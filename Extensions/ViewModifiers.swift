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
                    .stroke(borderColor, lineWidth: borderWidth)
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
            return Color(NSColor.controlBackgroundColor).opacity(0.8)
        } else if isSelected {
            // Made selection more visible
            return Color.accentColor.opacity(0.15)
        } else if isHovering {
            return Color.gray.opacity(0.08)
        }
        #endif
        return Color.clear
    }
    
    private var borderColor: Color {
        #if os(macOS)
        if isExpanded {
            return Color.accentColor.opacity(0.4)
        } else if isSelected {
            // Made border more visible when selected
            return Color.accentColor.opacity(0.5)
        }
        #endif
        return Color.clear
    }
    
    private var borderWidth: CGFloat {
        #if os(macOS)
        if isSelected || isExpanded {
            return 1.0  // Slightly thicker border for better visibility
        }
        #endif
        return 0.5
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
