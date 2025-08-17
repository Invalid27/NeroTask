// Views/UpcomingView.swift
import SwiftUI
import SwiftData

struct UpcomingView: View {
    @Query(filter: #Predicate<Task> { task in
        !task.isCompleted && task.dueDate != nil
    }, sort: \Task.dueDate) private var tasks: [Task]
    
    @State private var selection: UUID?
    @State private var expandedTask: Task?
    
    #if os(macOS)
    @Binding var selectedTask: Task?
    var searchText: String = ""
    
    init(searchText: String = "", selectedTask: Binding<Task?>? = nil) {
        self.searchText = searchText
        self._selectedTask = selectedTask ?? .constant(nil)
    }
    #else
    init() {}
    #endif
    
    var filteredTasks: [Task] {
        #if os(macOS)
        if searchText.isEmpty {
            return tasks
        }
        return tasks.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.notes.localizedCaseInsensitiveContains(searchText)
        }
        #else
        return tasks
        #endif
    }
    
    var body: some View {
        List(selection: $selection) {
            ForEach(filteredTasks) { task in
                TaskRowView(
                    task: task,
                    selectedTask: Binding(
                        get: { selectedTask },
                        set: { selectedTask = $0 }
                    ),
                    expandedTask: $expandedTask,
                    isSelected: selection == task.id
                )
                .tag(task.id)
                .listRowInsets(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4))
                .listRowSeparator(.hidden)
            }
        }
        #if os(macOS)
        .listStyle(.inset(alternatesRowBackgrounds: false))
        #else
        .listStyle(.plain)
        #endif
        .navigationTitle("Upcoming")
        #if os(macOS)
        .navigationSubtitle("\(tasks.count) scheduled")
        #endif
    }
}
