import jwt from 'jsonwebtoken';
import { Pool, PoolClient, QueryResultRow } from 'pg';
import Redis from 'ioredis';
import { Kafka, Producer, Consumer } from 'kafkajs';
import { randomUUID } from 'crypto';

export type Role = string;
export interface AuthContext { userId:string; tenantId:string; roles:Role[]; email?:string; }
export interface RequestContext extends AuthContext { requestId:string; }

function fail(message:string,statusCode:number):never { throw Object.assign(new Error(message),{statusCode}); }
export function parseAuth(req:any):AuthContext {
  const raw=(req.headers?.authorization||'').replace(/^Bearer\s+/i,'');
  if(!raw) fail('Missing bearer token',401);
  try {
    const p:any=jwt.verify(raw,process.env.JWT_SECRET||'change-me');
    const tenantId=p.tenantId || req.headers['x-tenant-id'];
    if(!p.sub || !tenantId) fail('tenantId is required',401);
    return {userId:String(p.sub),tenantId:String(tenantId),roles:[],email:p.email};
  } catch(e:any) { if(e.statusCode) throw e; fail('Invalid authentication token',401); }
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
}
export const db=new Database();
export const redis=new Redis(process.env.REDIS_URL||'redis://redis:6379',{maxRetriesPerRequest:3});

export async function authorizeTenant(auth:AuthContext):Promise<AuthContext>{
  const q=await db.query<{status:string;roles:string[]}>('SELECT t.status,m.roles FROM tenant_memberships m JOIN tenants t ON t.id=m.tenant_id WHERE m.tenant_id=$1 AND m.user_id=$2 AND m.status=\'active\'',[auth.tenantId,auth.userId]);
  if(!q.rowCount || q.rows[0].status!=='active') fail('Tenant membership denied',403);
  return {...auth,roles:q.rows[0].roles||[]};
}
export function requireRoles(ctx:AuthContext,allowed:string[]){if(!allowed.some(r=>ctx.roles.includes(r))) fail('Forbidden',403);}
export function requirePermission(ctx:AuthContext,permission:string){
  const rolePermissions:Record<string,string[]>={
    superadmin:['*'], admin:['tenant:read','tenant:write','users:manage','patients:read','patients:write','clinical:read','clinical:write','appointments:manage','billing:read','billing:write','departments:read','departments:write','staff:read','staff:write','beds:read','beds:write','admissions:read','admissions:write','prescriptions:read','prescriptions:write','lab:read','lab:write','radiology:read','radiology:write','insurance:read','insurance:write','discharge:write','students:read','students:write','guests:read','guests:write','rooms:manage','attendance:manage','attendance:read','college:read','college:write','faculty:manage','courses:manage','enrollments:manage','fees:manage','exams:manage','properties:read','properties:write','units:manage','listings:manage','leads:manage','viewings:manage','leases:manage','payments:manage','realestate:reports','rooms:read','rooms:manage','bookings:manage','checkin:manage','housekeeping:manage','hotel:reports'],
    doctor:['patients:read','patients:write','clinical:read','clinical:write','appointments:manage','departments:read','staff:read','prescriptions:read','prescriptions:write','lab:read','lab:write','radiology:read','radiology:write','admissions:read','admissions:write','discharge:write','billing:read','insurance:read','insurance:write'], nurse:['patients:read','clinical:read','clinical:write','appointments:read','departments:read','staff:read','admissions:read','admissions:write','beds:read','beds:write','prescriptions:read','lab:read','lab:write','radiology:read'],
    accountant:['patients:read','billing:read','billing:write','insurance:read','insurance:write'], receptionist:['patients:read','patients:write','appointments:manage','departments:read','admissions:read','admissions:write','beds:read'], patient:['patients:self','appointments:self','clinical:self','billing:self','prescriptions:self','lab:self','radiology:self'], teacher:['students:read','students:write','attendance:manage','attendance:read'], student:['students:self','attendance:self'], parent:['students:self','attendance:self'], faculty:['college:read','college:write','faculty:read','courses:read','enrollments:read','attendance:manage','attendance:read','exams:manage'], manager:['guests:read','guests:write','rooms:manage','rooms:read','bookings:manage','checkin:manage','housekeeping:manage','hotel:reports'], hoteladmin:['guests:read','guests:write','rooms:manage','rooms:read','bookings:manage','checkin:manage','housekeeping:manage','hotel:reports','billing:write'], housekeeping:['guests:read','rooms:read','rooms:manage','housekeeping:manage'], guest:['guests:self','bookings:self'], hotel_guest:['guests:self','bookings:self'], guests:['guests:read','guests:write'], collegeadmin:['college:read','college:write','faculty:manage','faculty:read','courses:manage','courses:read','enrollments:manage','attendance:manage','attendance:read','fees:manage','exams:manage'], college_student:['college:self','courses:self','attendance:self','fees:self','exams:self'], realestateadmin:['properties:read','properties:write','units:manage','listings:manage','leads:manage','viewings:manage','leases:manage','payments:manage','realestate:reports'], agent:['properties:read','listings:manage','leads:manage','viewings:manage','leases:read'], property_manager:['properties:read','units:manage','leases:manage','payments:manage','viewings:manage'], realestate_accountant:['properties:read','leases:read','payments:manage','realestate:reports'], buyer:['properties:read','listings:read','viewings:self','offers:self'], tenant:['properties:read','leases:self','payments:self','maintenance:self'], students:['students:read','students:write']
  };
  if(!ctx.roles.some(r=>rolePermissions[r]?.includes('*')||rolePermissions[r]?.includes(permission))) fail('Forbidden',403);
}
export function audit(action:string,ctx:AuthContext,entity:string,entityId:string,metadata:any={}){return db.withTenant(ctx.tenantId,c=>c.query('INSERT INTO platform_audit(tenant_id,user_id,action,entity,entity_id,metadata) VALUES($1,$2,$3,$4,$5,$6)',[ctx.tenantId,ctx.userId,action,entity,entityId,metadata]));}

export class EventBus {
  private producer?:Producer; private kafka:Kafka;
  constructor(){this.kafka=new Kafka({clientId:process.env.KAFKA_CLIENT_ID||'emtaf',brokers:(process.env.KAFKA_BROKERS||'redpanda:9092').split(',')});}
  async connect(){if(!this.producer){this.producer=this.kafka.producer();await this.producer.connect();}}
  async publish(topic:string,event:any){await this.connect();await this.producer!.send({topic,messages:[{key:event.aggregateId||randomUUID(),value:JSON.stringify({...event,eventId:randomUUID(),occurredAt:new Date().toISOString()})}]});}
  async subscribe(groupId:string,topics:string[],handler:(e:any)=>Promise<void>){const c:Consumer=this.kafka.consumer({groupId});await c.connect();for(const t of topics) await c.subscribe({topic:t,fromBeginning:false});await c.run({eachMessage:async({message})=>{if(message.value) await handler(JSON.parse(message.value.toString()));}});}
}
export const events=new EventBus();
export function tenantKey(tenantId:string,...parts:string[]){return ['emtaf',tenantId,...parts].join(':');}
export * from './http';

export function requireSelfOrPermission(ctx:AuthContext, permission:string, ownerUserId?:string, ownerPatientId?:string, currentUserId?:string){
  if(ctx.roles.includes('superadmin') || ctx.roles.includes('admin')) return;
  if(ctx.roles.includes('patient') && currentUserId && ownerUserId && currentUserId===ownerUserId) return;
  requirePermission(ctx, permission);
}
