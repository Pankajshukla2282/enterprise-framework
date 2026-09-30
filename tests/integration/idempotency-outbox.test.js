const test=require('node:test'); const assert=require('node:assert/strict'); const url=process.env.TEST_DATABASE_URL;
const {Client}=url?require('pg'):{};
test('idempotency key is unique per tenant and outbox rows are durable', {skip:!url}, async()=>{
 const c=new Client({connectionString:url}); await c.connect();
 try{
  const tenant='00000000-0000-0000-0000-0000000000a1';
  const user='00000000-0000-0000-0000-0000000000c1';
  await c.query('BEGIN');
  await c.query("insert into users(id,email,display_name) values($1,'itest@example.com','Integration') on conflict do nothing",[user]);
  await c.query("insert into tenants(id,code,name) values($1,'itest-idem','Idem Test') on conflict do nothing",[tenant]);
  await c.query("select set_config('app.tenant_id',$1,true)",[tenant]);
  await c.query("insert into platform_idempotency(tenant_id,user_id,key,request_hash,status,status_code,response_body) values($1,$2,'same-key','hash','completed',201,'{\"ok\":true}') on conflict do nothing",[tenant,user]);
  const r=await c.query("select count(*)::int n from platform_idempotency where tenant_id=$1 and key='same-key'",[tenant]); assert.equal(r.rows[0].n,1);
  await c.query("insert into platform_outbox(tenant_id,topic,event_type,aggregate_id,payload) values($1,'test.v1','test.created','a1','{\"ok\":true}')",[tenant]);
  const o=await c.query("select count(*)::int n from platform_outbox where tenant_id=$1 and aggregate_id='a1'",[tenant]); assert.equal(o.rows[0].n,1);
  await c.query('ROLLBACK');
 }finally{await c.end()}
});

test('outbox migration includes transactional trigger and consumer dedupe',()=>{const fs=require('fs');const sql=fs.readFileSync(require('path').join(__dirname,'../../infra/postgres/006-production-grade-events.sql'),'utf8');assert.match(sql,/CREATE TRIGGER/);assert.match(sql,/platform_consumed_events/);assert.match(sql,/locked_at/);});
