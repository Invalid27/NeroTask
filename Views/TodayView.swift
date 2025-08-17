// Views/TodayView.swift
import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Task> { task in
        task.isToday && !task.isCompleted
    }) private var todayTasks: [Task]
    
    @State private var selection: UUID?
    @State private var expandedTask: Task?
    
    #if os(macOS)
    var searchText: String
    @Binding var selectedTask: Task?
    
    init(searchText: String = "", selectedTask: Binding<Task?>) {
        self.searchText = searchText
        self._selectedTask = selectedTask
    }
    #else
    let searchText: String = ""
    @State private var selectedTask: Task?
    
    init() {}
    #endif
    
    var filteredTasks: [Task] {
        if searchText.isEmpty {
            return todayTasks
        }
        return todayTasks.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.notes.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        List(selection: $selection) {
            if filteredTasks.isEmpty {
                ContentUnavailableView(
                    "No Tasks for Today",
                    systemImage: "star",
                    description: Text("Mark tasks for today from your inbox")
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
        #if os(macOS)
        .listStyle(.inset(alternatesRowBackgrounds: false))
        #else
        .listStyle(.plain)
        #endif
        .navigationTitle("Today")
        #if os(macOS)
        .navigationSubtitle("\(todayTasks.count) tasks")
        #endif
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
