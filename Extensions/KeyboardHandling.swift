// Extensions/KeyboardHandling.swift
import SwiftUI
import SwiftData

// Custom ViewModifier for keyboard handling
struct TaskListKeyboardHandler: ViewModifier {
    @Binding var selection: UUID?  // Use UUID directly instead of Task.ID
    @Binding var expandedTask: Task?
    let tasks: [Task]
    let onDelete: ((Task) -> Void)?
    let onToggleExpand: ((Task) -> Void)?
    
    func body(content: Content) -> some View {
        content
            #if os(macOS)
            .onKeyPress(.return) {
                handleReturnKey()
            }
            .onKeyPress(.space) {
                handleSpaceKey()
            }
            .onDeleteCommand {
                handleDeleteKey()
            }
            #endif
    }
    
    #if os(macOS)
    private func handleReturnKey() -> KeyPress.Result {
        guard let selectedID = selection,
              let selected = tasks.first(where: { $0.id == selectedID }) else {
            return .ignored
        }
        
        onToggleExpand?(selected)
        return .handled
    }
    
    private func handleSpaceKey() -> KeyPress.Result {
        guard let selectedID = selection,
              let selected = tasks.first(where: { $0.id == selectedID }) else {
            return .ignored
        }
        
        // Quick complete toggle with space
        selected.toggleCompletion()
        return .handled
    }
    
    private func handleDeleteKey() {
        guard let selectedID = selection,
              let selected = tasks.first(where: { $0.id == selectedID }) else {
            return
        }
        
        onDelete?(selected)
        selection = nil
    }
    #endif
}

// Extension to make it easy to use
extension View {
    func taskListKeyboardHandling(
        selection: Binding<UUID?>,  // Use UUID directly
        expandedTask: Binding<Task?>,
        tasks: [Task],
        onDelete: ((Task) -> Void)? = nil,
        onToggleExpand: ((Task) -> Void)? = nil
    ) -> some View {
        self.modifier(TaskListKeyboardHandler(
            selection: selection,
            expandedTask: expandedTask,
            tasks: tasks,
            onDelete: onDelete,
            onToggleExpand: onToggleExpand
        ))
    }
}
