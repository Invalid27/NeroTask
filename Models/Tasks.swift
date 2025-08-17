// Models/Task.swift
import SwiftUI
import SwiftData

@Model
final class Task {
    var id: UUID
    var title: String
    var notes: String
    var isCompleted: Bool
    var createdDate: Date
    var completedDate: Date?
    var dueDate: Date?
    var isToday: Bool
    var priority: TaskPriority
    var tags: [String]
    
    init(
        title: String,
        notes: String = "",
        dueDate: Date? = nil,
        priority: TaskPriority = .normal,
        tags: [String] = []
    ) {
        self.id = UUID()
        self.title = title
        self.notes = notes
        self.isCompleted = false
        self.createdDate = Date()
        self.completedDate = nil
        self.dueDate = dueDate
        self.isToday = false
        self.priority = priority
        self.tags = tags
    }
    
    func toggleCompletion() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isCompleted.toggle()
            completedDate = isCompleted ? Date() : nil
            
            // Remove from today when completed
            if isCompleted {
                isToday = false
            }
        }
    }
    
    func toggleToday() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isToday.toggle()
        }
    }
}

// MARK: - Task Priority
enum TaskPriority: Int, Codable, CaseIterable {
    case low = 0
    case normal = 1
    case high = 2
    case urgent = 3
    
    var label: String {
        switch self {
        case .low: return "Low"
        case .normal: return "Normal"
        case .high: return "High"
        case .urgent: return "Urgent"
        }
    }
    
    var color: Color {
        switch self {
        case .low: return .gray
        case .normal: return .blue
        case .high: return .orange
        case .urgent: return .red
        }
    }
    
    var icon: String {
        switch self {
        case .low: return "arrow.down.circle"
        case .normal: return "circle"
        case .high: return "arrow.up.circle"
        case .urgent: return "exclamationmark.circle.fill"
        }
    }
}

// MARK: - Task Extensions
extension Task {
    typealias ID = UUID
    
    var isOverdue: Bool {
        guard let dueDate = dueDate, !isCompleted else { return false }
        return dueDate < Date()
    }
    
    var isDueToday: Bool {
        guard let dueDate = dueDate else { return false }
        return Calendar.current.isDateInToday(dueDate)
    }
    
    var isDueTomorrow: Bool {
        guard let dueDate = dueDate else { return false }
        return Calendar.current.isDateInTomorrow(dueDate)
    }
    
    var isDueThisWeek: Bool {
        guard let dueDate = dueDate else { return false }
        return Calendar.current.isDate(dueDate, equalTo: Date(), toGranularity: .weekOfYear)
    }
    
    var formattedDueDate: String? {
        guard let dueDate = dueDate else { return nil }
        
        if isDueToday {
            return "Today"
        } else if isDueTomorrow {
            return "Tomorrow"
        } else if isOverdue {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .full
            return formatter.localizedString(for: dueDate, relativeTo: Date())
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: dueDate)
        }
    }
    
    var subtitleInfo: String {
        var parts: [String] = []
        
        if !notes.isEmpty {
            parts.append("📝 Notes")
        }
        
        if let formattedDate = formattedDueDate {
            parts.append("📅 \(formattedDate)")
        }
        
        if !tags.isEmpty {
            parts.append("🏷 \(tags.count) tag\(tags.count == 1 ? "" : "s")")
        }
        
        return parts.joined(separator: " • ")
    }
}
