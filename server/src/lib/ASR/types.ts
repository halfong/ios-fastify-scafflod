import { z } from 'zod'

export interface AsrVendor {
  createTask(model: string, fileUrl: string, params: any): Promise<AsrTask>
  queryTask(model: string, taskId: any): Promise<AsrTask>
  formatData(raw: any): AsrData
}

export const asrDataSchema = z.object({
  text: z.string().optional(),
  words: z.array(z.object({
    text: z.string(),
    start: z.number(),
    end: z.number(),
    type: z.string(),
  }).catchall(z.any())),
  lang_code: z.string().optional(),
  lang_probability: z.number().optional(),
})

export const asrTaskSchema = z.object({
  taskId: z.string(),
  vendor: z.string(),
  model: z.string(),
  status: z.enum(['WAITING', 'PROCESSING', 'SUCCESS', 'FAIL']),
  durationSec: z.number().optional(),
  raw: z.any().optional(),
  data: asrDataSchema.optional(),
})

export type AsrData = z.infer<typeof asrDataSchema>
export type AsrTask = z.infer<typeof asrTaskSchema>
