//
//  ContentView.swift
//  AoE Overlay
//
//  Created by Asif Sheikh on 6/29/26.
//

import SwiftUI

struct ContentView: View {
    // Hardcoded tactical data for demonstration
    let activeCiv = "Mongols"
    let playerElo = 1450
    let opponentElo = 1420
    let opponentCiv = "Britons"
    
    // Build steps and navigation tracking
    let buildSteps = [
        "6 Villagers to Sheep",
        "4 Villagers to Wood",
        "Loom researched",
        "Click up to Imperial Age"
    ]
    @State private var currentStepIndex = 3 // Starting step for demonstration
    @State private var showMatchup = true
    
    var body: some View {
        VStack(spacing: 16) {
            // Header Bar
            HeaderView(buildSteps: buildSteps, currentStepIndex: $currentStepIndex, showMatchup: $showMatchup)
            
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
            
            // Checklist Area
            BuildStepsView(buildSteps: buildSteps, currentStepIndex: currentStepIndex)
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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

