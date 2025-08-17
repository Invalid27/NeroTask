// Views/macOS/QuickEntryView.swift
import SwiftUI
import SwiftData

#if os(macOS)
struct QuickEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var title = ""
    @State private var notes = ""
    @State private var dueDate: Date?
    @State private var isToday = false
    @FocusState private var titleFocused: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Text("New Task")
                .font(.headline)
            
            TextField("Task title", text: $title)
                .textFieldStyle(.roundedBorder)
                .focused($titleFocused)
                .onSubmit {
                    if !title.isEmpty {
                        createTask()
                    }
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Notes")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextEditor(text: $notes)
                    .font(.body)
                    .frame(minHeight: 60, maxHeight: 120)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
            }
            
            HStack {
                Toggle("Today", isOn: $isToday)
                
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
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.escape, modifiers: [])
                
                Spacer()
                
                Button("Create") {
                    createTask()
                }
                .keyboardShortcut(.return, modifiers: [])
                .disabled(title.isEmpty)
            }
        }
        .padding()
        .frame(width: 400)
        .onAppear {
            titleFocused = true
        }
    }
    
    private func createTask() {
        guard !title.isEmpty else { return }
        
        let task = Task(title: title, notes: notes, dueDate: dueDate)
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
