import SwiftUI

// MARK: - User Color Settings (persisted to UserDefaults)
class ColorSettings: ObservableObject, @unchecked Sendable {
    static let shared = ColorSettings()

    @Published var todoColorRGB: (CGFloat, CGFloat, CGFloat) {
        didSet { save() }
    }
    @Published var completedColorRGB: (CGFloat, CGFloat, CGFloat) {
        didSet { save() }
    }

    var todoHighRGB: (CGFloat, CGFloat, CGFloat) {
        (min(1, todoColorRGB.0 + 0.35), min(1, todoColorRGB.1 + 0.35), min(1, todoColorRGB.2 + 0.35))
    }
    var completedHighRGB: (CGFloat, CGFloat, CGFloat) {
        (min(1, completedColorRGB.0 + 0.35), min(1, completedColorRGB.1 + 0.35), min(1, completedColorRGB.2 + 0.35))
    }

    private init() {
        todoColorRGB = Self.loadRGB(key: "todoColor") ?? Morandi.darkBlueRGB
        completedColorRGB = Self.loadRGB(key: "completedColor") ?? Morandi.darkGreenRGB
    }

    func reset() {
        todoColorRGB = Morandi.darkBlueRGB
        completedColorRGB = Morandi.darkGreenRGB
    }

    private func save() {
        UserDefaults.standard.set([todoColorRGB.0, todoColorRGB.1, todoColorRGB.2], forKey: "todoColor")
        UserDefaults.standard.set([completedColorRGB.0, completedColorRGB.1, completedColorRGB.2], forKey: "completedColor")
    }

    private static func loadRGB(key: String) -> (CGFloat, CGFloat, CGFloat)? {
        guard let arr = UserDefaults.standard.array(forKey: key) as? [Double], arr.count == 3 else { return nil }
        return (CGFloat(arr[0]), CGFloat(arr[1]), CGFloat(arr[2]))
    }
}

// MARK: - Morandi Color Palette (Fresh, translucent feel)
struct Morandi {
    static let darkBlueRGB:    (CGFloat, CGFloat, CGFloat) = (0.35, 0.48, 0.65)
    static let lightBlueRGB:   (CGFloat, CGFloat, CGFloat) = (0.72, 0.84, 0.93)
    static let darkGreenRGB:   (CGFloat, CGFloat, CGFloat) = (0.38, 0.56, 0.42)
    static let lightGreenRGB:  (CGFloat, CGFloat, CGFloat) = (0.74, 0.88, 0.77)
    static let muddyYellowRGB: (CGFloat, CGFloat, CGFloat) = (0.82, 0.74, 0.55)
    static let muddyBrownRGB:  (CGFloat, CGFloat, CGFloat) = (0.66, 0.59, 0.49)
    static let purpleRGB:      (CGFloat, CGFloat, CGFloat) = (0.60, 0.50, 0.70)
    static let darkPurpleRGB:  (CGFloat, CGFloat, CGFloat) = (0.48, 0.40, 0.62)
    static let lightPurpleRGB: (CGFloat, CGFloat, CGFloat) = (0.78, 0.72, 0.86)

    static let darkBlue    = color(darkBlueRGB)
    static let lightBlue   = color(lightBlueRGB)
    static let darkGreen   = color(darkGreenRGB)
    static let lightGreen  = color(lightGreenRGB)
    static let muddyYellow = color(muddyYellowRGB)
    static let muddyBrown  = color(muddyBrownRGB)
    static let purple      = color(purpleRGB)
    static let darkPurple  = color(darkPurpleRGB)
    static let lightPurple = color(lightPurpleRGB)

    static let background    = Color(red: 0.97, green: 0.96, blue: 0.93)
    static let cardBg        = Color(red: 0.99, green: 0.98, blue: 0.96)
    static let textPrimary   = Color(red: 0.26, green: 0.27, blue: 0.30)
    static let textSecondary = Color(red: 0.56, green: 0.57, blue: 0.58)

    // Extended Morandi palette for color picker
    static let allPaletteColors: [(String, (CGFloat, CGFloat, CGFloat))] = [
        ("Dark Blue", darkBlueRGB), ("Light Blue", lightBlueRGB),
        ("Dark Green", darkGreenRGB), ("Light Green", lightGreenRGB),
        ("Muddy Yellow", muddyYellowRGB), ("Muddy Brown", muddyBrownRGB),
        ("Purple", purpleRGB), ("Dark Purple", darkPurpleRGB), ("Light Purple", lightPurpleRGB),
        ("Mist Blue", (0.45, 0.58, 0.72)), ("Dusty Blue", (0.55, 0.65, 0.78)),
        ("Sage", (0.52, 0.62, 0.50)), ("Olive", (0.55, 0.58, 0.42)),
        ("Warm Gray", (0.68, 0.65, 0.62)), ("Dusty Pink", (0.78, 0.62, 0.65)),
        ("Rose Gray", (0.72, 0.55, 0.58)), ("Camel", (0.72, 0.62, 0.50)),
        ("Dark Cyan", (0.35, 0.55, 0.55)), ("Red Bean", (0.68, 0.50, 0.52)),
        ("Ash Green", (0.58, 0.68, 0.58)),
    ]

    static func color(_ rgb: (CGFloat, CGFloat, CGFloat)) -> Color {
        Color(red: rgb.0, green: rgb.1, blue: rgb.2)
    }

    static func lerp(_ a: (CGFloat, CGFloat, CGFloat), _ b: (CGFloat, CGFloat, CGFloat), t: CGFloat) -> Color {
        color((a.0 + t * (b.0 - a.0), a.1 + t * (b.1 - a.1), a.2 + t * (b.2 - a.2)))
    }

    static func lerpRGB(_ a: (CGFloat, CGFloat, CGFloat), _ b: (CGFloat, CGFloat, CGFloat), t: CGFloat) -> (CGFloat, CGFloat, CGFloat) {
        (a.0 + t * (b.0 - a.0), a.1 + t * (b.1 - a.1), a.2 + t * (b.2 - a.2))
    }

    static func blueFor(score: Double) -> Color {
        let s = ColorSettings.shared
        return lerp(s.todoColorRGB, s.todoHighRGB, t: CGFloat(max(0, min(1, (score - 1) / 9.0))))
    }
    static func greenFor(score: Double) -> Color {
        let s = ColorSettings.shared
        return lerp(s.completedColorRGB, s.completedHighRGB, t: CGFloat(max(0, min(1, (score - 1) / 9.0))))
    }
    static func purpleFor(score: Double) -> Color {
        lerp(darkPurpleRGB, lightPurpleRGB, t: CGFloat(max(0, min(1, (score - 1) / 9.0))))
    }

    static func blockColor(todo: TodoEvent) -> Color { blueFor(score: todo.subjectiveScore) }
    static func blockColor(completed: CompletedEvent) -> Color { greenFor(score: completed.finalScore) }
    static func blockColor(abandoned: AbandonedEvent) -> Color {
        abandoned.abandonType == .activeAbandon ? muddyYellow : muddyBrown
    }

    static func lighten(_ rgb: (CGFloat, CGFloat, CGFloat), by amount: CGFloat = 0.15) -> Color {
        color((min(1, rgb.0 + amount), min(1, rgb.1 + amount), min(1, rgb.2 + amount)))
    }
}

// MARK: - Light Orb Back Button
struct LightOrbBackButton: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        Button { dismiss() } label: {
            ZStack {
                Circle()
                    .fill(RadialGradient(
                        colors: [.white.opacity(0.95), Morandi.lightBlue.opacity(0.3), .clear],
                        center: .center, startRadius: 2, endRadius: 22))
                    .frame(width: 44, height: 44)
                    .shadow(color: Morandi.lightBlue.opacity(0.5), radius: 10)
                Image(systemName: "house.fill")
                    .font(.system(size: 15)).foregroundColor(Morandi.textPrimary)
            }
        }
    }
}

// MARK: - Cloud Gradient Button
struct CloudButton: View {
    let title: String; let systemIcon: String; let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemIcon).font(.system(size: 16, weight: .medium))
                Text(title).font(.system(size: 17, weight: .semibold, design: .rounded))
            }
            .foregroundColor(Morandi.textPrimary)
            .padding(.horizontal, 24).padding(.vertical, 14)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 22).fill(.ultraThinMaterial)
                    RoundedRectangle(cornerRadius: 22)
                        .fill(LinearGradient(
                            colors: [.white.opacity(0.65), Morandi.cardBg.opacity(0.45), .white.opacity(0.25)],
                            startPoint: .topLeading, endPoint: .bottomTrailing))
                    RoundedRectangle(cornerRadius: 22).stroke(.white.opacity(0.5), lineWidth: 1)
                })
            .shadow(color: Morandi.textSecondary.opacity(0.12), radius: 12, y: 4)
        }
    }
}

// MARK: - Color Score Slider (with glass effect)
struct ColorScoreSlider: View {
    @Binding var score: Double
    let lowColor: Color
    let highColor: Color
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label).font(.subheadline).foregroundColor(Morandi.textSecondary)
                Spacer()
                Text(String(format: "%.0f", score))
                    .font(.subheadline.monospacedDigit()).foregroundColor(Morandi.textPrimary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.ultraThinMaterial)
                        .frame(height: 34)
                    RoundedRectangle(cornerRadius: 10)
                        .fill(LinearGradient(
                            colors: [lowColor, highColor],
                            startPoint: .leading, endPoint: .trailing))
                        .frame(height: 34)
                        .opacity(0.80)
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.white.opacity(0.45), lineWidth: 1)
                        .frame(height: 34)
                    Circle()
                        .fill(.white)
                        .frame(width: 30, height: 30)
                        .shadow(color: .black.opacity(0.15), radius: 4, y: 1)
                        .overlay(
                            Circle().fill(
                                LinearGradient(colors: [lowColor.opacity(0.3), highColor.opacity(0.3)],
                                               startPoint: .leading, endPoint: .trailing))
                                .frame(width: 20, height: 20)
                        )
                        .offset(x: CGFloat((score - 1) / 9.0) * (geo.size.width - 30))
                        .gesture(DragGesture(minimumDistance: 0).onChanged { v in
                            let t = min(max(v.location.x / geo.size.width, 0), 1)
                            score = round((1 + t * 9) * 10) / 10
                        })
                }
            }
            .frame(height: 34)
        }
    }
}

// MARK: - Collapsible Section
struct CollapsibleSection<Content: View>: View {
    let title: String
    @State private var expanded = true
    @ViewBuilder let content: () -> Content
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.25)) { expanded.toggle() }
            } label: {
                HStack {
                    Text(title).font(.headline).foregroundColor(Morandi.textPrimary)
                    Spacer()
                    Image(systemName: expanded ? "chevron.up" : "chevron.down")
                        .font(.caption).foregroundColor(Morandi.textSecondary)
                }
                .padding(.vertical, 12)
            }
            if expanded { content() }
        }
    }
}
