import SwiftUI

// MARK: - Confetti

enum ConfettiMode {
    /// Falls once and stops.
    case once
    /// Loops forever.
    case infinity
}

struct ConfettiView: View {
    /// How many particles to show (density).
    var density: Int = 50
    /// Base size of each particle in points (actual size is ±30% of this).
    var size: CGFloat = 8
    /// Fall speed multiplier — 1 is normal, 2 is twice as fast.
    var speed: Double = 1
    /// Whether to loop forever or fall once.
    var mode: ConfettiMode = .infinity

    private var particles: [ConfettiParticle] {
        let colors: [Color] = [
            .red, .orange, .yellow, .green, .blue,
            .purple, .pink, .cyan, .mint, .indigo
        ]
        // Base fall duration at speed = 1 is 2.5–4.5 s; divide by speed to go faster.
        let baseDurationRange: ClosedRange<Double> = (2.5 / speed)...(4.5 / speed)
        let maxDelay: Double = mode == .once ? 3.5 / speed : 3.5

        return (0..<density).map { _ in
            ConfettiParticle(
                x: CGFloat.random(in: 0...1),
                color: colors.randomElement()!,
                size: size * CGFloat.random(in: 0.7...1.3),
                initialRotation: Double.random(in: 0...360),
                rotationDelta: Double.random(in: 180...540) * (Bool.random() ? 1 : -1),
                delay: Double.random(in: 0...maxDelay),
                duration: Double.random(in: baseDurationRange),
                shape: ConfettiShape.allCases.randomElement()!,
                aspectRatio: CGFloat.random(in: 0.5...1.5),
                repeats: mode == .infinity
            )
        }
    }

    var body: some View {
        GeometryReader { geo in
            ForEach(particles) { p in
                ConfettiBit(particle: p, containerHeight: geo.size.height)
                    .position(x: p.x * geo.size.width, y: 0)
            }
        }
        .allowsHitTesting(false)
        .clipped()
    }
}

// MARK: - Particle model

private enum ConfettiShape: CaseIterable {
    case circle, rectangle, diamond
}

private struct ConfettiParticle: Identifiable {
    let id = UUID()
    let x: CGFloat
    let color: Color
    let size: CGFloat
    let initialRotation: Double
    let rotationDelta: Double
    let delay: Double
    let duration: Double
    let shape: ConfettiShape
    let aspectRatio: CGFloat
    let repeats: Bool
}

// MARK: - Single bit

private struct ConfettiBit: View {
    let particle: ConfettiParticle
    let containerHeight: CGFloat

    @State private var isAnimating = false

    var body: some View {
        particleShape
            .fill(particle.color.opacity(0.88))
            .frame(
                width: particle.size,
                height: particle.size * particle.aspectRatio
            )
            .rotationEffect(.degrees(
                isAnimating
                    ? particle.initialRotation + particle.rotationDelta
                    : particle.initialRotation
            ))
            .offset(y: isAnimating ? containerHeight + 40 : -20)
            .onAppear {
                let base = Animation.linear(duration: particle.duration).delay(particle.delay)
                let anim = particle.repeats ? base.repeatForever(autoreverses: false) : base
                withAnimation(anim) { isAnimating = true }
            }
    }

    private var particleShape: AnyShape {
        switch particle.shape {
        case .circle:    AnyShape(Circle())
        case .rectangle: AnyShape(Rectangle())
        case .diamond:   AnyShape(DiamondShape())
        }
    }
}

// MARK: - Diamond helper

private struct DiamondShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to:    CGPoint(x: rect.midX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        p.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        p.closeSubpath()
        return p
    }
}
