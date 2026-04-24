import { TextToSpeechClient } from '@google-cloud/text-to-speech'
import { TtsVendor, TtsRequestParams, TtsResult, TtsVoiceInfo } from '../types'
import googleVoicesData from './google.voices.json'

/**
 * [List voices]
 * curl -H "Authorization: Bearer $(gcloud auth print-access-token
)" -H "x-goog-user-project: senselin" "https://texttospeech.googleapis.com/v1/voices" | jq '.' > /Library/
WebServer/Documents/projects/scaffolds/fastify-ts/src/lib/TTS/vendors/google.voices.json
 */

class GoogleTtsVendor implements TtsVendor {
  static key = 'google'
  static voices = googleVoicesData.voices.map((v: any) => v.name)

  private client: TextToSpeechClient
  private cachedVoices: TtsVoiceInfo[] | null = null

  constructor(config?: { keyFilename?: string; projectId?: string; apiKey?: string }) {
    // Support multiple auth methods
    const clientConfig: any = {}
    
    if (config?.keyFilename) {
      clientConfig.keyFilename = config.keyFilename
    } else if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
      clientConfig.keyFilename = process.env.GOOGLE_APPLICATION_CREDENTIALS
    }
    
    if (config?.projectId || process.env.TTS_GOOGLE_PROJECT_ID) {
      clientConfig.projectId = config?.projectId || process.env.TTS_GOOGLE_PROJECT_ID
    }
    
    if (config?.apiKey) {
      clientConfig.apiKey = config.apiKey
    }

    this.client = new TextToSpeechClient(clientConfig)
  }

  async synthesize(params: TtsRequestParams): Promise<TtsResult> {
    const { text, voice, speed = 1.0, pitch = 0, vendorParams = {} } = params

    // Parse voice name to extract language code and voice name
    const languageCode = voice.split('-').slice(0, 2).join('-') // e.g., "en-US" from "en-US-Wavenet-A"

    const request = {
      input: { text },
      voice: {
        languageCode,
        name: voice,
        ...vendorParams.voice
      },
      audioConfig: {
        audioEncoding: 'MP3' as const,
        speakingRate: speed,
        pitch,
        ...vendorParams.audioConfig
      }
    }

    try {
      const [response] = await this.client.synthesizeSpeech(request)
      
      if (!response.audioContent) {
        throw new Error('No audio content in response')
      }

      const audio = Buffer.from(response.audioContent as Uint8Array)

      return {
        audio,
        format: 'mp3',
        vendor: GoogleTtsVendor.key,
        voice,
        raw: response
      }
    } catch (error: any) {
      throw new Error(`Google TTS failed: ${error.message}`)
    }
  }

  async listVoices(): Promise<TtsVoiceInfo[]> {
    // Cache voices to avoid repeated API calls
    if (this.cachedVoices) {
      return this.cachedVoices
    }

    try {
      const [response] = await this.client.listVoices({})
      
      const voices: TtsVoiceInfo[] = (response.voices || []).map(voice => ({
        name: voice.name || '',
        vendor: GoogleTtsVendor.key,
        language: voice.languageCodes?.[0] || '',
        gender: voice.ssmlGender as any
      }))

      this.cachedVoices = voices
      return voices
    } catch (error: any) {
      throw new Error(`Failed to list Google voices: ${error.message}`)
    }
  }
}

export default GoogleTtsVendor
