// Views/macOS/TaskEditView.swift
import SwiftUI
import SwiftData

#if os(macOS)
struct TaskEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let task: Task
    @State private var title: String
    @State private var notes: String
    @State private var dueDate: Date?
    @State private var isToday: Bool
    @State private var isCompleted: Bool
    @FocusState private var titleFocused: Bool
    
    init(task: Task) {
        self.task = task
        self._title = State(initialValue: task.title)
        self._notes = State(initialValue: task.notes)
        self._dueDate = State(initialValue: task.dueDate)
        self._isToday = State(initialValue: task.isToday)
        self._isCompleted = State(initialValue: task.isCompleted)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Edit Task")
                .font(.headline)
            
            TextField("Task title", text: $title)
                .textFieldStyle(.roundedBorder)
                .focused($titleFocused)
                .onSubmit {
                    saveTask()
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Notes")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextEditor(text: $notes)
                    .font(.body)
                    .frame(minHeight: 80, maxHeight: 200)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
            }
            
            HStack {
                Toggle("Today", isOn: $isToday)
                Toggle("Completed", isOn: $isCompleted)
                
                Spacer()
                
                if dueDate != nil {
                    DatePicker("Due:", selection: Binding(
                        get: { dueDate ?? Date() },
                        set: { dueDate = $0 }
                    ), displayedComponents: [.date])
                    
                    Button("Clear") {
                        dueDate = nil
                    }
                    .font(.caption)
                } else {
                    Button("Add Due Date") {
                        dueDate = Date()
                    }
                }
            }
            
            Divider()
            
            HStack {
                Button("Delete", role: .destructive) {
                    deleteTask()
                }
                
                Spacer()
                
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.escape, modifiers: [])
                
                Button("Save") {
                    saveTask()
                }
                .keyboardShortcut(.return, modifiers: [])
                .disabled(title.isEmpty)
            }
        }
        .padding()
        .frame(width: 450)
        .onAppear {
            titleFocused = true
        }
    }
    
    private func saveTask() {
        guard !title.isEmpty else { return }
        
        task.title = title
        task.notes = notes
        task.dueDate = dueDate
        task.isToday = isToday
        task.isCompleted = isCompleted
        if isCompleted && task.completedDate == nil {
            task.completedDate = Date()
        } else if !isCompleted {
            task.completedDate = nil
        }
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error saving task: \(error)")
        }
    }
    
    private func deleteTask() {
        modelContext.delete(task)
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error deleting task: \(error)")
        }
    }
}
#endif
