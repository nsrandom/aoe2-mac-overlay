//
//  CachedImage.swift
//  AoE Overlay
//
//  Created by Antigravity on 6/30/26.
//

import SwiftUI

struct CachedImage: View {
    let path: String
    var width: CGFloat? = nil
    var height: CGFloat? = nil
    var contentMode: ContentMode = .fit
    
    @State private var image: NSImage? = nil
    @State private var isLoading = false
    @State private var hasFailed = false
    
    var body: some View {
        Group {
            if let image = image {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else if isLoading {
                ProgressView()
                    .controlSize(.small)
            } else if hasFailed {
                Image(systemName: "questionmark.square.dashed")
                    .foregroundColor(.gray)
            } else {
                Color.clear
            }
        }
        .frame(width: width, height: height)
        .task(id: path) {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        guard !path.isEmpty else { return }
        
        isLoading = true
        hasFailed = false
        
        if let localURL = await AssetManager.shared.fetchAsset(path: path) {
            // Load and deserialize the image on a background thread
            let loadedImage = await Task.detached(priority: .userInitiated) { () -> NSImage? in
                return NSImage(contentsOf: localURL)
            }.value
            
            await MainActor.run {
                self.image = loadedImage
                self.isLoading = false
                self.hasFailed = loadedImage == nil
            }
        } else {
            await MainActor.run {
                self.isLoading = false
                self.hasFailed = true
            }
        }
    }
}
