import type { FastifyRequest } from "fastify";

export interface AuthenticatedUser {
    id: string,
    mobileNumber: string,
    email: string | null,
}

export interface AuthenticatedRequest extends FastifyRequest  {
    user: AuthenticatedUser
}