import * as tencentcloud from "tencentcloud-sdk-nodejs-asr";
import type { AsrTask, AsrData, AsrVendor } from '../types';

const AsrClient = tencentcloud.asr.v20190614.Client;

/**
 * Tencent Cloud ASR vendor implementation
 * Supports multiple Chinese and English models with word-level timestamps
 */
class TCloudAsrVendor implements AsrVendor {
  static key = 'tcloud';
  static models = [
    "16k_zh_en",  // 中英粤+9种方言大模型引擎【大模型版】。当前模型同时支持中文、英语、粤语、四川、陕西、河南、上海、湖南、湖北、安徽、闽南和潮汕方言识别，模型参数量极大，语言模型性能增强，针对噪声大、回音大、人声小、人声远等低质量音频的识别准确率极大提升;
    "16k_zh_large", // 普方英大模型引擎【大模型版】。当前模型同时支持中文、英文、多种中文方言等语言的识别，模型参数量极大，语言模型性能增强，针对噪声大、回音大、人声小、人声远等低质量音频的识别准确率极大提升，点击这里 对比中文普通话常规版本与普方英大模型版本的识别效果；
    "16k_multi_lang", // 多语种大模型引擎【大模型版】。当前模型同时支持英语、日语、韩语、阿拉伯语、菲律宾语、法语、印地语、印尼语、马来语、葡萄牙语、西班牙语、泰语、土耳其语、越南语、德语的识别，可实现15个语种的自动识别(句子/段落级别)；
    "16k_zh", // 中文普通话通用引擎，支持中文普通话和少量英语，使用丰富的中文普通话语料训练，覆盖场景广泛，适用于除电话通讯外的所有中文普通话识别场景；
    "16k_en", // 英语；
    "16k_yue",  // 粤语；
    "16k_zh-PY",  // 中英粤混合引擎，使用一个引擎同时识别中文普通话、英语、粤语三个语言;
    "16k_zh-TW", // 中文繁体；
    "16k_ja", // 日语；
    "16k_ko", // 韩语；
    "16k_vi", // 越南语；
    "16k_ms", // 马来语；
    "16k_id", // 印度尼西亚语；
    "16k_fil",  // 菲律宾语；
    "16k_th", // 泰语；
    "16k_pt", // 葡萄牙语；
    "16k_tr", // 土耳其语；
    "16k_ar", // 阿拉伯语；
    "16k_es", // 西班牙语；
    "16k_hi", // 印地语；
    "16k_fr", // 法语；
    "16k_zh_medical", // 中文医疗引擎；
    "16k_de", // 德语；
  ];

  private client: InstanceType<typeof AsrClient>;

  constructor(config?: { secretId?: string; secretKey?: string; region?: string }) {
    const secretId = config?.secretId || process.env.ASR_SECRET_ID;
    const secretKey = config?.secretKey || process.env.ASR_SECRET_KEY;
    const region = config?.region || process.env.ASR_REGION || 'ap-guangzhou';

    if (!secretId || !secretKey) {
      throw new Error('TCloud ASR credentials not configured. Set ASR_SECRET_ID and ASR_SECRET_KEY environment variables.');
    }

    this.client = new AsrClient({
      credential: { secretId, secretKey },
      region,
      profile: {
        httpProfile: {
          endpoint: "asr.tencentcloudapi.com",
        },
      },
    });
  }

  /**
   * Create a new ASR task
   * @param fileUrl - Audio file URL (must be accessible via HTTP/HTTPS)
   * @param params - Additional parameters (engineModelType is required)
   */
  async createTask(model: string, fileUrl: string, params: any = {}): Promise<AsrTask> {
    try {
      console.log('TCloud ASR createTask called with model:', model, 'fileUrl:', fileUrl, 'params:', params);
      const response = await this.client.CreateRecTask({
        EngineModelType: model,
        ChannelNum: params.channelNum || 1,
        ResTextFormat: params.resTextFormat || 3,
        SourceType: params.sourceType || 0,
        Url: fileUrl,
      });

      if (!response.Data?.TaskId) throw new Error('No TaskId in response');

      return {
        taskId: String(response.Data.TaskId),
        model,
        status: "PROCESSING",
        vendor: TCloudAsrVendor.key,
        raw: response.Data,
      };
    } catch (error: any) {
      throw new Error(`TCloud ASR createTask failed: ${error.message}`);
    }
  }

  /**
   * Query existing ASR task status and results
   * @param taskId - Numeric task ID from TCloud
   */
  async queryTask(model: string, taskId: any): Promise<AsrTask> {
    const numericTaskId = typeof taskId === 'number' ? taskId : parseInt(taskId, 10);
    
    if (isNaN(numericTaskId)) {
      throw new Error(`Invalid TCloud task ID: ${taskId}`);
    }

    try {
      const response = await this.client.DescribeTaskStatus({
        TaskId: numericTaskId
      });

      const data = response.Data;
      if (!data) {
        throw new Error('Invalid TCloud ASR response: missing Data field');
      }

      const statusMap: Record<number, 'WAITING' | 'PROCESSING' | 'SUCCESS' | 'FAIL'> = {
        0: 'WAITING',
        1: 'PROCESSING',
        2: 'SUCCESS',
        3: 'FAIL'
      };
      const status = (data.Status !== undefined && statusMap[data.Status]) || 'FAIL';

      return {
        taskId: String(data.TaskId),
        model,
        status,
        vendor: TCloudAsrVendor.key,
        raw: data,
      };
    } catch (error: any) {
      throw new Error(`TCloud ASR queryTask failed: ${error.message}`);
    }
  }

  formatData(raw: any): AsrData {
    const words: AsrData['words'] = [];
    
    if (raw.ResultDetail && Array.isArray(raw.ResultDetail)) {
      for (const segment of raw.ResultDetail) {
        const segmentStartMs = segment.StartMs || 0;
        
        if (segment.Words && Array.isArray(segment.Words)) {
          for (const word of segment.Words) {
            words.push({
              text: word.Word,
              start: (segmentStartMs + word.OffsetStartMs) / 1000,
              end: (segmentStartMs + word.OffsetEndMs) / 1000,
              type: "word"
            });
          }
        }
      }
    }

    return {
      text: raw.Result || '',
      words,
      lang_code: raw.ResultDetail?.[0]?.LangType,
    };
  }
}

export default TCloudAsrVendor