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
    @AppStorage("lastLoadedBuildOrder") private var lastLoadedBuildOrder: String = "fc-lancers.json"
    
    // Dynamic active build order state
    @State private var buildOrder: BuildOrder = .defaultBuildOrder
    @State private var currentStepIndex = 0
    @State private var showMatchup = true
    
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
            
            // Build Order Page Header (Civilization / Description)
            VStack(alignment: .leading, spacing: 2) {
                Text(buildOrder.name)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Text("Civ: \(buildOrder.civilization)")
                        .font(.caption2)
                        .foregroundColor(Theme.primaryGold)
                    
                    Text("•")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    
                    Text("By \(buildOrder.author)")
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 4)
            
            // Checklist Area (Paging built in)
            BuildStepsView(
                buildOrder: buildOrder,
                currentStepIndex: currentStepIndex
            )
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
        if lastLoadedBuildOrder == "fc-lancers.json" {
            self.buildOrder = .defaultBuildOrder
            return
        }
        
        let paths = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        guard let appSupport = paths.first?.appendingPathComponent("com.nsrandom.AoE-Overlay") else {
            self.buildOrder = .defaultBuildOrder
            return
        }
        
        let fileURL = appSupport.appendingPathComponent("build_orders/\(lastLoadedBuildOrder)")
        
        if FileManager.default.fileExists(atPath: fileURL.path),
           let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode(BuildOrder.self, from: data) {
            self.buildOrder = decoded
        } else {
            // Revert back if file path is missing or corrupted
            self.lastLoadedBuildOrder = "fc-lancers.json"
            self.buildOrder = .defaultBuildOrder
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
