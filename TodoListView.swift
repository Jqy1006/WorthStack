import SwiftUI

struct TodoListView: View {
    @EnvironmentObject var store: EventStore
    @State private var editingEvent: TodoEvent?
    @State private var showNew = false
    @State private var convertedCompleted: CompletedEvent?

    private var activeTodos: [TodoEvent] {
        store.todos.filter { !$0.isConverted }
    }

    var body: some View {
        ZStack {
            Morandi.background.ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Text("Things To Do")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Morandi.textPrimary)
                    Spacer()
                    Button { showNew = true } label: {
                        Image(systemName: "plus.circle.fill").font(.system(size: 26)).foregroundColor(Morandi.darkBlue)
                    }
                }
                .padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 8)

                if activeTodos.isEmpty {
                    Spacer()
                    Text("No tasks yet. Tap + to add one.").foregroundColor(Morandi.textSecondary).font(.subheadline)
                    Spacer()
                } else {
                    List {
                        ForEach(activeTodos) { todo in
                            todoRow(todo)
                                .listRowInsets(EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        store.abandonTodo(todo, type: .passiveAbandon)
                                        triggerHaptic()
                                    } label: { Label("Passive Abandon", systemImage: "xmark.shield") }
                                    .tint(Morandi.muddyBrown)

                                    Button {
                                        store.abandonTodo(todo, type: .activeAbandon)
                                        triggerHaptic()
                                    } label: { Label("Active Abandon", systemImage: "minus.circle") }
                                    .tint(Morandi.muddyYellow)
                                }
                                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                    Button {
                                        let ce = store.makeCompletedEvent(from: todo)
                                        store.completeTodo(todo, completed: ce)
                                        triggerHaptic()
                                        convertedCompleted = ce
                                    } label: { Label("Complete", systemImage: "checkmark.circle") }
                                    .tint(Morandi.darkGreen)
                                }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar { ToolbarItem(placement: .navigationBarLeading) { LightOrbBackButton() } }
        .sheet(isPresented: $showNew) {
            NavigationStack { TodoEditView(event: TodoEvent(), isNew: true).environmentObject(store) }
        }
        .sheet(item: $editingEvent) { ev in
            NavigationStack { TodoEditView(event: ev, isNew: false).environmentObject(store) }
        }
        .sheet(item: $convertedCompleted) { ce in
            NavigationStack { CompletedEditView(event: ce, isNew: false).environmentObject(store) }
        }
    }

    @ViewBuilder
    private func todoRow(_ todo: TodoEvent) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 4)
                .fill(RadialGradient(
                    colors: [Morandi.blockColor(todo: todo), Morandi.blockColor(todo: todo).opacity(0.5)],
                    center: .center, startRadius: 2, endRadius: 18))
                .frame(width: 36, height: 36)
            VStack(alignment: .leading, spacing: 3) {
                Text(todo.title.isEmpty ? "Untitled" : todo.title)
                    .font(.system(size: 15, weight: .medium)).foregroundColor(Morandi.textPrimary).lineLimit(1)
                if let s = todo.startDate, let e = todo.endDate {
                    let f = DateFormatter(); let _ = (f.dateStyle = .short, f.timeStyle = .short)
                    Text("\(f.string(from: s)) → \(f.string(from: e))")
                        .font(.caption2).foregroundColor(Morandi.textSecondary)
                }
            }
            Spacer()
            if todo.countdownEnabled {
                Image(systemName: "timer").font(.caption).foregroundColor(Morandi.purple)
            }
            Button { editingEvent = todo } label: {
                Image(systemName: "pencil").font(.system(size: 14)).foregroundColor(Morandi.textPrimary)
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 14).fill(Morandi.cardBg)
            .shadow(color: .black.opacity(0.03), radius: 6, y: 2))
    }

    private func triggerHaptic() {
        let gen = UIImpactFeedbackGenerator(style: .soft)
        gen.impactOccurred()
    }
}
