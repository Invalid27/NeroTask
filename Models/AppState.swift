// Models/AppState.swift
import SwiftUI
import Combine

@MainActor
class AppState: ObservableObject {
    @Published var selectedView: SidebarItem? = .inbox
    @Published var searchText: String = ""
    @Published var selectedTask: Task?
    @Published var showingQuickEntry: Bool = false
    @Published var expandedTask: Task?
}
