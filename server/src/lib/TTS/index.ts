import { TtsVendor } from './types'

// Vendor class registry — register vendors with registerTTSVendor() before use.
// Extension point: in your app, call registerTTSVendor('myvendor', MyVendorClass)
// to add a vendor without modifying this file.
const vendorClasses: { [key: string]: new (config?: any) => TtsVendor } = {}

// Instance cache (one singleton per vendor name)
const vendorInstances: { [key: string]: TtsVendor } = {}

/**
 * Register a TTS vendor class by name.
 * Call this once at app startup before any getTTSVendor() calls.
 */
export function registerTTSVendor(name: string, VendorClass: new (config?: any) => TtsVendor): void {
  vendorClasses[name] = VendorClass
  delete vendorInstances[name]
}

/**
 * Get TTS vendor instance by name. Returns null if vendor not registered.
 * Instantiates with .env credentials on first call; subsequent calls return
 * the cached instance.
 */
export function getTTSVendor(vendorName: string): TtsVendor | null {
  if (vendorInstances[vendorName]) {
    return vendorInstances[vendorName]
  }
  const VendorClass = vendorClasses[vendorName]
  if (!VendorClass) return null
  const instance = new VendorClass()
  vendorInstances[vendorName] = instance
  return instance
}

// Re-export types for convenience
export * from './types'

// Register built-in vendors
import GoogleTtsVendor from './vendors/google.tts'
import QwenTtsVendor from './vendors/qwen.tts'
registerTTSVendor('google', GoogleTtsVendor)
registerTTSVendor('qwen', QwenTtsVendor)
