// Views/macOS/TaskEditView.swift
import SwiftUI
import SwiftData

#if os(macOS)
struct TaskEditView: View {
    let task: Task
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var title: String
    @State private var notes: String
    @State private var dueDate: Date?
    @State private var isToday: Bool
    
    init(task: Task) {
        self.task = task
        self._title = State(initialValue: task.title)
        self._notes = State(initialValue: task.notes)
        self._dueDate = State(initialValue: task.dueDate)
        self._isToday = State(initialValue: task.isToday)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Title bar
            HStack {
                Text("Edit Task")
                    .font(.headline)
                Spacer()
                Button("Done") {
                    saveChanges()
                    dismiss()
                }
                .keyboardShortcut(.return, modifiers: .command)
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            // Content
            Form {
                TextField("Title", text: $title)
                    .textFieldStyle(.roundedBorder)
                
                VStack(alignment: .leading) {
                    Text("Notes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextEditor(text: $notes)
                        .font(.body)
                        .frame(minHeight: 100)
                        .scrollContentBackground(.hidden)
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(4)
                }
                
                Toggle("Today", isOn: $isToday)
                
                HStack {
                    if dueDate != nil {
                        DatePicker("Due Date", selection: Binding(
                            get: { dueDate ?? Date() },
                            set: { dueDate = $0 }
                        ))
                    } else {
                        Button("Add Due Date") {
                            dueDate = Date()
                        }
                    }
                    
                    if dueDate != nil {
                        Button("Clear") {
                            dueDate = nil
                        }
                    }
                }
            }
            .padding()
        }
        .frame(width: 500, height: 400)
    }
    
    private func saveChanges() {
        task.title = title
        task.notes = notes
        task.dueDate = dueDate
        task.isToday = isToday
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving task changes: \(error)")
        }
    }
}
#endif
