import SwiftUI

struct ChartViews {
    // MARK: - Time Comparison Bar Chart
    struct TimeComparisonChart: View {
        let items: [(title: String, estimated: Double, actual: Double)]
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(0..<items.count, id: \.self) { i in
                    let item = items[i]
                    let maxVal = max(item.estimated, item.actual, 1)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.title).font(.caption).foregroundColor(Morandi.textPrimary).lineLimit(1)
                        barRow(label: "Est.", value: item.estimated, color: Morandi.lightBlue, maxVal: maxVal)
                        barRow(label: "Act.", value: item.actual, color: Morandi.lightGreen, maxVal: maxVal)
                    }
                }
            }
        }
        @ViewBuilder
        func barRow(label: String, value: Double, color: Color, maxVal: Double) -> some View {
            HStack(spacing: 6) {
                Text(label).font(.system(size: 10)).foregroundColor(Morandi.textSecondary).frame(width: 28, alignment: .trailing)
                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: 4).fill(color)
                        .frame(width: max(4, geo.size.width * CGFloat(value / maxVal)))
                }.frame(height: 14)
                Text(String(format: "%.0fm", value)).font(.system(size: 10)).foregroundColor(Morandi.textSecondary).frame(width: 32)
            }
        }
    }

    // MARK: - Value Comparison Chart (dot-based: 1 dot = 1 point, three rows per event)
    struct ValueComparisonChart: View {
        let items: [(title: String, objective: Double, subjective: Double, final_: Double)]
        var body: some View {
            VStack(alignment: .leading, spacing: 20) {
                // Legend
                HStack(spacing: 12) {
                    legendDot(color: Morandi.purple.opacity(0.75), text: "Objective")
                    legendDot(color: Morandi.darkBlue.opacity(0.75), text: "Subjective")
                    legendDot(color: Morandi.darkGreen.opacity(0.75), text: "Final")
                }.font(.caption2)

                ForEach(0..<items.count, id: \.self) { i in
                    let item = items[i]
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.title).font(.caption).foregroundColor(Morandi.textPrimary).lineLimit(1)
                            .padding(.bottom, 2)
                        // Three dot rows, same left start, no gap between them
                        dotRow(value: item.objective, color: Morandi.purple.opacity(0.65))
                        dotRow(value: item.subjective, color: Morandi.darkBlue.opacity(0.65))
                        dotRow(value: item.final_, color: Morandi.darkGreen.opacity(0.65))
                    }
                }
            }
        }

        @ViewBuilder
        func dotRow(value: Double, color: Color) -> some View {
            HStack(spacing: 3) {
                ForEach(0..<Int(max(0, min(10, round(value)))), id: \.self) { _ in
                    Circle().fill(color).frame(width: 8, height: 8)
                }
            }
            .frame(height: 10)
        }

        @ViewBuilder
        func legendDot(color: Color, text: String) -> some View {
            HStack(spacing: 4) {
                Circle().fill(color).frame(width: 8, height: 8)
                Text(text).foregroundColor(Morandi.textSecondary)
            }
        }
    }

    // MARK: - Time vs Final Value Chart
    struct TimeValueChart: View {
        let items: [(title: String, duration: Double, finalScore: Double)]
        var body: some View {
            let maxDur = items.map(\.duration).max() ?? 1
            VStack(alignment: .leading, spacing: 10) {
                ForEach(0..<items.count, id: \.self) { i in
                    let item = items[i]
                    VStack(alignment: .leading, spacing: 3) {
                        Text(item.title).font(.caption).foregroundColor(Morandi.textPrimary).lineLimit(1)
                        GeometryReader { geo in
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Morandi.greenFor(score: item.finalScore))
                                .frame(width: max(8, geo.size.width * CGFloat(item.duration / max(maxDur, 1))))
                        }.frame(height: 18)
                    }
                }
            }
        }
    }
}
