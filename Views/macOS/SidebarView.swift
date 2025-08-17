// Views/macOS/SidebarView.swift
import SwiftUI
import SwiftData

#if os(macOS)
struct SidebarView: View {
    @Binding var selection: SidebarItem?
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appState: AppState
    
    @Query(filter: #Predicate<Task> { !$0.isCompleted })
    private var incompleteTasks: [Task]
    
    @Query(filter: #Predicate<Task> { $0.isToday && !$0.isCompleted })
    private var todayTasks: [Task]
    
    @Query(filter: #Predicate<Task> { task in
        !task.isCompleted && task.dueDate != nil
    })
    private var upcomingTasks: [Task]
    
    @Query(filter: #Predicate<Task> { task in
        !task.isCompleted && task.dueDate == nil && !task.isToday
    })
    private var anytimeTasks: [Task]
    
    @Query(filter: #Predicate<Task> { $0.isCompleted })
    private var completedTasks: [Task]
    
    var body: some View {
        List(selection: $selection) {
            Section {
                ForEach(SidebarItem.allCases) { item in
                    NavigationLink(value: item) {
                        Label {
                            HStack {
                                Text(item.rawValue)
                                    .font(.system(size: 13, weight: .medium))
                                Spacer()
                                if let count = taskCount(for: item), count > 0 {
                                    Text("\(count)")
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 1)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(4)
                                }
                            }
                        } icon: {
                            Image(systemName: item.icon)
                                .font(.system(size: 14))
                        }
                    }
                }
            }
            
            Section("Quick Actions") {
                Button(action: { appState.showingQuickEntry = true }) {
                    Label("New Task", systemImage: "plus.circle")
                        .font(.system(size: 13))
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(.accentColor)
            }
        }
        .listStyle(SidebarListStyle())
        .navigationTitle("Tasks")
        .frame(minWidth: 200)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: toggleSidebar) {
                    Image(systemName: "sidebar.left")
                        .font(.system(size: 12))
                }
            }
        }
    }
    
    private func taskCount(for item: SidebarItem) -> Int? {
        switch item {
        case .inbox:
            return incompleteTasks.count
        case .today:
            return todayTasks.count
        case .upcoming:
            return upcomingTasks.count
        case .anytime:
            return anytimeTasks.count
        case .completed:
            return completedTasks.count
        }
    }
    
    private func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
}
#endif
