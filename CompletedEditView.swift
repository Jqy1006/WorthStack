import SwiftUI

struct CompletedEditView: View {
    @EnvironmentObject var store: EventStore
    @Environment(\.dismiss) var dismiss

    @State var event: CompletedEvent
    let isNew: Bool
    @State private var useActualTime = false
    @State private var showDeleteAlert = false
    @State private var showPassiveAbandonAlert = false
    @State private var showActiveAbandonAlert = false
    @State private var convertedTodo: TodoEvent?

    var body: some View {
        ZStack {
            Morandi.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 20) {
                    // Title
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Event Title").font(.subheadline).foregroundColor(Morandi.textSecondary)
                        TextField("Enter title...", text: $event.title)
                            .textFieldStyle(.plain).padding(12)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Morandi.cardBg))
                    }

                    // Actual Time (date pickers)
                    VStack(alignment: .leading, spacing: 6) {
                        Toggle(isOn: $useActualTime) {
                            Text("Actual Time").font(.subheadline).foregroundColor(Morandi.textSecondary)
                        }.tint(Morandi.darkGreen)
                        .onChange(of: useActualTime) { on in
                            if on {
                                if event.startDate == nil { event.startDate = Date() }
                                if event.endDate == nil { event.endDate = Date() }
                            }
                        }
                        if useActualTime {
                            DatePicker("Start", selection: Binding(
                                get: { event.startDate ?? Date() }, set: { event.startDate = $0 })).font(.subheadline)
                            DatePicker("End", selection: Binding(
                                get: { event.endDate ?? Date() }, set: { event.endDate = $0 })).font(.subheadline)
                        }
                    }
                    .padding(14).background(RoundedRectangle(cornerRadius: 12).fill(Morandi.cardBg))

                    // Objective Score
                    ColorScoreSlider(
                        score: $event.objectiveScore,
                        lowColor: Morandi.darkPurple, highColor: Morandi.lightPurple,
                        label: "Objective Value")
                    .padding(14).background(RoundedRectangle(cornerRadius: 12).fill(Morandi.cardBg))

                    // Final Value
                    ColorScoreSlider(
                        score: $event.finalScore,
                        lowColor: Morandi.darkGreen, highColor: Morandi.lightGreen,
                        label: "Final Value")
                    .padding(14).background(RoundedRectangle(cornerRadius: 12).fill(Morandi.cardBg))

                    // Notes
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Notes").font(.subheadline).foregroundColor(Morandi.textSecondary)
                        TextEditor(text: $event.notes).frame(minHeight: 80)
                            .scrollContentBackground(.hidden)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Morandi.cardBg))
                    }
                    .padding(14).background(RoundedRectangle(cornerRadius: 12).fill(Morandi.cardBg))

                    // Convert to Todo (reverse conversion)
                    if !isNew {
                        Button {
                            // Compute actual duration from dates
                            if let start = event.startDate, let end = event.endDate {
                                event.actualDurationMinutes = max(0, end.timeIntervalSince(start) / 60)
                            }
                            let todo = store.makeTodoEvent(from: event)
                            store.revertToTodo(event, as: todo)
                            triggerHaptic()
                            convertedTodo = todo
                        } label: {
                            HStack {
                                Image(systemName: "arrow.left.circle.fill")
                                Text("Convert to Todo")
                            }
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white).padding(14)
                            .frame(maxWidth: .infinity)
                            .background(RoundedRectangle(cornerRadius: 14).fill(Morandi.darkBlue))
                        }

                        // Abandon buttons
                        HStack(spacing: 12) {
                            Button { showPassiveAbandonAlert = true } label: {
                                Text("Passive Abandon")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.white).padding(14)
                                    .frame(maxWidth: .infinity)
                                    .background(RoundedRectangle(cornerRadius: 14).fill(Morandi.muddyBrown))
                            }
                            Button { showActiveAbandonAlert = true } label: {
                                Text("Active Abandon")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.white).padding(14)
                                    .frame(maxWidth: .infinity)
                                    .background(RoundedRectangle(cornerRadius: 14).fill(Morandi.muddyYellow))
                            }
                        }

                        // Delete button
                        Button { showDeleteAlert = true } label: {
                            HStack {
                                Image(systemName: "trash.fill")
                                Text("Delete Event")
                            }
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white).padding(14)
                            .frame(maxWidth: .infinity)
                            .background(RoundedRectangle(cornerRadius: 14).fill(Color.red.opacity(0.7)))
                        }
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle(isNew ? "New Completion" : "Edit Completion")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") { dismiss() }.foregroundColor(Morandi.textSecondary)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") { saveEvent() }.fontWeight(.semibold).foregroundColor(Morandi.darkGreen)
            }
        }
        .onAppear {
            useActualTime = event.startDate != nil
        }
        .alert("Delete Event", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                store.removeCompleted(event)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete \"\(event.title)\"?")
        }
        .alert("Passive Abandon", isPresented: $showPassiveAbandonAlert) {
            Button("Abandon", role: .destructive) {
                store.abandonCompleted(event, type: .passiveAbandon)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to passively abandon \"\(event.title)\"?")
        }
        .alert("Active Abandon", isPresented: $showActiveAbandonAlert) {
            Button("Abandon", role: .destructive) {
                store.abandonCompleted(event, type: .activeAbandon)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to actively abandon \"\(event.title)\"?")
        }
        .sheet(item: $convertedTodo, onDismiss: { dismiss() }) { todo in
            NavigationStack { TodoEditView(event: todo, isNew: false).environmentObject(store) }
        }
    }

    private func saveEvent() {
        if useActualTime, let start = event.startDate, let end = event.endDate {
            event.actualDurationMinutes = max(0, end.timeIntervalSince(start) / 60)
        } else {
            event.startDate = nil; event.endDate = nil
            event.actualDurationMinutes = 0
        }
        if isNew { store.addCompleted(event) } else { store.updateCompleted(event) }
        dismiss()
    }

    private func triggerHaptic() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }
}
