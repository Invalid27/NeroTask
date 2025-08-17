// Views/macOS/DetailView.swift
import SwiftUI

#if os(macOS)
struct DetailView: View {
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        Group {
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
                EmptyDetailView()
            default:
                EmptyDetailView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.3))
    }
}

struct EmptyDetailView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "sidebar.left")
                .font(.system(size: 48))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue.opacity(0.5), .purple.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("Select a view from the sidebar")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
#endif
