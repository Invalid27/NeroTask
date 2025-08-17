// Models/SidebarItem.swift
import SwiftUI

#if os(macOS)
enum SidebarItem: String, CaseIterable, Identifiable, Hashable {
    case inbox = "Inbox"
    case today = "Today"
    case upcoming = "Upcoming"
    case anytime = "Anytime"
    case completed = "Completed"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .inbox: return "tray.fill"
        case .today: return "star.fill"
        case .upcoming: return "calendar"
        case .anytime: return "archivebox.fill"
        case .completed: return "checkmark.circle.fill"
        }
    }
}
#endif
