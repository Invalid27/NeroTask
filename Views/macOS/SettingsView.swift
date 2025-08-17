// Views/macOS/SettingsView.swift
import SwiftUI

#if os(macOS)
struct SettingsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Settings")
                .font(.largeTitle)
            
            Text("Settings will be added here later")
                .foregroundColor(.secondary)
            
            Text("Planned features:")
                .font(.headline)
            
            VStack(alignment: .leading) {
                Text("• Theme customization")
                Text("• Keyboard shortcuts")
                Text("• Default due times")
                Text("• Notification preferences")
            }
            .foregroundColor(.secondary)
        }
        .padding(40)
        .frame(width: 450, height: 300)
    }
}
#endif
