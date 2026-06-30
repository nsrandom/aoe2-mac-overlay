//
//  SettingsView.swift
//  AoE Overlay
//
//  Created by Antigravity on 6/30/26.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("windowOpacity") private var windowOpacity: Double = 0.5
    @AppStorage("maxStepsPerPage") private var maxStepsPerPage: Int = 5
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Overlay Settings")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
                .background(Color.white.opacity(0.15))
            
            // Dynamic window opacity control
            VStack(spacing: 6) {
                HStack {
                    Image(systemName: "circle.lefthalf.filled")
                        .foregroundColor(.gray)
                    Text("Overlay Opacity")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Spacer()
                    Text("\(Int(windowOpacity * 100))%")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                Slider(value: $windowOpacity, in: 0.1...1.0)
                    .tint(Theme.primaryGold)
            }
            .padding(12)
            .background(Color.white.opacity(0.05))
            .cornerRadius(8)
            
            // Max Steps per page setting
            VStack(spacing: 6) {
                HStack {
                    Image(systemName: "list.number")
                        .foregroundColor(.gray)
                    Stepper(value: $maxStepsPerPage, in: 2...10) {
                        HStack(spacing: 4) {
                            Text("Steps Per Page:")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text("\(maxStepsPerPage)")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .padding(12)
            .background(Color.white.opacity(0.05))
            .cornerRadius(8)
        }
        .padding(20)
        .frame(width: 300, height: 220)
        .background(Color(red: 0.08, green: 0.08, blue: 0.12))
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
