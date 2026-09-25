import type { FastifyRequest } from "fastify";

export type AuthenticatedUser = {
    id: string,
    mobileNumber: string,
    email: string | null,
}

export type AuthenticatedRequest = FastifyRequest & {
    user: AuthenticatedUser
}