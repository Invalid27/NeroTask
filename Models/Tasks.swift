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
    
    init(title: String, notes: String = "", dueDate: Date? = nil) {
        self.id = UUID()
        self.title = title
        self.notes = notes
        self.isCompleted = false
        self.createdDate = Date()
        self.completedDate = nil
        self.dueDate = dueDate
        self.isToday = false
    }
    
    func toggleCompletion() {
        isCompleted.toggle()
        completedDate = isCompleted ? Date() : nil
    }
}

// Make ID type accessible
extension Task {
    typealias ID = UUID
}
