// Views/macOS/QuickEntryView.swift
import SwiftUI
import SwiftData

#if os(macOS)
struct QuickEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appState: AppState
    
    @State private var taskTitle = ""
    @State private var taskNotes = ""
    @State private var dueDate: Date?
    @State private var isToday = false
    @State private var priority: TaskPriority = .normal
    @State private var tags: [String] = []
    @State private var newTag = ""
    
    @FocusState private var titleFocused: Bool
    @State private var shake = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Title input
                    titleInputView
                    
                    // Notes input
                    notesInputView
                    
                    // Priority selector
                    prioritySelector
                    
                    // Date and Today options
                    dateOptionsView
                    
                    // Tags
                    tagsView
                }
                .padding(20)
            }
            
            Divider()
            
            // Footer actions
            footerView
        }
        .frame(width: 520, height: 500)
        .background(Color(NSColor.windowBackgroundColor))
        .onAppear {
            titleFocused = true
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("New Task")
                    .font(.system(size: 18, weight: .semibold))
                
                Text("Press ⌘↩ to save quickly")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.secondary)
                    .background(Circle().fill(Color.gray.opacity(0.1)))
            }
            .buttonStyle(PlainButtonStyle())
            .keyboardShortcut(.escape, modifiers: [])
        }
        .padding(20)
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    // MARK: - Title Input
    private var titleInputView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("TITLE", systemImage: "text.cursor")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.secondary)
            
            TextField("What needs to be done?", text: $taskTitle)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.system(size: 16))
                .focused($titleFocused)
                .onSubmit {
                    if !taskTitle.isEmpty {
                        createTask()
                    } else {
                        withAnimation(.default) {
                            shake = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            shake = false
                        }
                    }
                }
                .modifier(ShakeEffect(animatableData: shake ? 1 : 0))
        }
    }
    
    // MARK: - Notes Input
    private var notesInputView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("NOTES", systemImage: "note.text")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.secondary)
            
            TextEditor(text: $taskNotes)
                .font(.system(size: 14))
                .frame(minHeight: 80, maxHeight: 120)
                .padding(8)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        }
    }
    
    // MARK: - Priority Selector
    private var prioritySelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("PRIORITY", systemImage: "flag")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.secondary)
            
            HStack(spacing: 12) {
                ForEach(TaskPriority.allCases, id: \.self) { level in
                    PriorityButton(
                        priority: level,
                        isSelected: priority == level,
                        action: { priority = level }
                    )
                }
            }
        }
    }
    
    // MARK: - Date Options
    private var dateOptionsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("SCHEDULE", systemImage: "calendar")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.secondary)
            
            HStack(spacing: 16) {
                Toggle(isOn: $isToday) {
                    Label("Today", systemImage: "star")
                        .font(.system(size: 13, weight: .medium))
                }
                .toggleStyle(SwitchToggleStyle(tint: .orange))
                
                Divider()
                    .frame(height: 20)
                
                if dueDate != nil {
                    DatePicker(
                        "Due:",
                        selection: Binding(
                            get: { dueDate ?? Date() },
                            set: { dueDate = $0 }
                        ),
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .font(.system(size: 13))
                    
                    Button("Clear") {
                        withAnimation {
                            dueDate = nil
                        }
                    }
                    .font(.system(size: 12))
                    .foregroundColor(.red)
                } else {
                    Button(action: { dueDate = Date() }) {
                        Label("Set Due Date", systemImage: "calendar.badge.plus")
                            .font(.system(size: 13))
                    }
                    .buttonStyle(BorderedButtonStyle())
                }
            }
        }
    }
    
    // MARK: - Tags View
    private var tagsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("TAGS", systemImage: "tag")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.secondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(tags, id: \.self) { tag in
                        TagChip(tag: tag) {
                            withAnimation {
                                tags.removeAll { $0 == tag }
                            }
                        }
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.system(size: 10))
                        
                        TextField("Add tag", text: $newTag)
                            .textFieldStyle(.plain)
                            .font(.system(size: 12))
                            .onSubmit {
                                if !newTag.isEmpty {
                                    withAnimation {
                                        tags.append(newTag)
                                        newTag = ""
                                    }
                                }
                            }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .frame(width: 100)
                }
            }
        }
    }
    
    // MARK: - Footer View
    private var footerView: some View {
        HStack {
            Button("Cancel") {
                dismiss()
            }
            .keyboardShortcut(.escape, modifiers: [])
            .buttonStyle(BorderedButtonStyle())
            
            Spacer()
            
            Button("Create Task") {
                createTask()
            }
            .keyboardShortcut(.return, modifiers: .command)
            .buttonStyle(BorderedProminentButtonStyle())
            .disabled(taskTitle.isEmpty)
        }
        .padding(20)
    }
    
    // MARK: - Actions
    private func createTask() {
        guard !taskTitle.isEmpty else {
            withAnimation {
                shake = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                shake = false
            }
            return
        }
        
        let task = Task(
            title: taskTitle,
            notes: taskNotes,
            dueDate: dueDate,
            priority: priority,
            tags: tags
        )
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

// MARK: - Supporting Views
struct PriorityButton: View {
    let priority: TaskPriority
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: priority.icon)
                    .font(.system(size: 12))
                Text(priority.label)
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundColor(isSelected ? .white : priority.color)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isSelected ? priority.color : priority.color.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(priority.color.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TagChip: View {
    let tag: String
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(tag)
                .font(.system(size: 11))
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 10))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.blue.opacity(0.1))
        .foregroundColor(.blue)
        .cornerRadius(12)
    }
}

struct ShakeEffect: GeometryEffect {
    var animatableData: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: sin(animatableData * .pi * 2) * 5, y: 0))
    }
}
#endif
