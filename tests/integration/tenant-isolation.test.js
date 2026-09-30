const test = require('node:test');
const assert = require('node:assert/strict');
const url=process.env.TEST_DATABASE_URL;
const {Client}=url?require('pg'):{};
const tables=['hospital_patients','school_students','college_students','hotel_guests','realestate_properties'];

test('tenant isolation across representative domain tables', {skip:!url}, async()=>{
  const c=new Client({connectionString:url}); await c.connect();
  try{
    const a='00000000-0000-0000-0000-0000000000a1', b='00000000-0000-0000-0000-0000000000b1';
    await c.query('BEGIN');
    await c.query(`insert into tenants(id,code,name) values($1,'itest-a','Integration A') on conflict do nothing`,[a]);
    await c.query(`insert into tenants(id,code,name) values($1,'itest-b','Integration B') on conflict do nothing`,[b]);
    await c.query("select set_config('app.tenant_id',$1,true)",[a]);
    for(const table of tables){
      const cols=table==='hospital_patients' ? '(tenant_id,mrn,first_name,last_name)' : table==='school_students' ? '(tenant_id,admission_no,first_name,last_name)' : table==='college_students' ? '(tenant_id,enrollment_no,first_name,last_name)' : table==='hotel_guests' ? '(tenant_id,guest_no,first_name,last_name)' : '(tenant_id,property_code,name,property_type)';
      const vals=table==='hospital_patients' ? [a,'IT-A','A','One'] : table==='school_students' ? [a,'IT-A','A','One'] : table==='college_students' ? [a,'IT-A','A','One'] : table==='hotel_guests' ? [a,'G-A','A','One'] : [a,'P-A','Integration Property','residential'];
      const placeholders=vals.map((_,i)=>`$${i+1}`).join(',');
      await c.query(`insert into ${table}${cols} values(${placeholders})`,vals);
    }
    await c.query("select set_config('app.tenant_id',$1,true)",[b]);
    for(const table of tables){ const r=await c.query(`select count(*)::int n from ${table}`); assert.equal(r.rows[0].n,0,`tenant B must not see ${table}`); }
    await c.query('ROLLBACK');
  }finally{await c.end();}
});
