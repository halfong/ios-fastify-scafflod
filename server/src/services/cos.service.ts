import COS from 'cos-nodejs-sdk-v5';

const secretId = process.env.COS_SECRET_ID || '';
const secretKey = process.env.COS_SECRET_KEY || '';
const bucket = process.env.COS_BUCKET || '';
const region = process.env.COS_REGION || '';

class CosService {

  private client: COS;

  constructor(secretId: string, secretKey: string) {
    if (!secretId || !secretKey) throw new Error('COS credentials not configured. Set COS_SECRET_ID and COS_SECRET_KEY.');
    if (!bucket || !region) throw new Error('COS bucket/region not configured. Set COS_BUCKET and COS_REGION.');
    this.client = new COS({ SecretId: secretId, SecretKey: secretKey });
  }

  ukey(uid: string, key: string | undefined): string {
    return ['users', uid, key].filter(i => i).join('/');
  }

  async presignURL(objectKey: string, method: 'GET' | 'PUT' = 'GET', expiresIn: number = 60 * 60): Promise<{ url: string; objectKey: string; expiresIn: number; existed: boolean; method: string }> {
    const existed = method === 'GET' ? await this.headObject(objectKey) : undefined;
    const url = this.client.getObjectUrl({
      Bucket: bucket, Region: region, Key: objectKey, Expires: expiresIn, Sign: true, Method: method,
    });
    return { url, objectKey, expiresIn, existed: !!existed, method };
  }

  async list(prefix: string | undefined, maxKeys: number = 1000): Promise<any> {
    return new Promise((resolve, reject) => {
      this.client.getBucket(
        { Bucket: bucket, Region: region, Prefix: prefix, MaxKeys: maxKeys },
        (err: any, data: any) => { if (err) reject(err); else resolve(data); }
      );
    });
  }

  async delete(objectKey: string): Promise<{ objectKey: string; deleted: boolean }> {
    return new Promise((resolve, reject) => {
      this.client.deleteObject(
        { Bucket: bucket, Region: region, Key: objectKey },
        (err: any) => { if (err) reject(err); else resolve({ objectKey, deleted: true }); }
      );
    });
  }

  async getObject(objectKey: string): Promise<any> {
    return new Promise((resolve, reject) => {
      this.client.getObject(
        { Bucket: bucket, Region: region, Key: objectKey },
        (err: any, data: any) => {
          if (err) reject(err);
          else { try { resolve(JSON.parse(data.Body.toString())); } catch (e) { reject(e); } }
        }
      );
    });
  }

  async putBuffer(objectKey: string, buffer: Buffer): Promise<{ objectKey: string; uploaded: boolean }> {
    return new Promise((resolve, reject) => {
      this.client.putObject(
        { Bucket: bucket, Region: region, Key: objectKey, Body: buffer },
        (err: any) => { if (err) reject(err); else resolve({ objectKey, uploaded: true }); }
      );
    });
  }

  async getBuffer(objectKey: string): Promise<Buffer | null> {
    return new Promise((resolve, reject) => {
      this.client.getObject(
        { Bucket: bucket, Region: region, Key: objectKey },
        (err: any, data: any) => {
          if (err) {
            if (err.statusCode === 404 || err.code === 'NoSuchKey') resolve(null);
            else reject(err);
          } else {
            resolve(data.Body as Buffer);
          }
        }
      );
    });
  }

  async putObject(objectKey: string, body: any): Promise<{ objectKey: string; uploaded: boolean }> {
    return new Promise((resolve, reject) => {
      this.client.putObject(
        { Bucket: bucket, Region: region, Key: objectKey, Body: JSON.stringify(body) },
        (err: any) => { if (err) reject(err); else resolve({ objectKey, uploaded: true }); }
      );
    });
  }

  async headObject(objectKey: string): Promise<COS.HeadObjectResult | undefined> {
    return new Promise((resolve) => {
      this.client.headObject(
        { Bucket: bucket, Region: region, Key: objectKey },
        (err: any, data: any) => { if (err) resolve(undefined); else resolve(data); }
      );
    });
  }

  async moveObject(sourceObjectKey: string, destObjectKey: string): Promise<{ sourceKey: string; destKey: string; moved: boolean }> {
    return new Promise((resolve, reject) => {
      this.client.putObjectCopy(
        { Bucket: bucket, Region: region, Key: destObjectKey, CopySource: `${bucket}.cos.${region}.myqcloud.com/${sourceObjectKey}` },
        (err: any) => {
          if (err) reject(err);
          else {
            this.client.deleteObject(
              { Bucket: bucket, Region: region, Key: sourceObjectKey },
              (deleteErr: any) => { if (deleteErr) reject(deleteErr); else resolve({ sourceKey: sourceObjectKey, destKey: destObjectKey, moved: true }); }
            );
          }
        }
      );
    });
  }

  async getMediaDuration(objectKey: string): Promise<number> {
    try {
      const result = await this.client.request({ Bucket: bucket, Region: region, Method: 'GET', Key: objectKey, Query: { 'ci-process': 'videoinfo' } });
      console.log("COS media info result:", result);
      return Number(result.Response.MediaInfo.Format.Duration);
    } catch (e) {
      throw "500:Failed to get media duration from COS: " + (e instanceof Error ? e.message : String(e));
    }
  }
}

const $cos = new CosService(secretId, secretKey);
export default $cos;
