import { Readable } from 'stream'
import OpenAI from 'openai'
import parseStream from '../helpers/parseStream'
import type { LLMRequestParams, LLMVendor, LLMStreamChunk } from '../types'

// https://modelstudio.console.aliyun.com/ap-southeast-1?tab=api#/api/?type=model&url=3016807
// SGP endpoint for international access
const ENDPOINT = 'https://dashscope-intl.aliyuncs.com/compatible-mode/v1'

class LLMQianwen implements LLMVendor {
  static key = 'qwen'
  static DEFAULT_MODEL = 'qwen-plus'
  
  private client: OpenAI

  constructor(config?: { apiKey?: string }) {
    const apiKey = config?.apiKey || process.env.QWEN_API_KEY || ''
    
    if (!apiKey) {
      throw new Error('Qwen API key not configured. Set QWEN_API_KEY environment variable.')
    }
    
    this.client = new OpenAI({
      apiKey,
      baseURL: ENDPOINT,
    })
  }

  /**
   * Request Qianwen LLM API using OpenAI SDK
   */
  async request(params: LLMRequestParams): Promise<Readable> {
    try {
      const stream = await this.client.chat.completions.create({
        model: params.model || LLMQianwen.DEFAULT_MODEL,
        messages: params.messages as any,
        stream: true,
        stream_options: { include_usage: true },
        max_tokens: params.modelParams?.maxOutputTokens,
      })

      // Create a readable stream that will receive chunks
      const rawStream = new Readable({ read() {} })

      // Consume the OpenAI stream immediately (only once)
      ;(async () => {
        try {
          let finalChunk: any = null
          for await (const chunk of stream) {
            const delta = chunk.choices[0]?.delta?.content || ''
            const isEnd = chunk.choices[0]?.finish_reason !== null
            const hasUsage = (chunk as any).usage?.total_tokens
            
            // Store final chunk for usage info
            if (isEnd || hasUsage) {
              finalChunk = chunk
            }
            
            const llmChunk: LLMStreamChunk = {
              partial: delta,
            }
            
            rawStream.push(JSON.stringify(llmChunk) + '\n')
            
            // After finish_reason, wait for usage chunk
            if (hasUsage) {
              const finalLlmChunk: LLMStreamChunk = {
                partial: '',
                tokens: (chunk as any).usage.total_tokens,
                raw: finalChunk,
              }
              rawStream.push(JSON.stringify(finalLlmChunk) + '\n')
              rawStream.push(null)
              break
            }
          }
          
          // If no usage was received, close anyway
          if (!finalChunk || !(finalChunk as any).usage) {
            rawStream.push(null)
          }
        } catch (err) {
          rawStream.destroy(err as Error)
        }
      })()

      // Use parseStream to normalize the output
      return parseStream(rawStream, (chunk) => {
        try {
          return JSON.parse(chunk.toString())
        } catch (e) {
          return { partial: '' }
        }
      })
    } catch (err: any) {
      throw new Error(`Qianwen API Error: ${err.message || 'Unknown error'}`)
    }
  }
}

export default LLMQianwen
