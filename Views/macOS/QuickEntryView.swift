// Views/macOS/QuickEntryView.swift
import SwiftUI
import SwiftData

#if os(macOS)
struct QuickEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var taskTitle = ""
    @State private var taskNotes = ""
    @State private var dueDate: Date?
    @State private var isToday = false
    @FocusState private var titleFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Title bar
            HStack {
                Text("Quick Entry")
                    .font(.headline)
                Spacer()
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.escape, modifiers: [])
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            // Content
            VStack(alignment: .leading, spacing: 16) {
                TextField("New Task", text: $taskTitle)
                    .textFieldStyle(.plain)
                    .font(.title3)
                    .focused($titleFocused)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextEditor(text: $taskNotes)
                        .font(.body)
                        .frame(minHeight: 60)
                        .scrollContentBackground(.hidden)
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(4)
                }
                
                HStack(spacing: 16) {
                    Toggle(isOn: $isToday) {
                        Label("Today", systemImage: "star")
                    }
                    .toggleStyle(.checkbox)
                    
                    if dueDate != nil {
                        DatePicker("Due:", selection: Binding(
                            get: { dueDate ?? Date() },
                            set: { dueDate = $0 }
                        ), displayedComponents: [.date])
                            .labelsHidden()
                    }
                    
                    Button("Set Due Date") {
                        dueDate = Date()
                    }
                    
                    if dueDate != nil {
                        Button("Clear") {
                            dueDate = nil
                        }
                    }
                    
                    Spacer()
                }
                
                Divider()
                
                // Action buttons
                HStack {
                    Spacer()
                    Button("Add to Inbox") {
                        createTask()
                    }
                    .keyboardShortcut(.return, modifiers: .command)
                    .buttonStyle(.borderedProminent)
                    .disabled(taskTitle.isEmpty)
                }
            }
            .padding()
        }
        .frame(width: 500, height: 300)
        .onAppear {
            titleFocused = true
        }
    }
    
    private func createTask() {
        guard !taskTitle.isEmpty else { return }
        
        let task = Task(title: taskTitle, notes: taskNotes, dueDate: dueDate)
        task.isToday = isToday
        modelContext.insert(task)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error creating task: \(error)")
        }
    }
}
#endif
