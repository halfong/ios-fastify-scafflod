import { z } from 'zod'
import { Readable } from 'stream'

export interface LLMVendor {
  request(params: LLMRequestParams): Promise<Readable>
}

export interface LLMResultStorage {
  get: (key: string) => Promise<LLMResult | null>
  set: (key: string, result: LLMResult) => Promise<void>
  delete: (key: string) => Promise<void>
}

export const llmMessageSchema = z.object({
  role: z.enum(['user', 'bot', 'system']),
  content: z.string(),
})

export const llmRequestParamsSchema = z.object({
  model: z.string(),
  messages: z.array(llmMessageSchema),
  modelParams: z.object({
    maxOutputTokens: z.number().optional(),
    responseMimeType: z.string().optional(),
  }).catchall(z.any()).optional(),
})

export const llmVendorResultSchema = z.object({
  value: z.string(),
  tokens: z.number(),
  raw: z.any(),
})

export const llmResultSchema = z.object({
  model: z.string(),
  qk: z.string(),
  value: z.string(),
  tokens: z.number(),
  raw: z.any(),
  pending: z.boolean().optional(),
  startedAt: z.number().optional(),
  error: z.string().optional(),
})

export const llmStreamChunkSchema = z.object({
  partial: z.string().optional(),
  value: z.string().optional(),
  tokens: z.number().optional(),
  raw: z.any().optional(),
})

export type LLMMessage        = z.infer<typeof llmMessageSchema>
export type LLMRequestParams  = z.infer<typeof llmRequestParamsSchema>
export type LLMVendorResult   = z.infer<typeof llmVendorResultSchema>
export type LLMResult         = z.infer<typeof llmResultSchema>
export type LLMStreamChunk    = z.infer<typeof llmStreamChunkSchema>
