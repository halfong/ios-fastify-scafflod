import type { AsrTask, AsrData, AsrVendor } from '../types';
import { ElevenLabsClient } from "@elevenlabs/elevenlabs-js";

/**
 * ElevenLabs ASR vendor implementation
 * Uses ElevenLabs Speech-to-Text API with word-level timestamps
 * API Docs: https://elevenlabs.io/docs/api-reference/speech-to-text
 */
class ElevenLabsAsrVendor implements AsrVendor {
  static key = 'elevenlabs';
  static models = [
    'scribe_v1'
  ];

  private client: ElevenLabsClient;

  constructor(config?: { apiKey?: string }) {
    const apiKey = config?.apiKey || process.env.ELEVENLABS_API_KEY;
    if (!apiKey) {
      throw new Error('ElevenLabs API key not configured. Set ELEVENLABS_API_KEY environment variable.');
    }

    this.client = new ElevenLabsClient({ apiKey });
  }

  /**
   * Create a new ASR task by submitting audio file URL
   * Uses cloud_storage_url parameter for remote file access
   * @param fileUrl - Audio file URL (must be publicly accessible)
   * @param params - Additional parameters (language, model_id, etc.)
   */
  async createTask(model: string, fileUrl: string, params: any = {}): Promise<AsrTask> {
    try {
      const result = await this.client.speechToText.convert({
        cloudStorageUrl: fileUrl,
        modelId: model as any,
        webhook: true,
      });
      if (!result.transcriptionId) throw new Error('Missing transcription ID in response.');
      return {
        taskId: String(result.transcriptionId),
        model,
        status: "PROCESSING",
        vendor: ElevenLabsAsrVendor.key,
        raw: result,
      };
    } catch (error: any) {
      throw new Error(`ElevenLabs ASR createTask failed: ${error.message}`);
    }
  }

  /**
   * Query existing ASR task status
   * @param taskId - Transcription ID
   */
  async queryTask(model: string, taskId: any): Promise<AsrTask> {
    try {
      const result = await this.client.speechToText.transcripts.get(taskId);
      return {
        taskId: String(taskId),
        model,
        status: 'SUCCESS',
        vendor: ElevenLabsAsrVendor.key,
        raw: result,
      };
    } catch (error: any) {
      throw new Error(`ElevenLabs ASR queryTask failed: ${error.message}`);
    }
  }

  formatData(raw: any): AsrData {
    const words = (raw.words || []).map((word: any) => ({
      text: word.text,
      start: word.start,
      end: word.end,
      type: word.type || 'word',
      ...(word.logprob !== undefined && { logprob: word.logprob })
    }));

    return {
      text: raw.text || '',
      words,
      lang_code: raw.language_code,
      lang_probability: raw.language_probability,
    };
  }
}

export default ElevenLabsAsrVendor