import SwiftUI

struct ObserveView: View {
    @EnvironmentObject var store: EventStore
    @State private var timeShowAll = false
    @State private var valueShowAll = false
    @State private var timeValueShowAll = false
    @State private var notesShowAll = false
    @State private var editingTodo: TodoEvent?
    @State private var editingCompleted: CompletedEvent?

    private let initialCount = 5

    private var matchedData: [(title: String, estimated: Double, actual: Double,
                               objective: Double, subjective: Double, final_: Double)] {
        store.completed.map { c in
            let todo = store.todos.first(where: { $0.id == c.sourceEventId })
            let subj = todo?.subjectiveScore ?? c.objectiveScore
            return (title: c.title,
                    estimated: c.estimatedDurationMinutes,
                    actual: c.actualDurationMinutes,
                    objective: c.objectiveScore,
                    subjective: subj,
                    final_: c.finalScore)
        }
    }

    private var allCompleted: [(title: String, duration: Double, finalScore: Double)] {
        store.completed.map { ($0.title, $0.actualDurationMinutes, $0.finalScore) }
    }

    private struct NoteItem: Identifiable {
        let id: UUID
        let title: String
        let notes: String
        let isTodo: Bool
    }

    private var allNotes: [NoteItem] {
        let tNotes = store.todos.filter { !$0.notes.isEmpty }
            .map { NoteItem(id: $0.id, title: $0.title, notes: $0.notes, isTodo: true) }
        let cNotes = store.completed.filter { !$0.notes.isEmpty }
            .map { NoteItem(id: $0.id, title: $0.title, notes: $0.notes, isTodo: false) }
        return tNotes + cNotes
    }

    var body: some View {
        ZStack {
            Morandi.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 24) {
                    Text("Observe")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(Morandi.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // 1. Estimated vs Actual Time
                    CollapsibleSection(title: "Estimated vs Actual Time") {
                        let filtered = matchedData.filter { $0.estimated > 0 || $0.actual > 0 }
                        if filtered.isEmpty {
                            emptyHint("Add estimated/actual durations to see data.")
                        } else {
                            let shown = timeShowAll ? filtered : Array(filtered.prefix(initialCount))
                            ChartViews.TimeComparisonChart(items: shown.map {
                                ($0.title, $0.estimated, $0.actual)
                            })
                            showMoreButton(total: filtered.count, showAll: $timeShowAll)
                        }
                    }

                    Divider().foregroundColor(Morandi.textSecondary.opacity(0.2))

                    // 2. Value Comparison
                    CollapsibleSection(title: "Value Comparison") {
                        if matchedData.isEmpty {
                            emptyHint("No completed events yet.")
                        } else {
                            let shown = valueShowAll ? matchedData : Array(matchedData.prefix(initialCount))
                            ChartViews.ValueComparisonChart(items: shown.map {
                                ($0.title, $0.objective, $0.subjective, $0.final_)
                            })
                            showMoreButton(total: matchedData.count, showAll: $valueShowAll)
                        }
                    }

                    Divider().foregroundColor(Morandi.textSecondary.opacity(0.2))

                    // 3. Time × Final Value
                    CollapsibleSection(title: "Time × Final Value") {
                        let filtered = allCompleted.filter { $0.duration > 0 }
                        if filtered.isEmpty {
                            emptyHint("Add actual durations to see data.")
                        } else {
                            let shown = timeValueShowAll ? filtered : Array(filtered.prefix(initialCount))
                            ChartViews.TimeValueChart(items: shown)
                            showMoreButton(total: filtered.count, showAll: $timeValueShowAll)
                        }
                    }

                    Divider().foregroundColor(Morandi.textSecondary.opacity(0.2))

                    // 4. Notes (tap to edit, delete button to clear note)
                    CollapsibleSection(title: "Notes") {
                        if allNotes.isEmpty {
                            emptyHint("No notes yet.")
                        } else {
                            let shown = notesShowAll ? allNotes : Array(allNotes.prefix(initialCount))
                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(shown) { note in
                                    noteRow(note)
                                }
                            }
                            showMoreButton(total: allNotes.count, showAll: $notesShowAll)
                        }
                    }
                }
                .padding(20)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar { ToolbarItem(placement: .navigationBarLeading) { LightOrbBackButton() } }
        .sheet(item: $editingTodo) { ev in
            NavigationStack { TodoEditView(event: ev, isNew: false).environmentObject(store) }
        }
        .sheet(item: $editingCompleted) { ev in
            NavigationStack { CompletedEditView(event: ev, isNew: false).environmentObject(store) }
        }
    }

    @ViewBuilder
    private func noteRow(_ note: NoteItem) -> some View {
        HStack(spacing: 0) {
            Button {
                if note.isTodo {
                    if let todo = store.todos.first(where: { $0.id == note.id }) {
                        editingTodo = todo
                    }
                } else {
                    if let ce = store.completed.first(where: { $0.id == note.id }) {
                        editingCompleted = ce
                    }
                }
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    Text(note.title)
                        .font(.caption).fontWeight(.semibold)
                        .foregroundColor(Morandi.textPrimary)
                    Text(note.notes)
                        .font(.caption)
                        .foregroundColor(Morandi.textSecondary)
                        .lineLimit(3)
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button {
                deleteNote(note)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Morandi.textSecondary.opacity(0.5))
                    .padding(10)
            }
        }
        .background(RoundedRectangle(cornerRadius: 10).fill(Morandi.cardBg))
    }

    private func deleteNote(_ note: NoteItem) {
        withAnimation(.easeOut(duration: 0.25)) {
            if note.isTodo {
                if var todo = store.todos.first(where: { $0.id == note.id }) {
                    todo.notes = ""
                    store.updateTodo(todo)
                }
            } else {
                if var ce = store.completed.first(where: { $0.id == note.id }) {
                    ce.notes = ""
                    store.updateCompleted(ce)
                }
            }
        }
    }

    @ViewBuilder
    private func showMoreButton(total: Int, showAll: Binding<Bool>) -> some View {
        if total > initialCount {
            Button {
                withAnimation(.easeInOut(duration: 0.3)) { showAll.wrappedValue.toggle() }
            } label: {
                Text(showAll.wrappedValue ? "Show Less" : "Show All (\(total))")
                    .font(.caption)
                    .foregroundColor(Morandi.darkBlue)
                    .padding(.top, 4)
            }
        }
    }

    @ViewBuilder
    private func emptyHint(_ text: String) -> some View {
        Text(text).font(.caption).foregroundColor(Morandi.textSecondary).padding(.vertical, 8)
    }
}
