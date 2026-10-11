import type { FastifyRequest } from "fastify"

declare module 'fastify' {
    Interface FastifyRequest {
        user: User
    }
}