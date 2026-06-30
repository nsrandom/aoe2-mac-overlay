//
//  AoE_OverlayApp.swift
//  AoE Overlay
//
//  Created by Asif Sheikh on 6/29/26.
//

import SwiftUI
import AppKit

struct WindowAccessor: NSViewRepresentable {
    var onChange: (NSWindow) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                onChange(window)
            }
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        if let window = nsView.window {
            onChange(window)
        }
    }
}

struct WindowConfigurationModifier: ViewModifier {
    @AppStorage("windowOpacity") private var windowOpacity: Double = 0.5

    func body(content: Content) -> some View {
        content
            .background(WindowAccessor { window in
                // Set the window background behavior
                window.isOpaque = false
                window.backgroundColor = .clear
                
                // Allow dragging the window from any transparent background area
                window.isMovableByWindowBackground = true
                
                // Apply the opacity setting (defaults to 0.5)
                window.alphaValue = CGFloat(windowOpacity)
                
                // Enable shadow for the custom window shape
                window.hasShadow = true
                
                // Custom titlebar appearance
                window.titlebarAppearsTransparent = true
                window.titleVisibility = .hidden
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
                .frame(width: 320, height: 460)
                .windowConfiguration()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}


