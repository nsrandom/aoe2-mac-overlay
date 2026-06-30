//
//  ContentView.swift
//  AoE Overlay
//
//  Created by Asif Sheikh on 6/29/26.
//

import SwiftUI

struct ContentView: View {
    // Hardcoded tactical data for ELO demonstration
    let activeCiv = "Mongols"
    let playerElo = 1450
    let opponentElo = 1420
    let opponentCiv = "Britons"
    
    // AppStorage tracking for the last loaded build order name
    @AppStorage("lastLoadedBuildOrder") private var lastLoadedBuildOrder: String = ""
    
    // Dynamic active build order state
    @State private var buildOrder: BuildOrder? = nil
    @State private var currentStepIndex = 0
    @State private var showMatchup = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Header Bar
            HeaderView(
                buildOrder: buildOrder,
                currentStepIndex: $currentStepIndex,
                showMatchup: $showMatchup,
                onLoadBuildOrder: { loadedBuildOrder in
                    self.buildOrder = loadedBuildOrder
                }
            )
            
            Divider()
                .background(Color.white.opacity(0.15))
            
            if showMatchup {
                // Match Players info
                MatchupView(
                    activeCiv: activeCiv,
                    playerElo: playerElo,
                    opponentCiv: opponentCiv,
                    opponentElo: opponentElo
                )
            }
            
            if let buildOrder = buildOrder {
                // Build Order Page Header (Civilization / Description)
                VStack(alignment: .leading, spacing: 2) {
                    Text(buildOrder.name)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 4)
                
                // Checklist Area (Paging built in)
                BuildStepsView(
                    buildOrder: buildOrder,
                    currentStepIndex: currentStepIndex
                )
            } else {
                // Placeholder when no build order is loaded
                VStack(spacing: 8) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 24))
                        .foregroundColor(.gray.opacity(0.6))
                    
                    Text("Load a build order to display here")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 40)
            }
        }
        .padding(18)
        .frame(width: 320)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(red: 0.08, green: 0.08, blue: 0.12).opacity(0.85))
                .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(red: 0.85, green: 0.65, blue: 0.2).opacity(0.5),
                            Color(red: 0.85, green: 0.65, blue: 0.2).opacity(0.1),
                            Color.white.opacity(0.1),
                            Color(red: 0.85, green: 0.65, blue: 0.2).opacity(0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .onAppear {
            loadInitialBuildOrder()
        }
    }
    
    private func loadInitialBuildOrder() {
        guard !lastLoadedBuildOrder.isEmpty else {
            self.buildOrder = nil
            return
        }
        
        let paths = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        guard let appSupport = paths.first?.appendingPathComponent("com.nsrandom.AoE-Overlay") else {
            self.buildOrder = nil
            return
        }
        
        let fileURL = appSupport.appendingPathComponent("build_orders/\(lastLoadedBuildOrder)")
        
        if FileManager.default.fileExists(atPath: fileURL.path),
           let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode(BuildOrder.self, from: data) {
            self.buildOrder = decoded
        } else {
            // Revert back if file path is missing or corrupted
            self.lastLoadedBuildOrder = ""
            self.buildOrder = nil
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
