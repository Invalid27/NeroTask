import SwiftUI
import SwiftData

// Centralized task actions
struct TaskActions {
    let modelContext: ModelContext
    
    func toggleCompletion(for task: Task) {
        task.toggleCompletion()
        save()
    }
    
    func toggleToday(for task: Task) {
        task.isToday.toggle()
        save()
    }
    
    func duplicate(_ task: Task) -> Task {
        let newTask = Task(
            title: task.title,
            notes: task.notes,
            dueDate: task.dueDate
        )
        newTask.isToday = task.isToday
        modelContext.insert(newTask)
        save()
        return newTask
    }
    
    func delete(_ task: Task) {
        modelContext.delete(task)
        save()
    }
    
    func updateTask(_ task: Task, title: String, notes: String, dueDate: Date?) {
        task.title = title
        task.notes = notes
        task.dueDate = dueDate
        save()
    }
    
    func createTask(title: String, notes: String = "", dueDate: Date? = nil, isToday: Bool = false) -> Task {
        let task = Task(title: title, notes: notes, dueDate: dueDate)
        task.isToday = isToday
        modelContext.insert(task)
        save()
        return task
    }
    
    private func save() {
        do {
            try modelContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}
