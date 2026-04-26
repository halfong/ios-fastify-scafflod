import SwiftUI
// import FirebaseAnalytics

/**
 * @important shoud add to ScrollView to globally disable the 150ms delay for all taps in this hierarchy, otherwise the tap effect will be delayed and feel unresponsive.
 * ```swift
 .onAppear {
     UIScrollView.appearance().delaysContentTouches = false
 }
 ```
 */
enum TapEffect {
    case scale
    case opacity
    case background(Color)
    case backgroundStyle(AnyShapeStyle)
    case none
}

struct TapEventLog {
    let name: String
    let parameters: [String: Any]
    func log() {
      print("Please setup FirebaseAnalytics")
        // Analytics.logEvent("tap_\(name)", parameters: parameters)
    }
}

struct TapModifier: ViewModifier {
    @State private var isExecuting = false

    let onTap: (() async -> Void)?
    let effect: TapEffect
    let stopPropagate: Bool
    let logEvent: TapEventLog?
    
    init(effect: TapEffect = .scale, stopPropagate: Bool = false, logEvent: TapEventLog? = nil, onTap: (() async -> Void)? = nil) {
        self.effect = effect
        self.stopPropagate = stopPropagate
        self.onTap = onTap
        self.logEvent = logEvent
    }
    
    func body(content: Content) -> some View {
        return Button {
            guard !isExecuting else { return }
            logEvent?.log()
            isExecuting = true
            Task { await onTap?(); isExecuting = false }
        } label: { content }
        .buttonStyle( EffectButtonStyle(effect: effect) )
        // // Use a Group instead of erasing to AnyView; keeps view identity and is simpler.
        // return Group {
        //     if stopPropagate {
        //         button
        //     } else {
        //         // Allow parent gestures to handle taps as well (similar to previous simultaneousGesture)
        //         button.simultaneousGesture(TapGesture().onEnded { })
        //     }
        // }
    }

    // ButtonStyle that applies tap effects (concise, press-only)
    private struct EffectButtonStyle: ButtonStyle {
        let effect: TapEffect
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .brightness(configuration.isPressed ? -0.1 : 0)
                .contentShape(Rectangle())
                .modifier(EffectModifier(effect: effect, isPressing: configuration.isPressed, isReleased: false))
                .animation(.interactiveSpring(response: 0.2, dampingFraction: 0.8), value: configuration.isPressed)
        }
    } 
}

// Helper modifier to apply the specific effect
struct EffectModifier: ViewModifier {
    let effect: TapEffect
    let isPressing: Bool
    let isReleased: Bool

    func body(content: Content) -> some View {
        let pressedOpacity = isPressing ? 0.5 : 1.0
        switch effect {
        case .scale:
            content.scaleEffect(isPressing ? 0.9 : (isReleased ? 1.07 : 1.0))
        case .opacity:
            content.opacity(pressedOpacity)
        case .background(let color):
            content.background(isPressing ? color : Color.clear).opacity(pressedOpacity)
        case .backgroundStyle(let style):
            content.background(isPressing ? style : AnyShapeStyle(Color.clear)).opacity(pressedOpacity)
        case .none:
            content
        }
    }
}

extension View {
    func tap(effect: TapEffect = .scale, stopPropagate: Bool = false, logEvent: TapEventLog? = nil, onTap: (() async -> Void)? = nil) -> some View {
        modifier(TapModifier(effect: effect, stopPropagate: stopPropagate, logEvent: logEvent, onTap: onTap))
    }
    
    func tapScale(stopPropagate: Bool = false, logEvent: TapEventLog? = nil, onTap: (() async -> Void)? = nil) -> some View {
        tap(effect: .scale, stopPropagate: stopPropagate, logEvent: logEvent, onTap: onTap)
    }
    
    func tapOpacity(stopPropagate: Bool = false, logEvent: TapEventLog? = nil, onTap: (() async -> Void)? = nil) -> some View {
        tap(effect: .opacity, stopPropagate: stopPropagate, logEvent: logEvent, onTap: onTap)
    }

    func tapBackground(color: Color = .black.opacity(0.2), stopPropagate: Bool = false, logEvent: TapEventLog? = nil, onTap: (() async -> Void)? = nil) -> some View {
        tap(effect: .background(color), stopPropagate: stopPropagate, logEvent: logEvent, onTap: onTap)
    }
    
    func tapBackgroundStyle(style: AnyShapeStyle, stopPropagate: Bool = false, logEvent: TapEventLog? = nil, onTap: (() async -> Void)? = nil) -> some View {
        tap(effect: .backgroundStyle(style), stopPropagate: stopPropagate, logEvent: logEvent, onTap: onTap)
    }
    
    func tapNone(stopPropagate: Bool = false, logEvent: TapEventLog? = nil, onTap: (() async -> Void)? = nil) -> some View {
        tap(effect: .none, stopPropagate: stopPropagate, logEvent: logEvent, onTap: onTap)
    }
} 
