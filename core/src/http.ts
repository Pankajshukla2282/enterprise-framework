import {parseAuth,authorizeTenant,requireRoles,requirePermission} from './index';
import {randomUUID} from 'crypto';
export async function context(req:any){const auth=parseAuth(req);const effective=await authorizeTenant(auth);req.emtaf={...effective,requestId:req.headers['x-request-id']||randomUUID()};return req.emtaf;}
export function roles(...r:string[]){return (req:any)=>requireRoles(req.emtaf,r);}
export function permission(p:string){return (req:any)=>requirePermission(req.emtaf,p);}
export function json(res:any,body:any,status=200){res.status(status).json(body);}
export function error(res:any,e:any){const status=e.statusCode||500;res.status(status).json({error:status>=500?'Internal server error':e.message,requestId:res.req?.emtaf?.requestId});}
