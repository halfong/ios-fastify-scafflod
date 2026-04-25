import type { LLMVendor } from './types'

// Vendor class registry — register vendors with registerLLMVendor() before use.
// Extension point: in your app, call registerLLMVendor('myvendor', MyVendorClass)
// to add a vendor without modifying this file.
const vendorClasses: { [key: string]: new (config?: any) => LLMVendor } = {}

// Instance cache (one singleton per vendor name)
const vendorInstances: { [key: string]: LLMVendor } = {}

/**
 * Register an LLM vendor class by name.
 * Call this once at app startup before any getLLMVendor() calls.
 */
export function registerLLMVendor(name: string, VendorClass: new (config?: any) => LLMVendor): void {
  vendorClasses[name] = VendorClass
  delete vendorInstances[name]
}

/**
 * Get LLM vendor instance by name. Returns null if vendor not registered.
 * Instantiates with .env credentials on first call; subsequent calls return
 * the cached instance.
 */
export function getLLMVendor(vendorName: string): LLMVendor | null {
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
import LLMGemini from './vendors/gemini.llm'
import LLMQianwen from './vendors/qianwen.llm'
registerLLMVendor('gemini', LLMGemini)
registerLLMVendor('qwen', LLMQianwen)
