// Views/macOS/DetailView.swift
import SwiftUI

#if os(macOS)
struct DetailView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Group {
            switch appState.selectedView {
            case .inbox:
                InboxView(searchText: appState.searchText, selectedTask: $appState.selectedTask)
            case .today:
                TodayView(searchText: appState.searchText, selectedTask: $appState.selectedTask)
            case .upcoming:
                UpcomingView(searchText: appState.searchText, selectedTask: $appState.selectedTask)
            case .anytime:
                AnytimeView(searchText: appState.searchText, selectedTask: $appState.selectedTask)
            case .completed:
                CompletedView(searchText: appState.searchText, selectedTask: $appState.selectedTask)
            case .none:
                Text("Select a view from the sidebar")
                    .foregroundColor(.secondary)
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { appState.showingQuickEntry = true }) {
                    Image(systemName: "plus")
                }
                .keyboardShortcut("n", modifiers: .command)
            }
        }
    }
}
#endif
