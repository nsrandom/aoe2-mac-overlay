//
//  ContentView.swift
//  AoE Overlay
//
//  Created by Asif Sheikh on 6/29/26.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("windowOpacity") private var windowOpacity: Double = 0.5
    
    // Hardcoded tactical data for demonstration
    let activeCiv = "Mongols"
    let playerElo = 1450
    let opponentElo = 1420
    let opponentCiv = "Britons"
    
    var body: some View {
        VStack(spacing: 16) {
            // Header Bar
            HStack {
                Image(systemName: "shield.fill")
                    .foregroundColor(Color(red: 0.85, green: 0.65, blue: 0.2)) // Gold
                    .font(.system(size: 20))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("AoE II Overlay")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text("Arabia Match Active")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Status/Phase indicator
                Text("Castle Age")
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(red: 0.85, green: 0.65, blue: 0.2).opacity(0.2))
                    .foregroundColor(Color(red: 0.85, green: 0.65, blue: 0.2))
                    .cornerRadius(6)
            }
            .padding(.horizontal, 4)
            
            Divider()
                .background(Color.white.opacity(0.15))
            
            // Match Players info
            VStack(spacing: 8) {
                HStack {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 8, height: 8)
                        Text("You (\(activeCiv))")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Text("ELO: \(playerElo)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                HStack {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                        Text("Opponent (\(opponentCiv))")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Text("ELO: \(opponentElo)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(10)
            .background(Color.white.opacity(0.05))
            .cornerRadius(8)
            
            // Checklist Area
            VStack(alignment: .leading, spacing: 8) {
                Text("Tactical Build Steps")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0.85, green: 0.65, blue: 0.2))
                    .textCase(.uppercase)
                
                BuildStepView(title: "6 Villagers to Sheep", isDone: true)
                BuildStepView(title: "4 Villagers to Wood", isDone: true)
                BuildStepView(title: "Loom researched", isDone: true)
                BuildStepView(title: "Next: Click up to Imperial Age", isDone: false, isCurrent: true)
            }
            .padding(10)
            .background(Color.white.opacity(0.05))
            .cornerRadius(8)
            
            // Dynamic window opacity control
            VStack(spacing: 6) {
                HStack {
                    Image(systemName: "circle.lefthalf.filled")
                        .foregroundColor(.gray)
                    Text("Window Opacity")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                    Text("\(Int(windowOpacity * 100))%")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                Slider(value: $windowOpacity, in: 0.1...1.0)
                    .tint(Color(red: 0.85, green: 0.65, blue: 0.2))
            }
            .padding(10)
            .background(Color.white.opacity(0.05))
            .cornerRadius(8)
        }
        .padding(18)
        .frame(width: 320)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.08, green: 0.08, blue: 0.12).opacity(0.85))
                .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
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

struct BuildStepView: View {
    let title: String
    let isDone: Bool
    var isCurrent: Bool = false
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isDone ? "checkmark.circle.fill" : (isCurrent ? "arrow.right.circle.fill" : "circle"))
                .foregroundColor(isDone ? Color.green : (isCurrent ? Color(red: 0.85, green: 0.65, blue: 0.2) : Color.gray))
                .font(.system(size: 14))
            
            Text(title)
                .font(.caption)
                .strikethrough(isDone)
                .foregroundColor(isDone ? .gray : (isCurrent ? .white : .gray.opacity(0.8)))
                .fontWeight(isCurrent ? .medium : .regular)
            
            Spacer()
        }
    }
}

struct CounterBadge: View {
    let unit: String
    let counter: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(unit)
                .font(.system(size: 10))
                .foregroundColor(.gray)
            Text(counter)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.03))
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

