import { z } from 'zod'

export const register = z.object ({
    email: z.string(),
    name: z.string(),
    password: z.string().min(6)
})

export const login = z.object ({
    email: z.string(),
    password: z.string().min(6)
})