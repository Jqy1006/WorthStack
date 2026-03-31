import SwiftUI

struct CompletedListView: View {
    @EnvironmentObject var store: EventStore
    @State private var editingEvent: CompletedEvent?
    @State private var showNew = false

    var body: some View {
        ZStack {
            Morandi.background.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Text("Things Completed")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Morandi.textPrimary)
                    Spacer()
                    Button { showNew = true } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 26))
                            .foregroundColor(Morandi.darkGreen)
                    }
                }
                .padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 8)

                if store.completed.isEmpty {
                    Spacer()
                    Text("No completed events yet.")
                        .foregroundColor(Morandi.textSecondary).font(.subheadline)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(store.completed) { ev in
                                completedRow(ev)
                            }
                        }
                        .padding(.horizontal, 16).padding(.top, 8)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar { ToolbarItem(placement: .navigationBarLeading) { LightOrbBackButton() } }
        .sheet(isPresented: $showNew) {
            NavigationStack {
                CompletedEditView(event: CompletedEvent(), isNew: true)
                    .environmentObject(store)
            }
        }
        .sheet(item: $editingEvent) { ev in
            NavigationStack {
                CompletedEditView(event: ev, isNew: false)
                    .environmentObject(store)
            }
        }
    }

    @ViewBuilder
    private func completedRow(_ ev: CompletedEvent) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 4)
                .fill(RadialGradient(
                    colors: [Morandi.blockColor(completed: ev), Morandi.blockColor(completed: ev).opacity(0.5)],
                    center: .center, startRadius: 2, endRadius: 18))
                .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 3) {
                Text(ev.title.isEmpty ? "Untitled" : ev.title)
                    .font(.system(size: 15, weight: .medium)).foregroundColor(Morandi.textPrimary).lineLimit(1)
                Text(String(format: "%.0f min • Value: %.0f", ev.actualDurationMinutes, ev.finalScore))
                    .font(.caption2).foregroundColor(Morandi.textSecondary)
            }

            Spacer()

            Button { editingEvent = ev } label: {
                Image(systemName: "pencil")
                    .font(.system(size: 14)).foregroundColor(Morandi.textPrimary)
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 14).fill(Morandi.cardBg)
            .shadow(color: .black.opacity(0.03), radius: 6, y: 2))
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                withAnimation { store.removeCompleted(ev) }
            } label: { Label("Delete", systemImage: "trash") }
        }
    }
}
