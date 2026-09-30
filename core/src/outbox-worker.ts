import { db, events } from './index';
import { randomUUID } from 'crypto';
const batchSize=Math.max(1,Math.min(Number(process.env.OUTBOX_BATCH_SIZE||50),500));
const pollMs=Math.max(100,Number(process.env.OUTBOX_POLL_MS||1000));
const lockMs=Math.max(5000,Number(process.env.OUTBOX_LOCK_MS||120000));
const workerId=`${process.env.HOSTNAME||'worker'}-${randomUUID()}`;

async function claimBatch(){
  return db.tx(async c=>{
    const r=await c.query(`UPDATE platform_outbox SET locked_at=now(), locked_by=$1, attempts=attempts+1 WHERE id IN (SELECT id FROM platform_outbox WHERE published_at IS NULL AND (next_attempt_at IS NULL OR next_attempt_at<=now()) AND (locked_at IS NULL OR locked_at < now()-($2::text||' milliseconds')::interval) ORDER BY created_at FOR UPDATE SKIP LOCKED LIMIT $3) RETURNING *`,[workerId,String(lockMs),batchSize]);
    return r.rows;
  });
}
async function processBatch(){
  const rows=await claimBatch();
  for(const row of rows){
    try{
      await events.publishOutboxRow(row);
      await db.query('UPDATE platform_outbox SET published_at=now(),last_error=NULL,locked_at=NULL,locked_by=NULL WHERE id=$1 AND locked_by=$2',[row.id,workerId]);
    }catch(e:any){
      await db.query(`UPDATE platform_outbox SET last_error=$2,locked_at=NULL,locked_by=NULL,next_attempt_at=now()+least(interval '15 minutes', interval '1 second' * power(2,least(attempts,8))) WHERE id=$1 AND locked_by=$3`,[row.id,String(e?.message||e),workerId]);
    }
  }
}
let stopping=false;
async function main(){
  console.log(`EMTAF outbox worker started: ${workerId}`);
  const stop=()=>{stopping=true}; process.once('SIGTERM',stop); process.once('SIGINT',stop);
  while(!stopping){try{await processBatch();}catch(e){console.error('outbox batch failed',e);}await new Promise(r=>setTimeout(r,pollMs));}
  await events.disconnect(); await db.pool.end();
}
main().catch(e=>{console.error(e);process.exit(1)});
