//
//  AssetManager.swift
//  AoE Overlay
//
//  Created by Antigravity on 6/30/26.
//

import Foundation
import Cocoa

actor AssetManager {
    static let shared = AssetManager()
    
    private let baseRemoteURLString = "https://raw.githubusercontent.com/CraftySalamander/RTS_Overlay/master/docs/assets/aoe2/"
    private let cacheDirectoryURL: URL
    private var activeDownloads: [String: Task<URL, Error>] = [:]
    private let urlSession: URLSession
    
    private init() {
        let paths = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let appSupport = paths.first!.appendingPathComponent("com.nsrandom.AoE-Overlay")
        self.cacheDirectoryURL = appSupport.appendingPathComponent("assets")
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 5.0
        config.timeoutIntervalForResource = 10.0
        self.urlSession = URLSession(configuration: config)
        
        // Ensure cache directory exists
        do {
            try FileManager.default.createDirectory(at: self.cacheDirectoryURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Failed to create assets directory: \(error)")
        }
    }
    
    /// Normalizes a path by replacing .png, .jpg, or .jpeg extensions with .webp
    private func normalizePath(_ path: String) -> String {
        let cleanPath = path.trimmingCharacters(in: .whitespacesAndNewlines)
        let lower = cleanPath.lowercased()
        if lower.hasSuffix(".png") {
            return String(cleanPath.dropLast(4)) + ".webp"
        } else if lower.hasSuffix(".jpg") {
            return String(cleanPath.dropLast(4)) + ".webp"
        } else if lower.hasSuffix(".jpeg") {
            return String(cleanPath.dropLast(5)) + ".webp"
        }
        return cleanPath
    }
    
    /// Returns the local cached URL for a given relative asset path.
    func cachePath(for path: String) -> URL {
        let normalized = normalizePath(path)
        return cacheDirectoryURL.appendingPathComponent(normalized)
    }
    
    /// Asynchronously fetches an asset, downloading it from the remote repository if not cached locally.
    /// Returns the local cached URL on success, or nil on failure.
    func fetchAsset(path: String) async -> URL? {
        let normalized = normalizePath(path)
        guard !normalized.isEmpty else { return nil }
        
        let localURL = cachePath(for: normalized)
        
        // Check if file is already cached on disk
        if FileManager.default.fileExists(atPath: localURL.path) {
            return localURL
        }
        
        // Check if there is an active download task for this path
        if let activeTask = activeDownloads[normalized] {
            do {
                return try await activeTask.value
            } catch {
                return nil
            }
        }
        
        // Start a new download task
        let downloadTask = Task<URL, Error> {
            let remoteURLString = baseRemoteURLString + normalized
            guard let remoteURL = URL(string: remoteURLString) else {
                throw URLError(.badURL)
            }
            
            // Ensure parent directory exists locally
            let parentDir = localURL.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: parentDir, withIntermediateDirectories: true, attributes: nil)
            
            let (tempURL, response) = try await urlSession.download(from: remoteURL)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
            
            // Move downloaded file to local cache path
            if FileManager.default.fileExists(atPath: localURL.path) {
                try? FileManager.default.removeItem(at: localURL)
            }
            try FileManager.default.moveItem(at: tempURL, to: localURL)
            return localURL
        }
        
        activeDownloads[normalized] = downloadTask
        
        defer {
            // Clean up download registry when finished
            Task {
                await removeActiveDownload(path: normalized)
            }
        }
        
        do {
            let resultURL = try await downloadTask.value
            return resultURL
        } catch {
            print("Failed to download asset \(normalized): \(error)")
            return nil
        }
    }
    
    private func removeActiveDownload(path: String) {
        activeDownloads.removeValue(forKey: path)
    }
}
