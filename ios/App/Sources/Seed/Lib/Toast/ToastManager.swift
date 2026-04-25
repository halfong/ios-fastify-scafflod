import SwiftUI

struct ToastMessage: Equatable {
    let message: String
    let isError: Bool
    var duration: Double = 3
}

@MainActor
@Observable
final class ToastManager {
    static let shared = ToastManager()
    private init() {}

    var current: ToastMessage? = nil
    private(set) var layers: [UUID] = []
    private var dismissTask: Task<Void, Never>?

    func show(_ message: String, isError: Bool = false, duration: Double = 2.5) {
        dismissTask?.cancel()
        withAnimation { current = ToastMessage(message: message, isError: isError, duration: duration) }
        dismissTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
            guard !Task.isCancelled else { return }
            withAnimation { self.current = nil }
        }
    }

    func hide() {
        dismissTask?.cancel()
        withAnimation { current = nil }
    }

    func register(_ id: UUID) {
        layers.append(id)
    }

    func unregister(_ id: UUID) {
        layers.removeAll { $0 == id }
    }
}
