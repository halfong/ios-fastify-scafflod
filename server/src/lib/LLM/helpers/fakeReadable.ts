import { Readable } from 'stream'
import type { LLMResult } from '../types'

/**
 * Create fake readable stream for cached results.
 * Simulates streaming by emitting cached data chunk by chunk.
 */
export default function fakeReadable(
  result: LLMResult,
  sizePerChunk: number = 10,
  delayMS: number = 50,
): Readable {
  const stream = new Readable({ read() {} })
  const { value, tokens, raw } = result

  let index = 0
  const interval = setInterval(() => {
    if (index < value.length) {
      const chunk = value.slice(index, index + sizePerChunk)
      stream.emit('data', { partial: chunk })
      index += sizePerChunk
    } else {
      clearInterval(interval)
      stream.push(null)
      stream.emit('end', { value, tokens, raw })
    }
  }, delayMS)

  return stream
}
