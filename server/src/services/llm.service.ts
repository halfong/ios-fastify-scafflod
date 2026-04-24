import crypto from 'crypto'
import { Readable } from 'stream'
import { getLLMVendor } from '../lib/LLM'
import { LLMRequestParams, LLMResult, LLMVendorResult } from '../lib/LLM/types'
import CosStorage from '../utils/CosStorage'
import $cos from './cos.service'

const llmCache = new CosStorage<LLMResult>('cache/llm', $cos)
const inflightKeys = new Set<string>()
const STALE_PENDING_MS = 30 * 60 * 1000

const $llmService = {
  getVendor: getLLMVendor,

  getCacheKey(params: LLMRequestParams): string {
    const hash = crypto.createHash('md5').update(JSON.stringify(params)).digest('hex')
    return `${params.model}/${hash}`
  },

  async request(vendorName: string, params: LLMRequestParams, useCache: boolean = true): Promise<LLMResult> {
    const cacheKey = this.getCacheKey(params)
    if (useCache && await llmCache.exists(cacheKey)) {
      const cached = await llmCache.get(cacheKey)
      if (cached) { console.log(`[LLM] cache hit  ${cacheKey}`); return { ...cached, fromCache: true } as any }
    }
    const vendor = this.getVendor(vendorName)
    if (!vendor) throw new Error(`Unknown LLM vendor: ${vendorName}`)
    console.log(`[LLM] request  vendor=${vendorName}  model=${params.model}  key=${cacheKey}`)
    const stream = await vendor.request(params)
    return new Promise((resolve, reject) => {
      let accumulatedValue = ''
      stream.on('data', (chunk: any) => { if (chunk.partial) accumulatedValue += chunk.partial })
      stream.on('end', async (endChunk: LLMVendorResult) => {
        const result: LLMResult = { model: params.model, qk: cacheKey.split('/')[1], value: endChunk.value || accumulatedValue, tokens: endChunk.tokens || 0, raw: endChunk.raw }
        console.log(`[LLM] done  tokens=${result.tokens}  key=${cacheKey}`)
        if (useCache) { try { await llmCache.set(cacheKey, result) } catch (error) { console.error('Failed to write to cache:', error) } }
        resolve(result)
      })
      stream.on('error', async (error: Error) => {
        console.error(`[LLM] stream error  key=${cacheKey}`, error)
        if (useCache) {
          try {
            await llmCache.set(cacheKey, { model: params.model, qk: cacheKey.split('/')[1], value: accumulatedValue, tokens: 0, raw: undefined, error: error.message })
            await llmCache.softDelete(cacheKey)
          } catch { /* best-effort */ }
        }
        reject(error)
      })
    })
  },

  async requestStream(vendorName: string, params: LLMRequestParams): Promise<Readable> {
    const vendor = this.getVendor(vendorName)
    if (!vendor) throw new Error(`Unknown LLM vendor: ${vendorName}`)
    return vendor.request(params)
  },

  async deleteCached(cacheKey: string): Promise<boolean> {
    try { await llmCache.delete(cacheKey); return true } catch { return false }
  },

  async softDeleteCached(cacheKey: string): Promise<void> {
    await llmCache.softDelete(cacheKey)
  },

  async isCached(params: LLMRequestParams): Promise<boolean> {
    const cacheKey = this.getCacheKey(params)
    return llmCache.exists(cacheKey, '.json')
  },

  async streamToCache(
    vendorName: string,
    params: LLMRequestParams,
    opts?: { onComplete?: (result: LLMResult) => Promise<void> }
  ): Promise<LLMResult> {
    const cacheKey = this.getCacheKey(params)
    let cached = await llmCache.get(cacheKey)
    if (cached) {
      if (cached.pending) {
        const age = Date.now() - (cached.startedAt ?? 0)
        if (!cached.startedAt || age > STALE_PENDING_MS) {
          console.log(`[LLM] streamToCache  stale pending (${Math.round(age / 1000)}s)  key=${cacheKey}`)
          await llmCache.softDelete(cacheKey)
          inflightKeys.delete(cacheKey)
          cached = null
        } else {
          console.log(`[LLM] streamToCache  pending  key=${cacheKey}`)
          return cached
        }
      } else {
        console.log(`[LLM] streamToCache  ready  key=${cacheKey}`)
        return cached
      }
    }
    if (inflightKeys.has(cacheKey)) {
      const placeholder = await llmCache.get(cacheKey)
      if (placeholder) { console.log(`[LLM] streamToCache  inflight  key=${cacheKey}`); return placeholder }
    }
    console.log(`[LLM] streamToCache  start  vendor=${vendorName}  model=${params.model}  key=${cacheKey}`)
    const pendingResult: LLMResult = { model: params.model, qk: cacheKey.split('/')[1], value: '', tokens: 0, raw: undefined, pending: true, startedAt: Date.now() }
    await llmCache.set(cacheKey, pendingResult)
    inflightKeys.add(cacheKey)
    try {
      const stream = await this.requestStream(vendorName, params)
      stream.on('end', async (endChunk: LLMVendorResult) => {
        inflightKeys.delete(cacheKey)
        const result: LLMResult = { model: params.model, qk: cacheKey.split('/')[1], value: endChunk.value, tokens: endChunk.tokens, raw: endChunk.raw }
        console.log(`[LLM] streamToCache  done  tokens=${result.tokens}  key=${cacheKey}`)
        await llmCache.set(cacheKey, result)
        if (opts?.onComplete) { try { await opts.onComplete(result) } catch (err) { console.error('[llmService.streamToCache] onComplete error:', err) } }
      })
      stream.on('error', async (err: Error) => {
        inflightKeys.delete(cacheKey)
        console.error(`[LLM] streamToCache  stream error  key=${cacheKey}`, err)
        try {
          await llmCache.set(cacheKey, { model: params.model, qk: cacheKey.split('/')[1], value: '', tokens: 0, raw: undefined, pending: true, startedAt: pendingResult.startedAt, error: err.message })
          await llmCache.softDelete(cacheKey)
        } catch { /* best-effort */ }
      })
    } catch (error) {
      inflightKeys.delete(cacheKey)
      try {
        await llmCache.set(cacheKey, { model: params.model, qk: cacheKey.split('/')[1], value: '', tokens: 0, raw: undefined, pending: true, startedAt: pendingResult.startedAt, error: (error as Error).message })
        await llmCache.softDelete(cacheKey)
      } catch { /* best-effort */ }
      throw error
    }
    return pendingResult
  },
}

export default $llmService
