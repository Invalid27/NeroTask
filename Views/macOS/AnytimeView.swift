// Views/macOS/AnytimeView.swift
import SwiftUI
import SwiftData

#if os(macOS)
struct AnytimeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Task> { task in
        !task.isCompleted && task.dueDate == nil && !task.isToday
    }) private var tasks: [Task]
    
    @State private var selection: UUID?
    @State private var expandedTask: Task?
    
    var searchText: String
    @Binding var selectedTask: Task?
    
    init(searchText: String = "", selectedTask: Binding<Task?>) {
        self.searchText = searchText
        self._selectedTask = selectedTask
    }
    
    var filteredTasks: [Task] {
        if searchText.isEmpty {
            return tasks
        }
        return tasks.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.notes.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        List(selection: $selection) {
            if filteredTasks.isEmpty {
                ContentUnavailableView(
                    "No Anytime Tasks",
                    systemImage: "archivebox",
                    description: Text("Tasks without dates that aren't marked for today appear here")
                )
            } else {
                ForEach(filteredTasks) { task in
                    TaskRowView(
                        task: task,
                        selectedTask: $selectedTask,
                        expandedTask: $expandedTask,
                        isSelected: selection == task.id
                    )
                    .tag(task.id)
                    .listRowInsets(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4))
                    .listRowSeparator(.hidden)
                }
                .onDelete(perform: deleteTasks)
            }
        }
        .listStyle(.inset(alternatesRowBackgrounds: false))
        .navigationTitle("Anytime")
        .navigationSubtitle("\(tasks.count) tasks")
    }
    
    private func deleteTasks(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filteredTasks[index])
        }
        do {
            try modelContext.save()
        } catch {
            print("Error deleting tasks: \(error)")
        }
    }
}
#endif
