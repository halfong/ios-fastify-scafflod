/**
 * Generic interface any object-storage backend must satisfy.
 * Pass a concrete backend (e.g. a Tencent COS wrapper) to the CosStorage
 * constructor to decouple storage logic from the vendor SDK.
 */
export interface ObjectStorageBackend {
  getObject(key: string): Promise<any>
  putObject(key: string, data: any): Promise<any>
  getBuffer(key: string): Promise<Buffer | null>
  putBuffer(key: string, buffer: Buffer): Promise<any>
  delete(key: string): Promise<any>
  moveObject(src: string, dst: string): Promise<any>
  headObject(key: string): Promise<any>
}

/**
 * Object-storage–backed storage for JSON data and raw buffers.
 * Mirrors the FileStorage interface but persists to remote object storage.
 *
 * Usage:
 *   const store = new CosStorage('cache/llm', cosBackend)
 */
export default class CosStorage<T = any> {
  basePath: string
  private backend: ObjectStorageBackend

  constructor(basePath: string, backend: ObjectStorageBackend) {
    this.basePath = basePath
    this.backend = backend
  }

  /**
   * Get full object key for a storage key with extension.
   * An empty basePath means keys are used as-is (storage root).
   */
  getPath(key: string, extension: string = ''): string {
    return this.basePath ? `${this.basePath}/${key}${extension}` : `${key}${extension}`
  }

  /**
   * Get cached JSON item by key. Returns null if not found.
   */
  async get(key: string): Promise<T | null> {
    try {
      const result = await this.backend.getObject(this.getPath(key, '.json'))
      return result as T
    } catch {
      return null
    }
  }

  /**
   * Store JSON item by key.
   */
  async set(key: string, value: T): Promise<void> {
    await this.backend.putObject(this.getPath(key, '.json'), value)
  }

  /**
   * Store raw buffer data with custom extension.
   */
  async setBuffer(key: string, buffer: Buffer, extension: string): Promise<void> {
    const ext = extension.startsWith('.') ? extension : `.${extension}`
    await this.backend.putBuffer(this.getPath(key, ext), buffer)
  }

  /**
   * Get raw buffer data.
   */
  async getBuffer(key: string, extension: string): Promise<Buffer | null> {
    const ext = extension.startsWith('.') ? extension : `.${extension}`
    return this.backend.getBuffer(this.getPath(key, ext))
  }

  /**
   * Delete cached item by key (JSON file).
   */
  async delete(key: string): Promise<void> {
    await this.backend.delete(this.getPath(key, '.json'))
  }

  /**
   * Soft-delete a JSON cache entry by renaming it to .failed.json.
   * Preserves the file for inspection while making it invisible to get().
   */
  async softDelete(key: string): Promise<void> {
    const src = this.getPath(key, '.json')
    const dst = this.getPath(key, '.failed.json')
    await this.backend.moveObject(src, dst)
  }

  /**
   * Delete file with custom extension.
   */
  async deleteFile(key: string, extension: string): Promise<void> {
    const ext = extension.startsWith('.') ? extension : `.${extension}`
    await this.backend.delete(this.getPath(key, ext))
  }

  /**
   * Check if a file exists.
   */
  async exists(key: string, extension: string = '.json'): Promise<boolean> {
    const ext = extension.startsWith('.') ? extension : `.${extension}`
    const result = await this.backend.headObject(this.getPath(key, ext))
    return !!result
  }
}
