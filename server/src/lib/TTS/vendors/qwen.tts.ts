import axios from 'axios'
import { TtsVendor, TtsRequestParams, TtsResult, TtsVoiceInfo } from '../types'
import qwenModelsData from './qwen.models.json'

// https://bailian.console.aliyun.com/cn-beijing/?spm=5176.29597918.J_SEsSjsNv72yRuRFS2VknO.2.64637b08ZFE65N&tab=doc#/doc/?type=model&url=2879134
// Maia: 勾人 女声
// Vivian: 淘气 中性 小孩

/**
 * Qwen TTS Vendor (Aliyun DashScope)
 * API Documentation: https://help.aliyun.com/zh/model-studio/qwen-tts-api
 * 
 * Supports Qwen-3-TTS-Flash and Qwen-TTS models
 */

// Extract voice IDs from models data
const QWEN_VOICES = qwenModelsData.voices.map((v: any) => v.id)

type QwenVoice = string

// Language types supported by Qwen TTS
type QwenLanguageType = 'Auto' | 'Chinese' | 'English' | 'German' | 'Italian' | 'Portuguese' | 'Spanish' | 'Japanese'

interface QwenTtsConfig {
  apiKey: string
  baseURL?: string
}

interface QwenTtsResponse {
  request_id: string
  code?: string
  message?: string
  output: {
    finish_reason: string
    audio: {
      url: string
      data?: string
      id: string
      expires_at?: number
    }
  }
  usage: {
    characters?: number
    total_tokens?: number
    input_tokens?: number
    output_tokens?: number
  }
}

class QwenTtsVendor implements TtsVendor {
  static key = 'qwen'
  static voices = QWEN_VOICES

  private apiKey: string
  private baseURL: string
  private cachedVoices: TtsVoiceInfo[] | null = null

  constructor(config?: QwenTtsConfig) {
    this.apiKey = config?.apiKey || process.env.TTS_QWEN_API_KEY || ''
    this.baseURL = config?.baseURL || process.env.TTS_QWEN_BASE_URL || 'https://dashscope.aliyuncs.com/api/v1'
    
    if (!this.apiKey) {
      throw new Error('Qwen TTS API key is required. Set TTS_QWEN_API_KEY environment variable or pass apiKey in config.')
    }
  }

  async synthesize(params: TtsRequestParams): Promise<TtsResult> {
    const { text, voice, speed = 1.0, pitch = 0, vendorParams = {} } = params

    // Validate voice
    const voiceData = qwenModelsData.voices.find((v: any) => v.id === voice)
    if (!voiceData) {
      throw new Error(`Unknown voice: ${voice}. See qwen.models.json for supported voices.`)
    }

    // Construct request payload
    const payload = {
      model: vendorParams.model || 'qwen3-tts-flash',
      input: {
        text,
        voice: voice,
        language_type: vendorParams.language_type as QwenLanguageType || 'Auto',
        stream: false,
        // speech_rate: 1000,  // only work for doc 智能语音交互 from SDK, not 百炼 api
        // pitch: pitch,  // only work for doc 智能语音交互 from SDK, not 百炼 api
        ...vendorParams.parameters
      }
    }

    try {
      const response = await axios.post<QwenTtsResponse>(
        `${this.baseURL}/services/aigc/multimodal-generation/generation`,
        payload,
        {
          headers: {
            'Authorization': `Bearer ${this.apiKey}`,
            'Content-Type': 'application/json',
            'X-DashScope-Async': 'disable'
          }
        }
      )

      const data = response.data

      // Check for errors (API errors return with code/message fields)
      if (data.code) {
        throw new Error(`Qwen TTS API error: ${data.code} - ${data.message}`)
      }

      if (!data.output?.audio?.url) {
        throw new Error('No audio URL in response')
      }

      // Download the audio file from the URL
      const audioResponse = await axios.get(data.output.audio.url, {
        responseType: 'arraybuffer'
      })

      const audio = Buffer.from(audioResponse.data)

      return {
        audio,
        format: 'mp3',
        vendor: QwenTtsVendor.key,
        voice,
        text,
        raw: data
      }
    } catch (error: any) {
      if (error.response) {
        const errData = error.response.data
        const errMsg = errData?.message || errData?.code || error.message
        throw new Error(`Qwen TTS failed: ${error.response.status} - ${errMsg}`)
      }
      throw new Error(`Qwen TTS failed: ${error.message}`)
    }
  }

  async listVoices(): Promise<TtsVoiceInfo[]> {
    // Cache voices to avoid repeated work
    if (this.cachedVoices) {
      return this.cachedVoices
    }

    // Convert from JSON data to TtsVoiceInfo format
    const voices: TtsVoiceInfo[] = qwenModelsData.voices.map((v: any) => ({
      name: v.id,
      vendor: QwenTtsVendor.key,
      language: v.languages[0] || 'zh-CN',
      gender: v.gender === 'male' ? 'MALE' as const : 
              v.gender === 'female' ? 'FEMALE' as const : 
              'NEUTRAL' as const
    }))

    this.cachedVoices = voices
    return voices
  }
}

export default QwenTtsVendor
