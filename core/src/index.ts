import jwt from 'jsonwebtoken';
import { Pool, PoolClient, QueryResultRow } from 'pg';
import Redis from 'ioredis';
import { Kafka, Producer, Consumer } from 'kafkajs';
import { randomUUID, createHash } from 'crypto';
import { requireRoles, requirePermission } from './rbac';
export { requireRoles, requirePermission, hasPermission, rolePermissions } from './rbac';

const isProduction = (process.env.NODE_ENV || '').toLowerCase() === 'production';
const jwtSecret = process.env.JWT_SECRET;
if (isProduction && (!jwtSecret || jwtSecret.length < 32 || jwtSecret === 'change-me')) {
  throw new Error('JWT_SECRET must be configured with at least 32 characters in production');
}

export type Role = string;
export interface AuthContext { userId:string; tenantId:string; roles:Role[]; email?:string; }
export interface RequestContext extends AuthContext { requestId:string; traceId:string; }

export interface IdempotencyResult<T=any> { replayed:boolean; statusCode:number; body:T; }

function stableHash(value:any){ return createHash('sha256').update(JSON.stringify(value)).digest('hex'); }

function fail(message:string,statusCode:number):never { throw Object.assign(new Error(message),{statusCode}); }
export function parseAuth(req:any):AuthContext {
  const raw=(req.headers?.authorization||'').replace(/^Bearer\s+/i,'');
  if(!raw) fail('Missing bearer token',401);
  try {
    const verifyOptions:any={};
    if(process.env.JWT_ISSUER) verifyOptions.issuer=process.env.JWT_ISSUER;
    if(process.env.JWT_AUDIENCE) verifyOptions.audience=process.env.JWT_AUDIENCE;
    const p:any=jwt.verify(raw,jwtSecret||'change-me',verifyOptions);
    const headerTenant=req.headers['x-tenant-id'];
    if(headerTenant && p.tenantId && String(headerTenant)!==String(p.tenantId)) fail('Tenant header does not match token tenant',401);
    const tenantId=p.tenantId || headerTenant;
    if(!p.sub || !tenantId) fail('tenantId is required',401);
    return {userId:String(p.sub),tenantId:String(tenantId),roles:[],email:p.email};
  } catch(e:any) { if(e.statusCode) throw e; fail('Invalid authentication token',401); }
}

export async function closeInfrastructure(){
  try { await events.disconnect(); } catch {}
  try { await redis.quit(); } catch {}
  try { await db.pool.end(); } catch {}
}

export class Database {
  pool:Pool;
  constructor(){this.pool=new Pool({connectionString:process.env.DATABASE_URL,max:Number(process.env.DB_POOL_MAX||20),ssl:process.env.DB_SSL==='true'?{rejectUnauthorized:false}:undefined});}
  query<T extends QueryResultRow=any>(text:string,values:any[]=[]){return this.pool.query<T>(text,values);}
  async withTenant<T>(tenantId:string,fn:(c:PoolClient)=>Promise<T>):Promise<T>{
    const c=await this.pool.connect();
    try { await c.query('BEGIN'); await c.query("SELECT set_config('app.tenant_id',$1,true)",[tenantId]); const result=await fn(c); await c.query('COMMIT'); return result; }
    catch(e){await c.query('ROLLBACK');throw e;} finally{c.release();}
  }
  async tx<T>(fn:(c:PoolClient)=>Promise<T>){const c=await this.pool.connect();try{await c.query('BEGIN');const r=await fn(c);await c.query('COMMIT');return r;}catch(e){await c.query('ROLLBACK');throw e;}finally{c.release();}}
  async idempotent<T>(tenantId:string,userId:string,key:string,requestHash:string,fn:(c:PoolClient)=>Promise<{statusCode?:number;body:T}>):Promise<IdempotencyResult<T>>{
    if(!key || key.length>200) fail('Invalid Idempotency-Key',400);
    return this.withTenant(tenantId, async c=>{
      const upsert=await c.query("INSERT INTO platform_idempotency(tenant_id,user_id,key,request_hash,status,processing_expires_at) VALUES($1,$2,$3,$4,'processing',now()+interval '2 minutes') ON CONFLICT (tenant_id,key) DO UPDATE SET processing_expires_at=CASE WHEN platform_idempotency.status='processing' AND platform_idempotency.processing_expires_at < now() THEN now()+interval '2 minutes' ELSE platform_idempotency.processing_expires_at END RETURNING (xmax = 0) AS inserted",[tenantId,userId,key,requestHash]);
      const inserted=upsert.rows[0]?.inserted===true;
      const existing=await c.query('SELECT user_id,request_hash,status,status_code,response_body,processing_expires_at FROM platform_idempotency WHERE tenant_id=$1 AND key=$2 FOR UPDATE',[tenantId,key]);
      if(!existing.rowCount) fail('Unable to create idempotency record',500);
      const row=existing.rows[0];
      if(String(row.user_id)!==String(userId)) fail('Idempotency-Key belongs to a different user',409);
      if(row.request_hash!==requestHash) fail('Idempotency-Key was already used with a different request',409);
      if(!inserted && row.status==='processing' && row.processing_expires_at && new Date(row.processing_expires_at).getTime() > Date.now()) fail('Idempotent request is currently being processed',409);
      if(row.status==='completed') return {replayed:true,statusCode:row.status_code||200,body:row.response_body};
      const result=await fn(c);
      const statusCode=result.statusCode||200;
      await c.query("UPDATE platform_idempotency SET status='completed',status_code=$3,response_body=$4,completed_at=now(),processing_expires_at=NULL WHERE tenant_id=$1 AND key=$2",[tenantId,key,statusCode,result.body]);
      return {replayed:false,statusCode,body:result.body};
    });
  }

  async enqueueOutbox(c:PoolClient,event:{tenantId:string;topic:string;eventType:string;aggregateId?:string;payload:any;headers?:Record<string,string>}):Promise<string>{
    const id=randomUUID();
    await c.query('INSERT INTO platform_outbox(id,tenant_id,topic,event_type,aggregate_id,payload,headers) VALUES($1,$2,$3,$4,$5,$6,$7)',[id,event.tenantId,event.topic,event.eventType,event.aggregateId||null,event.payload,event.headers||{}]);
    return id;
  }
}

export const db=new Database();
export const redis=new Redis(process.env.REDIS_URL||'redis://redis:6379',{maxRetriesPerRequest:3,family:4,enableReadyCheck:true,retryStrategy:(times:number)=>Math.min(times*200,5000),reconnectOnError:(err:Error)=>{const msg=String(err?.message||'');return msg.includes('READONLY')||msg.includes('ETIMEDOUT')||msg.includes('ECONNRESET');}});
redis.on('error',(err:Error)=>{if((process.env.NODE_ENV||'').toLowerCase()!=='test') console.error('[redis]',err?.message);});

export async function authorizeTenant(auth:AuthContext):Promise<AuthContext>{
  const q=await db.query<{status:string;roles:string[]}>('SELECT t.status,m.roles FROM tenant_memberships m JOIN tenants t ON t.id=m.tenant_id WHERE m.tenant_id=$1 AND m.user_id=$2 AND m.status=\'active\'',[auth.tenantId,auth.userId]);
  if(!q.rowCount || q.rows[0].status!=='active') fail('Tenant membership denied',403);
  return {...auth,roles:q.rows[0].roles||[]};
}
export function audit(action:string,ctx:AuthContext,entity:string,entityId:string,metadata:any={}){return db.withTenant(ctx.tenantId,c=>c.query('INSERT INTO platform_audit(tenant_id,user_id,action,entity,entity_id,metadata) VALUES($1,$2,$3,$4,$5,$6)',[ctx.tenantId,ctx.userId,action,entity,entityId,metadata]));}

export async function consumeOnce(consumerGroup:string,event:any,handler:(c:PoolClient)=>Promise<void>){
  if(!event?.eventId || !event?.tenantId) fail('Invalid event envelope',400);
  return db.withTenant(String(event.tenantId),async c=>{
    const inserted=await c.query('INSERT INTO platform_consumed_events(consumer_group,event_id,tenant_id) VALUES($1,$2,$3) ON CONFLICT DO NOTHING RETURNING event_id',[consumerGroup,event.eventId,event.tenantId]);
    if(!inserted.rowCount) return false;
    await handler(c); return true;
  });
}

export class EventBus {
  private producer?:Producer; private kafka:Kafka;
  constructor(){this.kafka=new Kafka({clientId:process.env.KAFKA_CLIENT_ID||'emtaf',brokers:(process.env.KAFKA_BROKERS||'redpanda:9092').split(',')});}
  async connect(){if(!this.producer){this.producer=this.kafka.producer();await this.producer.connect();}}
  async disconnect(){if(this.producer){await this.producer.disconnect();this.producer=undefined;}}
  async publish(topic:string,event:any){await this.connect();await this.producer!.send({topic,messages:[{key:event.aggregateId||randomUUID(),value:JSON.stringify({...event,eventId:event.eventId||randomUUID(),occurredAt:event.occurredAt||new Date().toISOString()})}]});}
  async publishOutboxRow(row:any){return this.publish(row.topic,{eventId:row.id,tenantId:row.tenant_id,aggregateId:row.aggregate_id,type:row.event_type,payload:row.payload,headers:row.headers,occurredAt:row.created_at});}
  async subscribe(groupId:string,topics:string[],handler:(e:any)=>Promise<void>){const c:Consumer=this.kafka.consumer({groupId});await c.connect();for(const t of topics) await c.subscribe({topic:t,fromBeginning:false});await c.run({eachMessage:async({message}:{message:any})=>{if(message.value) await handler(JSON.parse(message.value.toString()));}});}
}
export const events=new EventBus();
export function tenantKey(tenantId:string,...parts:string[]){return ['emtaf',tenantId,...parts].join(':');}
export function requestHash(req:any){ return stableHash({method:req.method,path:req.path,body:req.body||{},query:req.query||{}}); }
export function getIdempotencyKey(req:any){ return String(req.headers?.['idempotency-key']||''); }
export async function idempotent<T>(req:any,key:string,fn:(c:PoolClient)=>Promise<{statusCode?:number;body:T}>){ return db.idempotent(req.emtaf.tenantId,req.emtaf.userId,key,requestHash(req),fn); }
export async function enqueueOutbox(c:PoolClient,ctx:AuthContext,topic:string,type:string,aggregateId:string,payload:any,headers:Record<string,string>={}){ return db.enqueueOutbox(c,{tenantId:ctx.tenantId,topic,eventType:type,aggregateId,payload,headers}); }
export * from './http';

export function requireSelfOrPermission(ctx:AuthContext, permission:string, ownerUserId?:string, ownerPatientId?:string, currentUserId?:string){
  if(ctx.roles.includes('superadmin') || ctx.roles.includes('admin')) return;
  if(ctx.roles.includes('patient') && currentUserId && ownerUserId && currentUserId===ownerUserId) return;
  requirePermission(ctx, permission);
}
