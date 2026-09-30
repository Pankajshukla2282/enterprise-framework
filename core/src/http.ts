import {parseAuth,authorizeTenant,requireRoles,requirePermission} from './index';
import {randomUUID} from 'crypto';

export async function context(req:any,res?:any){
  const auth=parseAuth(req);
  const effective=await authorizeTenant(auth);
  const traceHeader=String(req.headers['traceparent']||'');
  const parts=traceHeader.split('-');
  const traceId=(parts.length>=2 && /^[0-9a-f]{32}$/i.test(parts[1])) ? parts[1] : randomUUID().replace(/-/g,'');
  const requestId=String(req.headers['x-request-id']||randomUUID()).slice(0,128);
  req.emtaf={...effective,requestId,traceId};
  if(res){res.setHeader('x-request-id',requestId);res.setHeader('x-trace-id',traceId);}
  return req.emtaf;
}
export function roles(...r:string[]){return (req:any)=>requireRoles(req.emtaf,r);}
export function permission(p:string){return (req:any)=>requirePermission(req.emtaf,p);}
export function json(res:any,body:any,status=200){res.status(status).json(body);}
export function error(res:any,e:any){const status=e.statusCode||500;res.status(status).json({error:status>=500?'Internal server error':e.message,requestId:res.req?.emtaf?.requestId,traceId:res.req?.emtaf?.traceId});}
