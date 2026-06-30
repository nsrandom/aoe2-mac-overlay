//
//  RichTextView.swift
//  AoE Overlay
//
//  Created by Antigravity on 6/30/26.
//

import SwiftUI

struct RichTextView: View {
    let note: String
    
    @AppStorage("buildStepsIconSize") private var iconSize: Double = 18.0
    @AppStorage("buildStepsTextSize") private var textSize: Double = 12.0
    
    @State private var loadedImages: [String: NSImage] = [:]
    @State private var parsedSegments: [Segment] = []
    
    enum Segment {
        case text(String)
        case image(String)
    }
    
    var body: some View {
        richText
            .font(.system(size: CGFloat(textSize)))
            .foregroundColor(.white)
            .onAppear {
                parseAndLoad()
            }
            .onChange(of: note) { _ in
                parseAndLoad()
            }
            .onChange(of: iconSize) { _ in
                loadedImages.removeAll()
                parseAndLoad()
            }
    }
    
    private var richText: Text {
        var result = Text("")
        for segment in parsedSegments {
            switch segment {
            case .text(let text):
                result = result + Text(text)
            case .image(let path):
                if let nsImage = loadedImages[path] {
                    result = result + Text(Image(nsImage: nsImage))
                } else {
                    // System fallback symbol while loading
                    result = result + Text(Image(systemName: "photo"))
                        .foregroundColor(.gray.opacity(0.5))
                }
            }
        }
        return result
    }
    
    private func parseAndLoad() {
        let parts = note.components(separatedBy: "@")
        var segments: [Segment] = []
        
        for (index, part) in parts.enumerated() {
            if part.isEmpty { continue }
            if index % 2 == 1 {
                segments.append(.image(part))
            } else {
                segments.append(.text(part))
            }
        }
        
        self.parsedSegments = segments
        
        // Trigger downloads for each image segment
        for segment in segments {
            if case .image(let path) = segment {
                // Skip if already loaded
                guard loadedImages[path] == nil else { continue }
                
                Task {
                    if let localURL = await AssetManager.shared.fetchAsset(path: path) {
                        let nsImage = await Task.detached(priority: .userInitiated) { () -> NSImage? in
                            guard let img = NSImage(contentsOf: localURL) else { return nil }
                            // Force resize to match user configured size
                            img.size = NSSize(width: CGFloat(iconSize), height: CGFloat(iconSize))
                            return img
                        }.value
                        
                        if let nsImage = nsImage {
                            await MainActor.run {
                                self.loadedImages[path] = nsImage
                            }
                        }
                    }
                }
            }
        }
    }
}

struct RichTextView_Previews: PreviewProvider {
    static var previews: some View {
        RichTextView(note: "Create 6 @resource/MaleVillDE.jpg@ on @animal/Sheep_aoe2DE.png@")
            .padding()
            .background(Color.black)
    }
}
