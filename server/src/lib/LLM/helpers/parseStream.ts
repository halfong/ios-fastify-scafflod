import { Readable } from 'stream'
import { LLMStreamChunk } from '../types'

/**
 * Normalize a raw vendor stream into a Readable emitting LLMStreamChunk objects.
 * - Accumulates `partial` into a final `value`
 * - Emits 'end' with the complete LLMResult when the stream closes
 */
export default function parseStream(
  readable: Readable,
  parseChunk: (chunk: any) => LLMStreamChunk
): Readable {
  const llmResult = { value: '', tokens: 1000, raw: null }
  const stream = new Readable({
    objectMode: true,
    read() {}
  })

  readable.on('data', (chunk) => {
    if (stream.closed || stream.destroyed) return

    try {
      const { partial = '', raw = undefined, tokens = undefined } = parseChunk(chunk)
      llmResult.value += partial

      if (tokens) {
        llmResult.raw = raw
        llmResult.tokens = tokens
        stream.push(null)
        stream.emit('end', llmResult)
      } else {
        stream.push({ partial })
      }
    } catch (e) {
      console.error('[parseStream error]', e, '\n', chunk.toString())
      stream.push({ partial: '💥' })
    }
  })

  readable.on('end', () => {
    if (!stream.destroyed) {
      stream.push(null)
      stream.emit('end', llmResult)
    }
  })

  readable.on('error', (err) => {
    stream.destroy(err)
  })

  return stream
}
