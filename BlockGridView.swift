import SwiftUI

struct BlockGridView: View {
    let colors: [Color]
    let reversed: Bool  // true = right→left, bottom→up

    var body: some View {
        GeometryReader { geo in
            let count = colors.count
            if count > 0 {
                let layout = gridLayout(count: count, width: geo.size.width, height: geo.size.height)
                let cols = layout.0
                let size = layout.1
                let gap = layout.2
                let ordered = reversed ? Array(colors.reversed()) : colors

                Canvas { context, canvasSize in
                    for i in 0..<ordered.count {
                        let row = i / cols
                        let col = i % cols
                        let x: CGFloat
                        let y: CGFloat

                        if reversed {
                            x = canvasSize.width - CGFloat(col) * (size + gap) - size - gap / 2
                            y = canvasSize.height - CGFloat(row) * (size + gap) - size - gap / 2
                        } else {
                            x = CGFloat(col) * (size + gap) + gap / 2
                            y = CGFloat(row) * (size + gap) + gap / 2
                        }

                        let rect = CGRect(x: x, y: y, width: size, height: size)
                        let cornerSize = CGSize(width: max(2, size * 0.08), height: max(2, size * 0.08))
                        let path = Path(roundedRect: rect, cornerRadii: .init(topLeading: cornerSize.width, bottomLeading: cornerSize.width, bottomTrailing: cornerSize.width, topTrailing: cornerSize.width))

                        // Draw filled block with the color
                        context.fill(path, with: .color(ordered[i]))

                        // Draw a lighter overlay on edges for the radial gradient effect
                        let center = CGPoint(x: rect.midX, y: rect.midY)
                        let gradient = Gradient(colors: [.clear, .white.opacity(0.35)])
                        context.fill(path, with: .radialGradient(gradient, center: center, startRadius: size * 0.1, endRadius: size * 0.6))
                    }
                }
            }
        }
    }

    private func gridLayout(count: Int, width: CGFloat, height: CGFloat) -> (Int, CGFloat, CGFloat) {
        let gap: CGFloat = 2.0
        let aspect = width / max(height, 1)
        var cols = max(1, Int(ceil(sqrt(Double(count) * Double(aspect)))))
        let rows = Int(ceil(Double(count) / Double(cols)))

        let maxW = (width - CGFloat(cols + 1) * gap) / CGFloat(cols)
        let maxH = (height - CGFloat(rows + 1) * gap) / CGFloat(rows)
        var size = min(maxW, maxH)

        size = max(4, min(size, 60))
        cols = max(1, Int(floor((width - gap) / (size + gap))))

        return (cols, size, gap)
    }
}
