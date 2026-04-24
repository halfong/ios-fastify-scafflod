import { z } from 'zod'

export interface TtsVendor {
  synthesize(params: TtsRequestParams): Promise<TtsResult>
  listVoices(): Promise<TtsVoiceInfo[]>
}

export interface TtsResultStorage {
  get(key: string): Promise<TtsResult | null>
  set(key: string, result: TtsResult): Promise<void>
  delete(key: string): Promise<void>
}

export const ttsVoiceInfoSchema = z.object({
  name: z.string(),
  vendor: z.string(),
  language: z.string(),
  gender: z.enum(['MALE', 'FEMALE', 'NEUTRAL']).optional(),
})

export const ttsRequestParamsSchema = z.object({
  text: z.string(),
  vendorName: z.string(),
  voice: z.string(),
  speed: z.number().optional(),
  pitch: z.number().optional(),
  vendorParams: z.record(z.string(), z.any()).optional(),
})

export const ttsResultSchema = z.object({
  audio: z.instanceof(Buffer, { message: 'Expected a Buffer' }),
  format: z.literal('mp3'),
  vendor: z.string(),
  voice: z.string(),
  text: z.string().optional(),
  raw: z.any().optional(),
})

export type TtsVoiceInfo     = z.infer<typeof ttsVoiceInfoSchema>
export type TtsRequestParams = z.infer<typeof ttsRequestParamsSchema>
export type TtsResult        = z.infer<typeof ttsResultSchema>
