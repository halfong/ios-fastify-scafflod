import { Readable } from 'stream'
import { GoogleGenAI, HarmBlockThreshold, HarmCategory } from '@google/genai'
import parseStream from '../helpers/parseStream'
import type { LLMRequestParams, LLMVendor, LLMVendorResult, LLMStreamChunk } from '../types'

const DEFAULT_SAFETY_SETTINGS = [
  { category: HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT, threshold: HarmBlockThreshold.BLOCK_NONE },
  { category: HarmCategory.HARM_CATEGORY_HARASSMENT, threshold: HarmBlockThreshold.BLOCK_NONE },
  { category: HarmCategory.HARM_CATEGORY_HATE_SPEECH, threshold: HarmBlockThreshold.BLOCK_NONE },
  { category: HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT, threshold: HarmBlockThreshold.BLOCK_NONE },
]

class LLMGemini implements LLMVendor {  
  static key = 'gemini'
  static DEFAULT_MODEL = 'gemini-2.0-flash'

  private client: GoogleGenAI
  private apiKey: string

  constructor(config?: { apiKey?: string }) {
    this.apiKey = config?.apiKey || process.env.GEMINI_API_KEY || ''
    
    if (!this.apiKey) {
      throw new Error('Gemini API key not configured. Set GEMINI_API_KEY environment variable.')
    }
    
    if (this.apiKey.startsWith('AQ.')) {
      this.client = new GoogleGenAI({
        vertexai: true,
        apiKey: this.apiKey,
      })
    } else {
      // Use standard Gemini API key
      this.client = new GoogleGenAI({ apiKey: this.apiKey })
    }
  }
  
  /**
   * Request Gemini LLM API (supports both API key and Vertex AI API key)
   */
  async request(params: LLMRequestParams): Promise<Readable> {
    const streamResponse = await this.client.models.generateContentStream({
      model: params.model || LLMGemini.DEFAULT_MODEL,
      contents: params.messages.map((m) => ({
        role: { 'bot': 'model', user: 'user', system: 'user' }[m.role] as 'user' | 'model',
        parts: [{ text: m.content }],
      })),
      config: {
        temperature: 1,
        topP: 0.95,
        topK: 40,
        maxOutputTokens: params.modelParams?.maxOutputTokens,
        responseMimeType: params.modelParams?.responseMimeType as 'text/plain' | 'application/json' | undefined,
        safetySettings:  DEFAULT_SAFETY_SETTINGS,
      },
    })

    // Create a raw stream with chunks
    const rawStream = new Readable({ read() {} })
    
    // Process the stream chunks
    ;(async () => {
      try {
        for await (const chunk of streamResponse) {
          const chunkText = chunk.text || ''
          
          const streamChunk: LLMStreamChunk = {
            partial: chunkText,  // Send only delta, not accumulated
            tokens: chunk.usageMetadata?.totalTokenCount || 0,
            raw: chunk.candidates,
          }
          rawStream.push(JSON.stringify(streamChunk) + '\n')
        }
        rawStream.push(null)
      } catch (error) {
        rawStream.destroy(error as Error)
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
  }
}

export default LLMGemini