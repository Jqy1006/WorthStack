import SwiftUI
import UIKit

struct MainView: View {
    @EnvironmentObject var store: EventStore
    @ObservedObject var colorSettings = ColorSettings.shared
    @State private var editingTodo: TodoEvent?
    @State private var editingCompleted: CompletedEvent?
    @State private var isDeleteMode = false

    var body: some View {
        GeometryReader { geo in
            let isLandscape = geo.size.width > geo.size.height

            ZStack {
                Morandi.background.ignoresSafeArea()
                    .onTapGesture { if isDeleteMode { isDeleteMode = false } }

                if isLandscape {
                    HStack(spacing: 0) {
                        rainArea(height: geo.size.height, width: geo.size.width * 0.42)
                        Spacer(minLength: 0)
                        meadowArea(height: geo.size.height, width: geo.size.width * 0.42)
                    }
                } else {
                    VStack(spacing: 0) {
                        rainArea(height: geo.size.height * 0.42, width: geo.size.width)
                        Spacer(minLength: 0)
                        meadowArea(height: geo.size.height * 0.42, width: geo.size.width)
                    }
                }

                // Center Buttons
                HStack(spacing: 20) {
                    NavigationLink(value: AppRoute.control) {
                        cloudLabel(title: "Control", icon: "slider.horizontal.3")
                    }
                    NavigationLink(value: AppRoute.observe) {
                        cloudLabel(title: "Observe", icon: "eye")
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onChange(of: store.conversionAnimationTrigger) { _ in
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        }
        .onChange(of: store.reversionAnimationTrigger) { _ in
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        }
        .sheet(item: $editingTodo) { ev in
            NavigationStack { TodoEditView(event: ev, isNew: false).environmentObject(store) }
        }
        .sheet(item: $editingCompleted) { ev in
            NavigationStack { CompletedEditView(event: ev, isNew: false).environmentObject(store) }
        }
    }

    // MARK: - Rain of Tasks
    @ViewBuilder
    private func rainArea(height: CGFloat, width: CGFloat) -> some View {
        let items = activeTodos
        let count = items.count
        let layout = gridLayout(count: count, width: width, height: height)
        let rows = count > 0 ? Int(ceil(Double(count) / Double(layout.0))) : 0
        let bottomY = count > 0 ? CGFloat(rows - 1) * (layout.1 + layout.2) + layout.2 / 2 + layout.1 : 0

        ZStack {
            blockGrid(
                items: items.map { ($0.id, Morandi.blockColor(todo: $0)) },
                recentCount: min(5, items.count),
                reversed: false, width: width, height: height,
                onTap: { id in
                    if isDeleteMode { return }
                    if let todo = store.todos.first(where: { $0.id == id }) { editingTodo = todo }
                },
                onDelete: { id in store.removeTodo(id: id) }
            )
            Text("Rain of Tasks")
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(Morandi.textPrimary)
                .shadow(color: .white.opacity(0.8), radius: 4)
                .position(x: width / 2, y: bottomY + 16)
        }
        .frame(width: width, height: height)
    }

    // MARK: - Life's Meadow
    @ViewBuilder
    private func meadowArea(height: CGFloat, width: CGFloat) -> some View {
        let items = meadowItems
        let count = items.count
        let layout = gridLayout(count: count, width: width, height: height)
        let rows = count > 0 ? Int(ceil(Double(count) / Double(layout.0))) : 0
        let topY = count > 0 ? height - CGFloat(rows - 1) * (layout.1 + layout.2) - layout.1 - layout.2 / 2 : height

        ZStack {
            blockGrid(
                items: items,
                recentCount: min(5, items.count),
                reversed: true, width: width, height: height,
                onTap: { id in
                    if isDeleteMode { return }
                    if let ce = store.completed.first(where: { $0.id == id }) { editingCompleted = ce }
                },
                onDelete: { id in
                    if let ce = store.completed.first(where: { $0.id == id }) {
                        store.removeCompleted(ce)
                    } else if let ae = store.abandoned.first(where: { $0.id == id }) {
                        store.removeAbandoned(ae)
                    }
                }
            )
            Text("Life's Meadow")
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(Morandi.textPrimary)
                .shadow(color: .white.opacity(0.8), radius: 4)
                .position(x: width / 2, y: topY - 16)
        }
        .frame(width: width, height: height)
    }

    // MARK: - Block Grid (always ordered, independent sizing, recent-5 fixed)
    @ViewBuilder
    private func blockGrid(
        items: [(UUID, Color)],
        recentCount: Int,
        reversed: Bool,
        width: CGFloat, height: CGFloat,
        onTap: @escaping (UUID) -> Void,
        onDelete: @escaping (UUID) -> Void
    ) -> some View {
        let count = items.count
        if count > 0 {
            let layout = gridLayout(count: count, width: width, height: height)
            let cols = layout.0; let size = layout.1; let gap = layout.2
            // Fixed size for the most recent 5 items (initial size = capped at 36pt)
            let fixedSize: CGFloat = min(36, max(size, 16))
            let ordered = reversed ? Array(items.reversed()) : items
            // The recent items are the last `recentCount` in the original (non-reversed) order
            // In `ordered`, their indices depend on direction
            let recentIds: Set<UUID> = Set(items.suffix(recentCount).map { $0.0 })

            ZStack {
                Canvas { ctx, _ in
                    for i in 0..<ordered.count {
                        let col = i % cols; let row = i / cols
                        let isRecent = recentIds.contains(ordered[i].0)
                        let blockSize = isRecent ? fixedSize : size
                        let pos = blockPosition(col: col, row: row, size: size, gap: gap,
                                                width: width, height: height, reversed: reversed)
                        // Center the block if it's a different size
                        let offset = (size - blockSize) / 2
                        let rect = CGRect(x: pos.x + offset, y: pos.y + offset,
                                          width: blockSize, height: blockSize)
                        let cr = max(2, blockSize * 0.08)
                        let path = Path(roundedRect: rect, cornerRadius: cr)
                        ctx.fill(path, with: .color(ordered[i].1))
                        ctx.fill(path, with: .radialGradient(
                            Gradient(colors: [.clear, .white.opacity(0.3)]),
                            center: CGPoint(x: rect.midX, y: rect.midY),
                            startRadius: blockSize * 0.05, endRadius: blockSize * 0.55))
                    }
                }
                .frame(width: width, height: height)
                .contentShape(Rectangle())
                .onTapGesture { location in
                    if isDeleteMode { isDeleteMode = false; return }
                    for i in stride(from: ordered.count - 1, through: 0, by: -1) {
                        let col = i % cols; let row = i / cols
                        let pos = blockPosition(col: col, row: row, size: size, gap: gap,
                                                width: width, height: height, reversed: reversed)
                        if CGRect(x: pos.x, y: pos.y, width: size, height: size).contains(location) {
                            onTap(ordered[i].0); return
                        }
                    }
                }
                .onLongPressGesture(minimumDuration: 0.6) {
                    withAnimation(.easeInOut(duration: 0.2)) { isDeleteMode = true }
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }

                // Delete buttons
                if isDeleteMode {
                    ForEach(0..<ordered.count, id: \.self) { i in
                        let col = i % cols; let row = i / cols
                        let pos = blockPosition(col: col, row: row, size: size, gap: gap,
                                                width: width, height: height, reversed: reversed)
                        Button {
                            withAnimation(.easeOut(duration: 0.25)) { onDelete(ordered[i].0) }
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 0.96, green: 0.94, blue: 0.90))
                                    .frame(width: max(12, size * 0.4), height: max(12, size * 0.4))
                                    .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
                                Image(systemName: "xmark")
                                    .font(.system(size: max(6, size * 0.18), weight: .bold))
                                    .foregroundColor(.black.opacity(0.7))
                            }
                        }
                        .position(x: pos.x + size - 2, y: pos.y + 2)
                    }
                }
            }
            .frame(width: width, height: height)
        }
    }

    private func blockPosition(col: Int, row: Int, size: CGFloat, gap: CGFloat,
                                width: CGFloat, height: CGFloat, reversed: Bool) -> CGPoint {
        if reversed {
            return CGPoint(x: width - CGFloat(col) * (size + gap) - size - gap / 2,
                           y: height - CGFloat(row) * (size + gap) - size - gap / 2)
        } else {
            return CGPoint(x: CGFloat(col) * (size + gap) + gap / 2,
                           y: CGFloat(row) * (size + gap) + gap / 2)
        }
    }

    private func gridLayout(count: Int, width: CGFloat, height: CGFloat) -> (Int, CGFloat, CGFloat) {
        let gap: CGFloat = 1.5
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

    // MARK: - Data Helpers
    private var activeTodos: [TodoEvent] {
        store.todos.filter { !$0.isConverted }.sorted { $0.createdAt < $1.createdAt }
    }

    private var meadowItems: [(UUID, Color)] {
        let completed = store.completed.map { ($0.id, Morandi.blockColor(completed: $0), $0.createdAt) }
        let abandoned = store.abandoned.map { ($0.id, Morandi.blockColor(abandoned: $0), $0.createdAt) }
        return (completed + abandoned)
            .sorted { $0.2 < $1.2 }
            .map { ($0.0, $0.1) }
    }

    @ViewBuilder
    private func cloudLabel(title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon).font(.system(size: 15, weight: .medium))
            Text(title).font(.system(size: 16, weight: .semibold, design: .rounded))
        }
        .foregroundColor(Morandi.textPrimary)
        .padding(.horizontal, 22).padding(.vertical, 13)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 22).fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: 22)
                    .fill(LinearGradient(
                        colors: [.white.opacity(0.65), Morandi.cardBg.opacity(0.4), .white.opacity(0.25)],
                        startPoint: .topLeading, endPoint: .bottomTrailing))
                RoundedRectangle(cornerRadius: 22).stroke(.white.opacity(0.5), lineWidth: 1)
            })
        .shadow(color: Morandi.textSecondary.opacity(0.12), radius: 12, y: 4)
    }
}
