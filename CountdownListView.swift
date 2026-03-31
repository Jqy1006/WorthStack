import SwiftUI

struct CountdownListView: View {
    @EnvironmentObject var store: EventStore
    @State private var pinnedIds: Set<UUID> = []
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var now = Date()

    private var countdownTodos: [TodoEvent] {
        let items = store.todos.filter { $0.countdownEnabled && !$0.isConverted && $0.endDate != nil }
        return items.sorted { a, b in
            let aPinned = pinnedIds.contains(a.id)
            let bPinned = pinnedIds.contains(b.id)
            if aPinned != bPinned { return aPinned }
            let aRemain = (a.endDate ?? .distantFuture).timeIntervalSince(now)
            let bRemain = (b.endDate ?? .distantFuture).timeIntervalSince(now)
            return aRemain < bRemain
        }
    }

    var body: some View {
        ZStack {
            Morandi.background.ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Text("Countdown")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Morandi.textPrimary)
                    Spacer()
                }
                .padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 8)

                if countdownTodos.isEmpty {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "timer").font(.system(size: 36)).foregroundColor(Morandi.textSecondary.opacity(0.4))
                        Text("No countdown tasks.")
                            .foregroundColor(Morandi.textSecondary).font(.subheadline)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(countdownTodos) { todo in
                                countdownRow(todo)
                            }
                        }
                        .padding(.horizontal, 16).padding(.top, 8)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar { ToolbarItem(placement: .navigationBarLeading) { LightOrbBackButton() } }
        .onReceive(timer) { now = $0 }
    }

    @ViewBuilder
    private func countdownRow(_ todo: TodoEvent) -> some View {
        let remaining = (todo.endDate ?? Date()).timeIntervalSince(now)
        let isPinned = pinnedIds.contains(todo.id)
        let isOverdue = remaining <= 0

        HStack(spacing: 12) {
            // Pin button
            Button {
                withAnimation {
                    if isPinned { pinnedIds.remove(todo.id) }
                    else { pinnedIds.insert(todo.id) }
                }
            } label: {
                Image(systemName: isPinned ? "pin.fill" : "pin")
                    .font(.system(size: 14))
                    .foregroundColor(isPinned ? Morandi.purple : Morandi.textSecondary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(todo.title.isEmpty ? "Untitled" : todo.title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Morandi.textPrimary)
                    .lineLimit(1)
            }

            Spacer()

            Text(isOverdue ? "Overdue" : formatRemaining(remaining))
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                .foregroundColor(isOverdue ? Color.red.opacity(0.7) : Morandi.textPrimary)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Morandi.cardBg)
                .shadow(color: .black.opacity(0.03), radius: 6, y: 2)
        )
    }

    private func formatRemaining(_ secs: TimeInterval) -> String {
        let s = Int(secs)
        let d = s / 86400, h = (s % 86400) / 3600, m = (s % 3600) / 60, sec = s % 60
        if d > 0 { return String(format: "%dd %02dh %02dm", d, h, m) }
        return String(format: "%02d:%02d:%02d", h, m, sec)
    }
}
