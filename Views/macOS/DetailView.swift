// Views/macOS/DetailView.swift
import SwiftUI

#if os(macOS)
struct DetailView: View {
    let selectedView: SidebarItem?
    @Binding var searchText: String
    @Binding var selectedTask: Task?
    @Binding var showingQuickEntry: Bool
    
    var body: some View {
        Group {
            switch selectedView {
            case .inbox:
                InboxView(searchText: searchText, selectedTask: $selectedTask)
            case .today:
                TodayView(searchText: searchText, selectedTask: $selectedTask)
            case .upcoming:
                UpcomingView(searchText: searchText, selectedTask: $selectedTask)
            case .anytime:
                AnytimeView(searchText: searchText, selectedTask: $selectedTask)
            case .completed:
                CompletedView(searchText: searchText, selectedTask: $selectedTask)
            case .none:
                Text("Select a view from the sidebar")
                    .foregroundColor(.secondary)
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingQuickEntry = true }) {
                    Image(systemName: "plus")
                }
                .keyboardShortcut("n", modifiers: .command)
            }
        }
    }
}
#endif
