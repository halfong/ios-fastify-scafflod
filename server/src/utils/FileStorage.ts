import fs from 'fs'
import path from 'path'

/**
 * File-based storage for JSON data and raw buffers.
 * Supports storing JSON objects and binary data (images, audio, etc.)
 */
export default class FileStorage<T = any> {
  basePath: string

  constructor(basePath: string) {
    this.basePath = basePath
  }

  getPath(key: string, extension: string = ''): string {
    return path.join(this.basePath, `${key}${extension}`)
  }

  /**
   * Get cached JSON item by key. Returns null if not found.
   */
  async get(key: string): Promise<T | null> {
    try {
      const filePath = this.getPath(key, '.json')
      const fileContent = fs.readFileSync(filePath, 'utf8')
      return JSON.parse(fileContent) as T
    } catch (error) {
      if ((error as NodeJS.ErrnoException).code === 'ENOENT') {
        return null
      }
      throw new Error(`FileStorage.get(${key}): ${(error as Error).message}`)
    }
  }

  /**
   * Store JSON item by key. Creates directories as needed.
   */
  async set(key: string, value: T): Promise<void> {
    try {
      const filePath = this.getPath(key, '.json')
      const dir = path.dirname(filePath)
      if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true })
      }
      fs.writeFileSync(filePath, JSON.stringify(value))
    } catch (error) {
      throw new Error(`FileStorage.set(${key}): ${(error as Error).message}`)
    }
  }

  /**
   * Store raw buffer data with custom extension.
   */
  async setBuffer(key: string, buffer: Buffer, extension: string): Promise<void> {
    try {
      const ext = extension.startsWith('.') ? extension : `.${extension}`
      const filePath = this.getPath(key, ext)
      const dir = path.dirname(filePath)
      if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true })
      }
      fs.writeFileSync(filePath, buffer)
    } catch (error) {
      throw new Error(`FileStorage.setBuffer(${key}): ${(error as Error).message}`)
    }
  }

  /**
   * Get raw buffer data from file.
   */
  async getBuffer(key: string, extension: string): Promise<Buffer | null> {
    try {
      const ext = extension.startsWith('.') ? extension : `.${extension}`
      const filePath = this.getPath(key, ext)
      return fs.readFileSync(filePath)
    } catch (error) {
      if ((error as NodeJS.ErrnoException).code === 'ENOENT') {
        return null
      }
      throw new Error(`FileStorage.getBuffer(${key}): ${(error as Error).message}`)
    }
  }

  /**
   * Delete cached item by key (JSON file).
   */
  async delete(key: string): Promise<void> {
    try {
      const filePath = this.getPath(key, '.json')
      fs.unlinkSync(filePath)
    } catch (error) {
      if ((error as NodeJS.ErrnoException).code !== 'ENOENT') {
        throw new Error(`FileStorage.delete(${key}): ${(error as Error).message}`)
      }
    }
  }

  /**
   * Soft-delete a JSON cache entry by renaming it to .failed.json.
   * Preserves the file for inspection while making it invisible to get().
   */
  async softDelete(key: string): Promise<void> {
    try {
      const src = this.getPath(key, '.json')
      const dst = this.getPath(key, '.failed.json')
      fs.renameSync(src, dst)
    } catch (error) {
      if ((error as NodeJS.ErrnoException).code !== 'ENOENT') {
        throw new Error(`FileStorage.softDelete(${key}): ${(error as Error).message}`)
      }
    }
  }

  /**
   * Delete file with custom extension.
   */
  async deleteFile(key: string, extension: string): Promise<void> {
    try {
      const ext = extension.startsWith('.') ? extension : `.${extension}`
      const filePath = this.getPath(key, ext)
      fs.unlinkSync(filePath)
    } catch (error) {
      if ((error as NodeJS.ErrnoException).code !== 'ENOENT') {
        throw new Error(`FileStorage.deleteFile(${key}): ${(error as Error).message}`)
      }
    }
  }

  /**
   * Check if a file exists.
   */
  async exists(key: string, extension: string = '.json'): Promise<boolean> {
    const ext = extension.startsWith('.') ? extension : `.${extension}`
    const filePath = this.getPath(key, ext)
    return fs.existsSync(filePath)
  }
}
