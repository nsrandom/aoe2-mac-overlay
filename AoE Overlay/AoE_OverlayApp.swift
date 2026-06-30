//
//  AoE_OverlayApp.swift
//  AoE Overlay
//
//  Created by Asif Sheikh on 6/29/26.
//

import SwiftUI
import AppKit

struct WindowAccessor: NSViewRepresentable {
    let opacity: Double
    var onChange: (NSWindow, Double) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                onChange(window, opacity)
            }
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        if let window = nsView.window {
            onChange(window, opacity)
        }
    }
}

struct WindowConfigurationModifier: ViewModifier {
    @AppStorage("windowOpacity") private var windowOpacity: Double = 0.5

    func body(content: Content) -> some View {
        content
            .background(WindowAccessor(opacity: windowOpacity) { window, opacity in
                // Set the window background behavior
                window.isOpaque = false
                window.backgroundColor = .clear
                
                // Allow dragging the window from any transparent background area
                window.isMovableByWindowBackground = true
                
                // Apply the opacity setting
                window.alphaValue = CGFloat(opacity)
                
                // Enable shadow for the custom window shape
                window.hasShadow = false
                
                // Remove the titlebar separator line and extend content under the titlebar
                window.styleMask.insert(.fullSizeContentView)
                window.titlebarSeparatorStyle = .none
                
                // Remove the titled style mask to make it borderless
                window.styleMask.remove(.titled)
                
                // Custom titlebar appearance
                window.titlebarAppearsTransparent = true
                window.titleVisibility = .hidden
                
                // Hide traffic light buttons (close, minimize, zoom)
                window.standardWindowButton(.closeButton)?.isHidden = true
                window.standardWindowButton(.miniaturizeButton)?.isHidden = true
                window.standardWindowButton(.zoomButton)?.isHidden = true
            })
    }
}

extension View {
    func windowConfiguration() -> some View {
        self.modifier(WindowConfigurationModifier())
    }
}

@main
struct AoE_OverlayApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .windowConfiguration()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        
        Window("Settings", id: "settings") {
            SettingsView()
        }
        .windowResizability(.contentSize)
    }
}
