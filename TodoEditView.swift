import SwiftUI

struct TodoEditView: View {
    @EnvironmentObject var store: EventStore
    @Environment(\.dismiss) var dismiss

    @State var event: TodoEvent
    let isNew: Bool
    @State private var useEstimatedTime = false
    @State private var showDeleteAlert = false
    @State private var showPassiveAbandonAlert = false
    @State private var showActiveAbandonAlert = false
    @State private var convertedCompleted: CompletedEvent?

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

                    // Estimated Time (date pickers)
                    VStack(alignment: .leading, spacing: 6) {
                        Toggle(isOn: $useEstimatedTime) {
                            Text("Estimated Time").font(.subheadline).foregroundColor(Morandi.textSecondary)
                        }.tint(Morandi.darkBlue)
                        .onChange(of: useEstimatedTime) { on in
                            if on {
                                if event.startDate == nil { event.startDate = Date() }
                                if event.endDate == nil { event.endDate = Date().addingTimeInterval(3600) }
                            }
                        }
                        if useEstimatedTime {
                            DatePicker("Start", selection: Binding(
                                get: { event.startDate ?? Date() }, set: { event.startDate = $0 })).font(.subheadline)
                            DatePicker("End", selection: Binding(
                                get: { event.endDate ?? Date().addingTimeInterval(3600) }, set: { event.endDate = $0 })).font(.subheadline)
                        }
                    }
                    .padding(14).background(RoundedRectangle(cornerRadius: 12).fill(Morandi.cardBg))

                    // Countdown (only shown when estimated time is set)
                    if useEstimatedTime {
                        VStack(alignment: .leading, spacing: 6) {
                            Toggle(isOn: $event.countdownEnabled) {
                                HStack {
                                    Image(systemName: "timer").foregroundColor(Morandi.purple)
                                    Text("Enable Countdown").font(.subheadline).foregroundColor(Morandi.textPrimary)
                                }
                            }
                            .tint(Morandi.darkBlue)
                        }
                        .padding(14).background(RoundedRectangle(cornerRadius: 12).fill(Morandi.cardBg))
                    }

                    // Objective Score
                    ColorScoreSlider(
                        score: $event.objectiveScore,
                        lowColor: Morandi.darkPurple, highColor: Morandi.lightPurple,
                        label: "Objective Value")
                    .padding(14).background(RoundedRectangle(cornerRadius: 12).fill(Morandi.cardBg))

                    // Subjective Score
                    ColorScoreSlider(
                        score: $event.subjectiveScore,
                        lowColor: Morandi.darkBlue, highColor: Morandi.lightBlue,
                        label: "Subjective Value")
                    .padding(14).background(RoundedRectangle(cornerRadius: 12).fill(Morandi.cardBg))

                    // Notes
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Notes").font(.subheadline).foregroundColor(Morandi.textSecondary)
                        TextEditor(text: $event.notes).frame(minHeight: 80)
                            .scrollContentBackground(.hidden)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Morandi.cardBg))
                    }
                    .padding(14).background(RoundedRectangle(cornerRadius: 12).fill(Morandi.cardBg))

                    // Convert to Completed
                    if !isNew {
                        Button {
                            // Compute estimated duration from dates
                            if let start = event.startDate, let end = event.endDate {
                                event.estimatedDurationMinutes = max(0, end.timeIntervalSince(start) / 60)
                            }
                            let ce = store.makeCompletedEvent(from: event)
                            store.completeTodo(event, completed: ce)
                            triggerHaptic()
                            convertedCompleted = ce
                        } label: {
                            HStack {
                                Image(systemName: "arrow.right.circle.fill")
                                Text("Convert to Completed")
                            }
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white).padding(14)
                            .frame(maxWidth: .infinity)
                            .background(RoundedRectangle(cornerRadius: 14).fill(Morandi.darkGreen))
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
                                Text("Delete Task")
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
        .navigationTitle(isNew ? "New Task" : "Edit Task")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") { dismiss() }.foregroundColor(Morandi.textSecondary)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") { saveEvent() }.fontWeight(.semibold).foregroundColor(Morandi.darkBlue)
            }
        }
        .onAppear {
            useEstimatedTime = event.startDate != nil
            if event.countdownEnabled && event.startDate == nil {
                event.startDate = Date()
                event.endDate = Date().addingTimeInterval(3600)
                useEstimatedTime = true
            }
        }
        .alert("Delete Task", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                store.removeTodo(id: event.id)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete \"\(event.title)\"?")
        }
        .alert("Passive Abandon", isPresented: $showPassiveAbandonAlert) {
            Button("Abandon", role: .destructive) {
                store.abandonTodo(event, type: .passiveAbandon)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to passively abandon \"\(event.title)\"?")
        }
        .alert("Active Abandon", isPresented: $showActiveAbandonAlert) {
            Button("Abandon", role: .destructive) {
                store.abandonTodo(event, type: .activeAbandon)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to actively abandon \"\(event.title)\"?")
        }
        .sheet(item: $convertedCompleted, onDismiss: { dismiss() }) { ce in
            NavigationStack { CompletedEditView(event: ce, isNew: false).environmentObject(store) }
        }
    }

    private func saveEvent() {
        if useEstimatedTime, let start = event.startDate, let end = event.endDate {
            event.estimatedDurationMinutes = max(0, end.timeIntervalSince(start) / 60)
        } else {
            event.startDate = nil; event.endDate = nil
            event.estimatedDurationMinutes = 0
            event.countdownEnabled = false
        }
        if isNew { store.addTodo(event) } else { store.updateTodo(event) }
        dismiss()
    }

    private func triggerHaptic() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }
}
