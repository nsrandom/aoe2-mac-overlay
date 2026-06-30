//
//  MatchupView.swift
//  AoE Overlay
//
//  Created by Antigravity on 6/30/26.
//

import SwiftUI

struct MatchupView: View {
    let activeCiv: String
    let playerElo: Int
    let opponentCiv: String
    let opponentElo: Int
    
    var body: some View {
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
    }
}

struct MatchupView_Previews: PreviewProvider {
    static var previews: some View {
        MatchupView(
            activeCiv: "Mongols",
            playerElo: 1450,
            opponentCiv: "Britons",
            opponentElo: 1420
        )
        .padding()
        .background(Color(red: 0.08, green: 0.08, blue: 0.12))
    }
}
