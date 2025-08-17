// Views/TaskRowView.swift
import SwiftUI
import SwiftData

struct TaskRowView: View {
    let task: Task
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appState: AppState
    
    @State private var isHovering = false
    @State private var isExpanded = false
    @State private var editingTitle: String = ""
    @State private var editingNotes: String = ""
    @State private var editingDueDate: Date?
    @State private var editingPriority: TaskPriority = .normal
    
    @FocusState private var titleFieldFocused: Bool
    @Namespace private var animation
    
    var isSelected: Bool {
        appState.selectedTasks.contains(task.id)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            mainRow
            
            if isExpanded {
                expandedContent
                    .transition(.asymmetric(
                        insertion: .push(from: .top).combined(with: .opacity),
                        removal: .push(from: .bottom).combined(with: .opacity)
                    ))
            }
        }
        .background(backgroundView)
        .contentShape(Rectangle())
        .onTapGesture(count: 2) {
            if !isExpanded {
                expandTask()
            }
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                if appState.selectedTasks.contains(task.id) {
                    appState.selectedTasks.remove(task.id)
                } else {
                    appState.selectedTasks.insert(task.id)
                }
            }
        }
        .contextMenu {
            contextMenuItems
        }
    }
    
    // MARK: - Main Row
    private var mainRow: some View {
        HStack(spacing: 12) {
            // Completion button
            Button(action: { toggleCompletion() }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18))
                    .foregroundColor(task.isCompleted ? .green : .gray.opacity(0.6))
                    .scaleEffect(task.isCompleted ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: task.isCompleted)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Task content
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    if task.priority != .normal {
                        Image(systemName: task.priority.icon)
                            .font(.system(size: 12))
                            .foregroundColor(task.priority.color)
                    }
                    
                    Text(task.title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(task.isCompleted ? .secondary : .primary)
                        .strikethrough(task.isCompleted, color: .secondary)
                        .lineLimit(1)
                    
                    if task.isToday {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.orange)
                    }
                    
                    Spacer()
                }
                
                if !task.subtitleInfo.isEmpty {
                    Text(task.subtitleInfo)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            // Due date badge
            if let formattedDate = task.formattedDueDate {
                Text(formattedDate)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(dueDateColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(dueDateColor.opacity(0.15))
                    .cornerRadius(6)
            }
            
            // Action buttons (visible on hover)
            #if os(macOS)
            if isHovering && !isExpanded {
                HStack(spacing: 8) {
                    Button(action: { toggleToday() }) {
                        Image(systemName: task.isToday ? "star.fill" : "star")
                            .font(.system(size: 14))
                            .foregroundColor(task.isToday ? .orange : .gray)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help(task.isToday ? "Remove from Today" : "Move to Today")
                    
                    Menu {
                        menuItems
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    .menuStyle(BorderlessButtonMenuStyle())
                }
                .transition(.scale.combined(with: .opacity))
            }
            #endif
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
    }
    
    // MARK: - Expanded Content
    private var expandedContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Divider()
                .padding(.horizontal, 12)
            
            VStack(alignment: .leading, spacing: 12) {
                // Title editing
                TextField("Task title", text: $editingTitle)
                    .textFieldStyle(.plain)
                    .font(.system(size: 16, weight: .semibold))
                    .focused($titleFieldFocused)
                
                // Notes editing
                VStack(alignment: .leading, spacing: 4) {
                    Text("NOTES")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    TextEditor(text: $editingNotes)
                        .font(.system(size: 13))
                        .frame(minHeight: 60, maxHeight: 120)
                        .padding(8)
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(8)
                }
                
                // Priority selector
                HStack(spacing: 16) {
                    Text("PRIORITY")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    Picker("Priority", selection: $editingPriority) {
                        ForEach(TaskPriority.allCases, id: \.self) { priority in
                            Label(priority.label, systemImage: priority.icon)
                                .tag(priority)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(maxWidth: 300)
                }
                
                // Date and today toggle
                HStack(spacing: 20) {
                    Toggle(isOn: Binding(
                        get: { task.isToday },
                        set: { _ in task.toggleToday() }
                    )) {
                        Label("Today", systemImage: "star")
                            .font(.system(size: 12))
                    }
                    .toggleStyle(.checkbox)
                    
                    if editingDueDate != nil {
                        DatePicker("Due:", selection: Binding(
                            get: { editingDueDate ?? Date() },
                            set: { editingDueDate = $0 }
                        ), displayedComponents: [.date, .hourAndMinute])
                            .font(.system(size: 12))
                        
                        Button("Clear") {
                            editingDueDate = nil
                        }
                        .font(.system(size: 11))
                        .buttonStyle(PlainButtonStyle())
                        .foregroundColor(.red)
                    } else {
                        Button("Add Due Date") {
                            editingDueDate = Date()
                        }
                        .font(.system(size: 12))
                        .buttonStyle(BorderedButtonStyle())
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Button("Cancel") {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                isExpanded = false
                            }
                        }
                        .buttonStyle(BorderedButtonStyle())
                        
                        Button("Save") {
                            saveChanges()
                        }
                        .buttonStyle(BorderedProminentButtonStyle())
                        .keyboardShortcut(.return, modifiers: [])
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
    }
    
    // MARK: - Background View
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(borderColor, lineWidth: 1)
            )
            .shadow(color: .black.opacity(isExpanded ? 0.1 : 0), radius: 8, y: 2)
    }
    
    private var backgroundColor: Color {
        if isExpanded {
            return Color(nsColor: .controlBackgroundColor)
        } else if isSelected {
            return Color.accentColor.opacity(0.08)
        } else if isHovering {
            return Color.gray.opacity(0.05)
        }
        return Color.clear
    }
    
    private var borderColor: Color {
        if isExpanded {
            return Color.accentColor.opacity(0.5)
        } else if isSelected {
            return Color.accentColor.opacity(0.3)
        }
        return Color.clear
    }
    
    private var dueDateColor: Color {
        if task.isOverdue {
            return .red
        } else if task.isDueToday {
            return .orange
        } else if task.isDueTomorrow {
            return .blue
        }
        return .secondary
    }
    
    // MARK: - Menu Items
    private var menuItems: some View {
        Group {
            Button("Edit") {
                expandTask()
            }
            
            Button("Duplicate") {
                duplicateTask()
            }
            
            Divider()
            
            Menu("Priority") {
                ForEach(TaskPriority.allCases, id: \.self) { priority in
                    Button(action: { setPriority(priority) }) {
                        Label(priority.label, systemImage: priority.icon)
                    }
                }
            }
            
            Divider()
            
            Button("Delete", role: .destructive) {
                deleteTask()
            }
        }
    }
    
    private var contextMenuItems: some View {
        Group {
            Button(task.isCompleted ? "Mark as Incomplete" : "Mark as Complete") {
                toggleCompletion()
            }
            
            Button(task.isToday ? "Remove from Today" : "Move to Today") {
                toggleToday()
            }
            
            Divider()
            
            menuItems
        }
    }
    
    // MARK: - Actions
    private func expandTask() {
        editingTitle = task.title
        editingNotes = task.notes
        editingDueDate = task.dueDate
        editingPriority = task.priority
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isExpanded = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            titleFieldFocused = true
        }
    }
    
    private func saveChanges() {
        task.title = editingTitle
        task.notes = editingNotes
        task.dueDate = editingDueDate
        task.priority = editingPriority
        
        do {
            try modelContext.save()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isExpanded = false
            }
        } catch {
            print("Error saving task: \(error)")
        }
    }
    
    private func toggleCompletion() {
        task.toggleCompletion()
        try? modelContext.save()
    }
    
    private func toggleToday() {
        task.toggleToday()
        try? modelContext.save()
    }
    
    private func setPriority(_ priority: TaskPriority) {
        task.priority = priority
        try? modelContext.save()
    }
    
    private func duplicateTask() {
        let newTask = Task(
            title: task.title,
            notes: task.notes,
            dueDate: task.dueDate,
            priority: task.priority,
            tags: task.tags
        )
        newTask.isToday = task.isToday
        modelContext.insert(newTask)
        try? modelContext.save()
    }
    
    private func deleteTask() {
        modelContext.delete(task)
        try? modelContext.save()
    }
}
