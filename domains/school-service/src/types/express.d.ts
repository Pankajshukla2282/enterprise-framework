export {};

declare global {
  namespace Express {
    interface Request {
      emtaf: {
        userId: string;
        tenantId: string;
        roles: string[];
        email?: string;
        requestId: string;
        traceId: string;
      };
    }
  }
}
