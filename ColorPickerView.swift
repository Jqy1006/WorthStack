import SwiftUI

struct ColorPickerView: View {
    @ObservedObject private var settings = ColorSettings.shared
    @State private var selectedTodo: (CGFloat, CGFloat, CGFloat)?
    @State private var selectedCompleted: (CGFloat, CGFloat, CGFloat)?

    var body: some View {
        ZStack {
            Morandi.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    Text("Color")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(Morandi.textPrimary)

                    // MARK: - Todo color section
                    sectionCard(
                        title: "Rain of Tasks",
                        subtitle: "Select a color for pending events",
                        selected: selectedTodo ?? settings.todoColorRGB,
                        onSelect: { rgb in
                            selectedTodo = rgb
                            settings.todoColorRGB = rgb
                        },
                        previewLow: settings.todoColorRGB,
                        previewHigh: settings.todoHighRGB
                    )

                    // MARK: - Completed color section
                    sectionCard(
                        title: "Life's Meadow",
                        subtitle: "Select a color for completed events",
                        selected: selectedCompleted ?? settings.completedColorRGB,
                        onSelect: { rgb in
                            selectedCompleted = rgb
                            settings.completedColorRGB = rgb
                        },
                        previewLow: settings.completedColorRGB,
                        previewHigh: settings.completedHighRGB
                    )

                    // MARK: - Reset button
                    Button {
                        settings.reset()
                        selectedTodo = nil
                        selectedCompleted = nil
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 14, weight: .medium))
                            Text("Reset to Default")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                        }
                        .foregroundColor(Morandi.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Morandi.cardBg)
                                .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
                        )
                    }
                }
                .padding(20)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar { ToolbarItem(placement: .navigationBarLeading) { LightOrbBackButton() } }
        .onAppear {
            selectedTodo = settings.todoColorRGB
            selectedCompleted = settings.completedColorRGB
        }
    }

    @ViewBuilder
    private func sectionCard(
        title: String,
        subtitle: String,
        selected: (CGFloat, CGFloat, CGFloat),
        onSelect: @escaping ((CGFloat, CGFloat, CGFloat)) -> Void,
        previewLow: (CGFloat, CGFloat, CGFloat),
        previewHigh: (CGFloat, CGFloat, CGFloat)
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(Morandi.textPrimary)
            Text(subtitle)
                .font(.system(size: 13))
                .foregroundColor(Morandi.textSecondary)

            // Palette grid
            let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 5)
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(Morandi.allPaletteColors, id: \.0) { name, rgb in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { onSelect(rgb) }
                    } label: {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Morandi.color(rgb))
                            .frame(height: 44)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(.white, lineWidth: rgbMatch(selected, rgb) ? 3 : 0)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Morandi.textPrimary.opacity(0.2), lineWidth: rgbMatch(selected, rgb) ? 1 : 0)
                                    .padding(2)
                            )
                            .shadow(color: rgbMatch(selected, rgb) ? .white.opacity(0.6) : .clear, radius: 4)
                    }
                }
            }

            // Preview gradient strip
            VStack(alignment: .leading, spacing: 6) {
                Text("Score gradient preview")
                    .font(.system(size: 12))
                    .foregroundColor(Morandi.textSecondary)
                HStack(spacing: 2) {
                    ForEach(1...10, id: \.self) { i in
                        let t = CGFloat(i - 1) / 9.0
                        let rgb = Morandi.lerpRGB(previewLow, previewHigh, t: t)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Morandi.color(rgb))
                            .frame(height: 28)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Morandi.cardBg)
                .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
        )
    }

    private func rgbMatch(_ a: (CGFloat, CGFloat, CGFloat), _ b: (CGFloat, CGFloat, CGFloat)) -> Bool {
        abs(a.0 - b.0) < 0.01 && abs(a.1 - b.1) < 0.01 && abs(a.2 - b.2) < 0.01
    }
}
