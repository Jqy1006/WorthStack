import Foundation

// MARK: - Abandon Type
enum AbandonType: String, Codable, CaseIterable {
    case activeAbandon
    case passiveAbandon
}

// MARK: - Todo Event
struct TodoEvent: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String = ""
    var startDate: Date?
    var endDate: Date?
    var countdownEnabled: Bool = false
    var objectiveScore: Double = 5.0
    var subjectiveScore: Double = 5.0
    var isConverted: Bool = false
    var estimatedDurationMinutes: Double = 0
    var notes: String = ""
    var createdAt: Date = Date()
}

// MARK: - Completed Event
struct CompletedEvent: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String = ""
    var startDate: Date?
    var endDate: Date?
    var estimatedDurationMinutes: Double = 0
    var actualDurationMinutes: Double = 0
    var objectiveScore: Double = 5.0
    var finalScore: Double = 5.0
    var notes: String = ""
    var sourceEventId: UUID?
    var createdAt: Date = Date()
}

// MARK: - Abandoned Event
struct AbandonedEvent: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String = ""
    var objectiveScore: Double = 5.0
    var subjectiveScore: Double = 5.0
    var abandonType: AbandonType = .activeAbandon
    var notes: String = ""
    var sourceEventId: UUID = UUID()
    var createdAt: Date = Date()
}
