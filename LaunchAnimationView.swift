import SwiftUI

struct LaunchAnimationView: View {
    let onFinish: () -> Void

    @State private var startTime: Date?
    @State private var finished = false

    private let duration: Double = 4.5

    // Monet-inspired blue palette (back to front, deeper to lighter)
    private let skyBlues: [(CGFloat, CGFloat, CGFloat)] = [
        (0.30, 0.45, 0.68),  // deep cerulean
        (0.42, 0.58, 0.78),  // cobalt
        (0.55, 0.70, 0.85),  // soft sky
        (0.72, 0.82, 0.93),  // pale blue
    ]

    // Meadow palette (back to front)
    private let meadowColors: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
        (0.38, 0.56, 0.42, 0.65),  // deep green
        (0.50, 0.68, 0.48, 0.55),  // vivid green
        (0.82, 0.74, 0.55, 0.30),  // yellow accent
        (0.60, 0.76, 0.58, 0.50),  // light green front
    ]

    var body: some View {
        TimelineView(.animation) { timeline in
            let elapsed = startTime.map { timeline.date.timeIntervalSince($0) } ?? 0
            let progress = min(elapsed / duration, 1.0)

            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height

                Canvas { ctx, _ in
                    // Background
                    ctx.fill(Path(CGRect(origin: .zero, size: CGSize(width: w, height: h))),
                             with: .color(Morandi.background))

                    let waveGrow = min(progress * 1.8, 1.0) // waves grow amplitude in first ~2.5s

                    // === SKY WAVES (4 layers, top area) ===
                    for layer in 0..<skyBlues.count {
                        let baseY = h * (0.06 + CGFloat(layer) * 0.04)
                        let amplitude = (6.0 + CGFloat(layer) * 3.0) * CGFloat(waveGrow)
                        let frequency = 1.8 + Double(layer) * 0.4
                        let phase = elapsed * (0.6 + Double(layer) * 0.15) + Double(layer) * 0.9
                        let opacity = 0.45 + Double(layer) * 0.08

                        var path = Path()
                        path.move(to: CGPoint(x: 0, y: 0))
                        for xp in stride(from: CGFloat(0), through: w, by: 2) {
                            let nx = Double(xp) / Double(w)
                            let y = baseY + amplitude * CGFloat(sin(nx * .pi * frequency + phase))
                            path.addLine(to: CGPoint(x: xp, y: y))
                        }
                        path.addLine(to: CGPoint(x: w, y: 0))
                        path.closeSubpath()

                        let rgb = skyBlues[layer]
                        ctx.fill(path, with: .color(Color(red: rgb.0, green: rgb.1, blue: rgb.2).opacity(opacity)))
                    }

                    // === RAINDROPS (5 drops falling from wave bottom) ===
                    let dropCount = 5
                    let dropXPositions: [CGFloat] = [0.12, 0.30, 0.50, 0.68, 0.85]
                    for i in 0..<dropCount {
                        let rainStart = 1.0 + Double(i) * 0.4
                        let rainDur = 2.2
                        let t = max(0, (elapsed - rainStart) / rainDur)
                        if t <= 0 { continue }

                        let xPos = w * dropXPositions[i]
                        let startY = h * 0.20
                        let endY = h * 0.55
                        let curY = startY + CGFloat(min(t, 1.0)) * (endY - startY)
                        let fade: Double = t > 0.85 ? max(0, 1.0 - (t - 0.85) / 0.3) : 1.0

                        // Teardrop shape
                        var drop = Path()
                        drop.addEllipse(in: CGRect(x: xPos - 2.5, y: curY - 2, width: 5, height: 9))
                        ctx.fill(drop, with: .color(Color(red: 0.35, green: 0.48, blue: 0.65).opacity(0.55 * fade)))
                    }

                    // === MEADOW WAVES (4 layers, bottom area, grow upward) ===
                    let meadowGrow = min(progress * 1.3, 1.0) // meadow grows in first ~3.5s
                    for layer in 0..<meadowColors.count {
                        let targetBaseY = h * (0.72 - CGFloat(layer) * 0.05)
                        let currentBaseY = h + (targetBaseY - h) * CGFloat(meadowGrow)
                        let amplitude = (5.0 + CGFloat(layer) * 2.5) * CGFloat(meadowGrow)
                        let frequency = 1.2 + Double(layer) * 0.35
                        let phase = elapsed * (0.4 + Double(layer) * 0.12) + Double(layer) * 1.3 + 3.0

                        var path = Path()
                        path.move(to: CGPoint(x: 0, y: h))
                        for xp in stride(from: CGFloat(0), through: w, by: 2) {
                            let nx = Double(xp) / Double(w)
                            let y = currentBaseY + amplitude * CGFloat(sin(nx * .pi * frequency + phase))
                            path.addLine(to: CGPoint(x: xp, y: y))
                        }
                        path.addLine(to: CGPoint(x: w, y: h))
                        path.closeSubpath()

                        let mc = meadowColors[layer]
                        ctx.fill(path, with: .color(Color(red: mc.0, green: mc.1, blue: mc.2).opacity(Double(mc.3))))
                    }
                }

                // Center text (script font, not obscured)
                VStack(spacing: 4) {
                    Text("Self-reflection guides action,")
                    Text("action defeats anxiety.")
                }
                .font(.custom("SnellRoundhand-Bold", size: 19))
                .multilineTextAlignment(.center)
                .foregroundColor(Morandi.textPrimary)
                .padding(.horizontal, 24).padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Morandi.background.opacity(0.92))
                )
                .opacity(progress > 0.35 ? min((progress - 0.35) / 0.2, 1) : 0)
                .scaleEffect(progress > 0.35 ? 1 : 0.88)
                .animation(.easeOut(duration: 0.5), value: progress > 0.35)
                .position(x: w / 2, y: h * 0.42)
            }
        }
        .background(Morandi.background)
        .ignoresSafeArea()
        .onAppear {
            startTime = Date()
            DispatchQueue.main.asyncAfter(deadline: .now() + duration + 0.6) {
                if !finished { finished = true; onFinish() }
            }
        }
    }
}
