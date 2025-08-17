// Models/SidebarItem.swift
import SwiftUI

#if os(macOS)
enum SidebarItem: String, CaseIterable, Identifiable {
    case inbox = "Inbox"
    case today = "Today"
    case upcoming = "Upcoming"
    case anytime = "Anytime"
    case completed = "Completed"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .inbox: return "tray"
        case .today: return "star"
        case .upcoming: return "calendar"
        case .anytime: return "archivebox"
        case .completed: return "checkmark.circle"
        }
    }
}
#endif
