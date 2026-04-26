import Foundation
import AVFoundation
import CryptoKit

extension Data {
    var md5Hash: String {
        let digest = Insecure.MD5.hash(data: self)
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - Audio MD5 Utility

/// MD5 calculation utility for audio files (PCM-based for content deduplication)
/// This ensures consistent hashing regardless of file format or metadata changes
enum AudioMD5 {
    /// Computes PCM-based MD5 hash from audio content (metadata-agnostic)
    /// Falls back to file data hash if audio track cannot be read
    static func calculate(for url: URL) async -> String {
        guard FileManager.default.fileExists(atPath: url.path) else {
            print("[MD5] File does not exist: \(url.lastPathComponent)")
            return ""
        }
        
        // Try to read raw audio PCM data without metadata
        do {
            let asset = AVURLAsset(url: url)
            let reader = try AVAssetReader(asset: asset)
            
            let audioTracks = try await asset.loadTracks(withMediaType: .audio)
            guard let track = audioTracks.first else {
                // No audio track, fallback to file data
                print("[MD5] No audio track found, using file data hash: \(url.lastPathComponent)")
                let data = try? Data(contentsOf: url)
                return data?.md5Hash ?? ""
            }
            
            let output = AVAssetReaderTrackOutput(
                track: track,
                outputSettings: [
                    AVFormatIDKey: kAudioFormatLinearPCM,
                    AVLinearPCMBitDepthKey: 16,
                    AVLinearPCMIsFloatKey: false,
                    AVLinearPCMIsBigEndianKey: false,
                    AVLinearPCMIsNonInterleaved: false
                ]
            )
            reader.add(output)
            reader.startReading()
            
            // Calculate MD5 incrementally to avoid memory spike
            var hasher = Insecure.MD5()
            while let sampleBuffer = output.copyNextSampleBuffer() {
                if let blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer) {
                    let length = CMBlockBufferGetDataLength(blockBuffer)
                    var data = Data(count: length)
                    data.withUnsafeMutableBytes { bytes in
                        if let baseAddress = bytes.baseAddress {
                            CMBlockBufferCopyDataBytes(blockBuffer, atOffset: 0, dataLength: length, destination: baseAddress)
                        }
                    }
                    hasher.update(data: data)
                }
            }
            
            print("[MD5] Calculated PCM-based hash: \(url.lastPathComponent)")
            let digest = hasher.finalize()
            return digest.map { String(format: "%02x", $0) }.joined()
        } catch {
            // Fallback to file data hash if audio reading fails
            print("[MD5] PCM extraction failed, using file data hash: \(error.localizedDescription)")
            let data = try? Data(contentsOf: url)
            return data?.md5Hash ?? ""
        }
    }
}