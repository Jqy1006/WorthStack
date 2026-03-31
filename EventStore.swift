import Foundation
import SwiftUI

@MainActor
class EventStore: ObservableObject {
    @Published var todos: [TodoEvent] = []
    @Published var completed: [CompletedEvent] = []
    @Published var abandoned: [AbandonedEvent] = []
    @Published var conversionAnimationTrigger: UUID? = nil
    /// Set to true when a completed→todo reversion happens (green→blue animation)
    @Published var reversionAnimationTrigger: UUID? = nil

    private let todosFile = "mindblock_todos.json"
    private let completedFile = "mindblock_completed.json"
    private let abandonedFile = "mindblock_abandoned.json"

    init() { load() }

    private var docsURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    // MARK: - Todo CRUD
    func addTodo(_ event: TodoEvent) { todos.append(event); save() }

    func updateTodo(_ event: TodoEvent) {
        if let i = todos.firstIndex(where: { $0.id == event.id }) {
            todos[i] = event; save()
        }
    }

    func removeTodo(id: UUID) {
        todos.removeAll { $0.id == id }; save()
    }

    // MARK: - Completed CRUD
    func addCompleted(_ event: CompletedEvent) { completed.append(event); save() }

    func updateCompleted(_ event: CompletedEvent) {
        if let i = completed.firstIndex(where: { $0.id == event.id }) {
            completed[i] = event; save()
        }
    }

    func removeCompleted(_ event: CompletedEvent) {
        completed.removeAll { $0.id == event.id }; save()
    }

    // MARK: - Abandoned
    func removeAbandoned(_ event: AbandonedEvent) {
        abandoned.removeAll { $0.id == event.id }; save()
    }

    // MARK: - Pure function: build CompletedEvent from TodoEvent
    func makeCompletedEvent(from todo: TodoEvent) -> CompletedEvent {
        CompletedEvent(
            title: todo.title,
            startDate: todo.startDate,
            endDate: todo.endDate,
            estimatedDurationMinutes: todo.estimatedDurationMinutes,
            objectiveScore: todo.objectiveScore,
            notes: todo.notes,
            sourceEventId: todo.id
        )
    }

    // MARK: - Pure function: build TodoEvent from CompletedEvent
    func makeTodoEvent(from ce: CompletedEvent) -> TodoEvent {
        TodoEvent(
            title: ce.title,
            startDate: ce.startDate,
            endDate: ce.endDate,
            objectiveScore: ce.objectiveScore,
            subjectiveScore: ce.finalScore,
            estimatedDurationMinutes: ce.estimatedDurationMinutes,
            notes: ce.notes
        )
    }

    // MARK: - Safe state mutation: complete a todo (Todo → Completed)
    func completeTodo(_ todo: TodoEvent, completed ce: CompletedEvent) {
        todos.removeAll { $0.id == todo.id }
        completed.append(ce)
        conversionAnimationTrigger = UUID()
        save()
    }

    // MARK: - Safe state mutation: revert completed → todo (Completed → Todo)
    func revertToTodo(_ ce: CompletedEvent, as todo: TodoEvent) {
        completed.removeAll { $0.id == ce.id }
        todos.append(todo)
        reversionAnimationTrigger = UUID()
        save()
    }

    // MARK: - Safe state mutation: abandon a todo
    func abandonTodo(_ todo: TodoEvent, type: AbandonType) {
        let ae = AbandonedEvent(
            title: todo.title,
            objectiveScore: todo.objectiveScore,
            subjectiveScore: todo.subjectiveScore,
            abandonType: type,
            notes: todo.notes,
            sourceEventId: todo.id,
            createdAt: todo.createdAt
        )
        abandoned.append(ae)
        todos.removeAll { $0.id == todo.id }
        save()
    }

    // MARK: - Safe state mutation: abandon a completed event
    func abandonCompleted(_ ce: CompletedEvent, type: AbandonType) {
        let ae = AbandonedEvent(
            title: ce.title,
            objectiveScore: ce.objectiveScore,
            subjectiveScore: ce.finalScore,
            abandonType: type,
            notes: ce.notes,
            sourceEventId: ce.id,
            createdAt: ce.createdAt
        )
        abandoned.append(ae)
        completed.removeAll { $0.id == ce.id }
        save()
    }

    // MARK: - Persistence
    func save() {
        let enc = JSONEncoder(); enc.dateEncodingStrategy = .iso8601
        try? enc.encode(todos).write(to: docsURL.appendingPathComponent(todosFile))
        try? enc.encode(completed).write(to: docsURL.appendingPathComponent(completedFile))
        try? enc.encode(abandoned).write(to: docsURL.appendingPathComponent(abandonedFile))
    }

    func load() {
        let dec = JSONDecoder(); dec.dateDecodingStrategy = .iso8601
        if let d = try? Data(contentsOf: docsURL.appendingPathComponent(todosFile)),
           let v = try? dec.decode([TodoEvent].self, from: d) { todos = v }
        if let d = try? Data(contentsOf: docsURL.appendingPathComponent(completedFile)),
           let v = try? dec.decode([CompletedEvent].self, from: d) { completed = v }
        if let d = try? Data(contentsOf: docsURL.appendingPathComponent(abandonedFile)),
           let v = try? dec.decode([AbandonedEvent].self, from: d) { abandoned = v }
    }
}
