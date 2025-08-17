// Views/TodayView.swift
import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var appState: AppState
    @Query(filter: #Predicate<Task> { task in
        task.isToday && !task.isCompleted
    }) private var todayTasks: [Task]
    
    @State private var selection: UUID?
    
    var filteredTasks: [Task] {
        #if os(macOS)
        if appState.searchText.isEmpty {
            return todayTasks
        }
        return todayTasks.filter {
            $0.title.localizedCaseInsensitiveContains(appState.searchText) ||
            $0.notes.localizedCaseInsensitiveContains(appState.searchText)
        }
        #else
        return todayTasks
        #endif
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
                        selectedTask: $appState.selectedTask,
                        expandedTask: $appState.expandedTask,
                        isSelected: selection == task.id
                    )
                    .tag(task.id)
                    .listRowInsets(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4))
                    .listRowSeparator(.hidden)
                }
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
}
