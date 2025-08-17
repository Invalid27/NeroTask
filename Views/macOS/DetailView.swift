// Views/macOS/DetailView.swift
import SwiftUI

#if os(macOS)
struct DetailView: View {
    @EnvironmentObject var appState: AppState
    
    @ViewBuilder
    var body: some View {
        ZStack {
            switch appState.selectedView {
            case .inbox:
                InboxView()
            case .today:
                TodayView()
            case .upcoming:
                UpcomingView()
            case .anytime:
                AnytimeView()
            case .completed:
                CompletedView()
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
