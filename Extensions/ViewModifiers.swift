import SwiftUI

// Environment key for hover state
private struct HoveringKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var isHovering: Bool {
        get { self[HoveringKey.self] }
        set { self[HoveringKey.self] = newValue }
    }
}

// Task row styling modifier
struct TaskRowStyling: ViewModifier {
    let isSelected: Bool
    let isExpanded: Bool
    @State private var isHovering = false
    
    func body(content: Content) -> some View {
        content
            #if os(macOS)
            .background(
                RoundedRectangle(cornerRadius: 3)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .stroke(borderColor, lineWidth: 0.5)
            )
            .onHover { hovering in
                isHovering = hovering
            }
            .environment(\.isHovering, isHovering)
            #endif
    }
    
    private var backgroundColor: Color {
        #if os(macOS)
        if isExpanded {
            return Color(NSColor.controlBackgroundColor).opacity(0.5)
        } else if isSelected {
            return Color.accentColor.opacity(0.1)
        } else if isHovering {
            return Color.gray.opacity(0.05)
        }
        #endif
        return Color.clear
    }
    
    private var borderColor: Color {
        #if os(macOS)
        if isExpanded || isSelected {
            return Color.accentColor.opacity(0.3)
        }
        #endif
        return Color.clear
    }
}

// Compact list row modifier
struct CompactListRow: ViewModifier {
    func body(content: Content) -> some View {
        content
            .listRowInsets(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4))
            .listRowSeparator(.hidden)
    }
}

// Extension to make modifiers easy to use
extension View {
    func taskRowStyling(isSelected: Bool, isExpanded: Bool) -> some View {
        self.modifier(TaskRowStyling(isSelected: isSelected, isExpanded: isExpanded))
    }
    
    func compactListRow() -> some View {
        self.modifier(CompactListRow())
    }
}
