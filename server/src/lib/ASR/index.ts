import type { AsrVendor } from './types'

// Vendor class registry — register vendors with registerASRVendor() before use.
// Extension point: in your app, call registerASRVendor('myvendor', MyVendorClass)
// to add a vendor without modifying this file.
const vendorClasses: { [key: string]: new (config?: any) => AsrVendor } = {}

// Instance cache (one singleton per vendor name)
const vendorInstances: { [key: string]: AsrVendor } = {}

/**
 * Register an ASR vendor class by name.
 * Call this once at app startup before any getASRVendor() calls.
 */
export function registerASRVendor(name: string, VendorClass: new (config?: any) => AsrVendor): void {
  vendorClasses[name] = VendorClass
  delete vendorInstances[name] // clear cached instance on re-registration
}

/**
 * Get ASR vendor instance by name. Returns null if vendor not registered.
 * Instantiates with .env credentials on first call; subsequent calls return
 * the cached instance.
 */
export function getASRVendor(vendorName: string): AsrVendor | null {
  if (vendorInstances[vendorName]) {
    return vendorInstances[vendorName]
  }
  const VendorClass = vendorClasses[vendorName]
  if (!VendorClass) return null
  const instance = new VendorClass()
  vendorInstances[vendorName] = instance
  return instance
}

/**
 * Resolve the vendor name for a given model identifier string.
 * Returns null if no registered vendor declares that model.
 */
export function getVendorForModel(model: string): string | null {
  for (const [key, VendorClass] of Object.entries(vendorClasses)) {
    const models = (VendorClass as any).models as string[] | undefined
    if (models?.includes(model)) return key
  }
  return null
}

// Re-export types for convenience
export * from './types'

// Register built-in vendors
import TCloudAsrVendor from './vendors/tcloud.asr'
import ElevenLabsAsrVendor from './vendors/elevenlabs.asr'
registerASRVendor('tcloud', TCloudAsrVendor)
registerASRVendor('elevenlabs', ElevenLabsAsrVendor)
