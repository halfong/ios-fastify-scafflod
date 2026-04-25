import { getASRVendor, getVendorForModel } from '../lib/ASR'
import type { AsrTask, AsrVendor } from '../lib/ASR/types'
import CosStorage from '../utils/CosStorage'
import $cos from './cos.service'

const asrStorage = new CosStorage<AsrTask>('', $cos)
const asrKey = (cacheKey: string) => cacheKey + '.asr'

function getVendorInstance(vendorName: string): AsrVendor {
  const vendor = getASRVendor(vendorName)
  if (!vendor) throw new Error(`Unknown ASR vendor: ${vendorName}`)
  return vendor
}

function sanitize(task: AsrTask): AsrTask {
  const result = { ...task }
  if (result.raw) {
    result.data = getVendorInstance(result.vendor).formatData(result.raw)
    delete result.raw
  }
  return result
}

const $asrService = {
  resolveVendor(model: string, vendorOverride?: string): string {
    const vendor = vendorOverride ?? getVendorForModel(model)
    if (!vendor) throw `400:Unknown model '${model}' — provide a vendor`
    return vendor
  },

  async getCached(cacheKey: string): Promise<AsrTask | null> {
    try {
      const cached = await asrStorage.get(asrKey(cacheKey))
      if (!cached) return null
      return sanitize(cached)
    } catch {
      return null
    }
  },

  async createTask(cacheKey: string, vendorName: string, model: string, fileUrl: string, durationSec?: number): Promise<AsrTask> {
    const vendor = getVendorInstance(vendorName)
    const newTask = await vendor.createTask(model, fileUrl, {})
    if (durationSec) newTask.durationSec = durationSec
    await asrStorage.set(asrKey(cacheKey), newTask)
    return sanitize(newTask)
  },

  async queryTask(cacheKey: string): Promise<AsrTask> {
    let cachedTask: AsrTask
    try {
      cachedTask = await asrStorage.get(asrKey(cacheKey)) as AsrTask
    } catch {
      throw '404:ASR Task not found/created'
    }
    if (!cachedTask) throw '404:ASR Task not found/created'

    if (cachedTask.status !== 'SUCCESS' && cachedTask.status !== 'FAIL') {
      const vendor = getVendorInstance(cachedTask.vendor)
      const updatedTask = await vendor.queryTask(cachedTask.model, cachedTask.taskId)
      Object.assign(cachedTask, updatedTask)
      await asrStorage.set(asrKey(cacheKey), cachedTask)
    }

    const result = sanitize(cachedTask)

    if (result.status === 'SUCCESS' && !result.durationSec) {
      const words = result.data?.words ?? []
      const lastWord = words.filter(w => w.type === 'word').at(-1) ?? words.at(-1)
      if (lastWord) {
        result.durationSec = Math.ceil(lastWord.end)
        await asrStorage.set(asrKey(cacheKey), { ...cachedTask, durationSec: result.durationSec })
      }
    }

    return result
  },
}

export default $asrService
