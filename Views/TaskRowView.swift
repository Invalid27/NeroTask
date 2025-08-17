// Views/TaskRowView.swift
import SwiftUI
import SwiftData

struct TaskRowView: View {
    let task: Task
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var appState: AppState
    @State private var isHovering = false
    @State private var editingTitle: String = ""
    @State private var editingNotes: String = ""
    @State private var editingDueDate: Date?
    @FocusState private var titleFieldFocused: Bool
    @FocusState private var notesFieldFocused: Bool
    @FocusState private var listFocused: Bool
    
    #if os(macOS)
    @Binding var selectedTask: Task?
    @Binding var expandedTask: Task?
    let isSelected: Bool
    
    var isExpanded: Bool {
        expandedTask?.id == task.id
    }
    
    init(task: Task, selectedTask: Binding<Task?>? = nil, expandedTask: Binding<Task?>? = nil, isSelected: Bool = false) {
        self.task = task
        self._selectedTask = selectedTask ?? .constant(nil)
        self._expandedTask = expandedTask ?? .constant(nil)
        self.isSelected = isSelected
    }
    #else
    @State private var isExpanded = false
    
    init(task: Task) {
        self.task = task
    }
    #endif
    
    var body: some View {
        VStack(spacing: 0) {
            // Main row with minimal padding
            HStack(spacing: 6) {
                // Completion button
                Button(action: {
                    task.toggleCompletion()
                    try? modelContext.save()
                }) {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(task.isCompleted ? .green : .gray)
                        .font(.system(size: 14))
                }
                .buttonStyle(PlainButtonStyle())
                
                // Task content - ultra compact
                VStack(alignment: .leading, spacing: 0) {
                    if isExpanded {
                        TextField("Task title", text: $editingTitle)
                            .textFieldStyle(.plain)
                            .font(.system(size: 13))
                            .focused($titleFieldFocused)
                            .onSubmit {
                                saveChanges()
                                #if os(macOS)
                                expandedTask = nil
                                // Return focus to list
                                listFocused = true
                                #else
                                isExpanded = false
                                #endif
                            }
                            #if os(macOS)
                            .onExitCommand {
                                // Revert changes and close
                                editingTitle = task.title
                                editingNotes = task.notes
                                editingDueDate = task.dueDate
                                expandedTask = nil
                                // Return focus to list
                                listFocused = true
                            }
                            #endif
                    } else {
                        // Main title with inline badges
                        HStack(spacing: 4) {
                            Text(task.title)
                                .strikethrough(task.isCompleted)
                                .foregroundColor(task.isCompleted ? .secondary : .primary)
                                .font(.system(size: 13))
                                .lineLimit(1)
                            
                            // Inline badges for minimal height
                            if task.isToday {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.orange)
                            }
                            
                            if let dueDate = task.dueDate {
                                Text(dueDate, style: .date)
                                    .font(.system(size: 10))
                                    .foregroundColor(.blue)
                            }
                            
                            if !task.notes.isEmpty {
                                Image(systemName: "note.text")
                                    .font(.system(size: 10))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                Spacer(minLength: 2)
                
                // Action buttons (visible on hover on macOS)
                #if os(macOS)
                if isHovering && !isExpanded {
                    HStack(spacing: 2) {
                        Button(action: {
                            task.isToday.toggle()
                            try? modelContext.save()
                        }) {
                            Image(systemName: task.isToday ? "star.fill" : "star")
                                .foregroundColor(task.isToday ? .orange : .gray)
                                .font(.system(size: 12))
                        }
                        .buttonStyle(PlainButtonStyle())
                        .help(task.isToday ? "Remove from Today" : "Move to Today")
                        
                        Menu {
                            Button("Expand") {
                                expandTask()
                            }
                            Button("Edit...") {
                                selectedTask = task
                            }
                            Button("Duplicate") {
                                duplicateTask()
                            }
                            Divider()
                            Button("Delete", role: .destructive) {
                                modelContext.delete(task)
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .foregroundColor(.gray)
                                .font(.system(size: 12))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                #endif
            }
            .padding(.vertical, 1)
            .padding(.horizontal, 4)
            .focused($listFocused)
            
            // Expanded content (when needed)
            if isExpanded {
                VStack(alignment: .leading, spacing: 6) {
                    // Notes section
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Notes")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        TextEditor(text: $editingNotes)
                            .font(.system(size: 11))
                            .frame(minHeight: 40, maxHeight: 80)
                            .scrollContentBackground(.hidden)
                            .focused($notesFieldFocused)
                            #if os(macOS)
                            .background(Color(NSColor.controlBackgroundColor))
                            #else
                            .background(Color.gray.opacity(0.1))
                            #endif
                            .cornerRadius(3)
                    }
                    
                    // Compact controls
                    HStack(spacing: 8) {
                        Toggle(isOn: Binding(
                            get: { task.isToday },
                            set: { newValue in
                                task.isToday = newValue
                                try? modelContext.save()
                            }
                        )) {
                            Label("Today", systemImage: "star")
                                .font(.system(size: 11))
                        }
                        .toggleStyle(.checkbox)
                        
                        if let date = editingDueDate {
                            DatePicker("Due:", selection: Binding(
                                get: { date },
                                set: { editingDueDate = $0 }
                            ), displayedComponents: [.date])
                                .font(.system(size: 11))
                        } else {
                            Button("Add Due Date") {
                                editingDueDate = Date()
                            }
                            .font(.system(size: 11))
                        }
                        
                        if editingDueDate != nil {
                            Button("Clear") {
                                editingDueDate = nil
                            }
                            .font(.system(size: 11))
                        }
                        
                        Spacer()
                        
                        Button("Done") {
                            saveChanges()
                            #if os(macOS)
                            expandedTask = nil
                            // Return focus to list
                            listFocused = true
                            #else
                            isExpanded = false
                            #endif
                        }
                        .keyboardShortcut(.return, modifiers: [])
                        .font(.system(size: 11))
                    }
                    
                    Divider()
                }
                .padding(.horizontal, 4)
                .padding(.bottom, 4)
            }
        }
        #if os(macOS)
        .background(
            RoundedRectangle(cornerRadius: 3)
                .fill(isExpanded ? Color(NSColor.controlBackgroundColor).opacity(0.5) :
                      isSelected ? Color.accentColor.opacity(0.1) :
                      isHovering ? Color.gray.opacity(0.05) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 3)
                .stroke(isExpanded ? Color.accentColor.opacity(0.3) :
                       isSelected ? Color.accentColor.opacity(0.3) : Color.clear,
                       lineWidth: 0.5)
        )
        .onHover { hovering in
            if !isExpanded {
                isHovering = hovering
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(count: 2) {
            if !isExpanded {
                expandTask()
            }
        }
        .onChange(of: isExpanded) { oldValue, newValue in
            if !newValue && oldValue {
                // When collapsing, return focus to list
                listFocused = true
            }
        }
        #endif
    }
    
    private func expandTask() {
        editingTitle = task.title
        editingNotes = task.notes
        editingDueDate = task.dueDate
        #if os(macOS)
        expandedTask = task
        #else
        isExpanded = true
        #endif
        // Small delay to ensure the view is ready
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            titleFieldFocused = true
        }
    }
    
    private func saveChanges() {
        task.title = editingTitle
        task.notes = editingNotes
        task.dueDate = editingDueDate
        try? modelContext.save()
    }
    
    private func duplicateTask() {
        let newTask = Task(title: task.title, notes: task.notes, dueDate: task.dueDate)
        newTask.isToday = task.isToday
        modelContext.insert(newTask)
        try? modelContext.save()
    }
}
