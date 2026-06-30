//
//  HeaderView.swift
//  AoE Overlay
//
//  Created by Antigravity on 6/30/26.
//

import SwiftUI

struct HeaderView: View {
    let buildSteps: [String]
    @Binding var currentStepIndex: Int
    
    var body: some View {
        HStack {
            HStack(spacing: 4) {
                Button(action: {
                    // Document action placeholder
                }) {
                    Image(systemName: "doc.text")
                        .font(.system(size: Theme.iconButtonSize, weight: .bold))
                        .foregroundColor(Theme.primaryGold)
                        .padding(8)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    // Settings action placeholder
                }) {
                    Image(systemName: "gearshape")
                        .font(.system(size: Theme.iconButtonSize, weight: .bold))
                        .foregroundColor(Theme.primaryGold)
                        .padding(8)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            
            Spacer()
            
            // Build Order Step Navigation (First / Prev / Next Buttons)
            HStack(spacing: 4) {
                // First Step Button
                Button(action: {
                    currentStepIndex = 0
                }) {
                    Image(systemName: "backward.end.fill")
                        .font(.system(size: Theme.iconButtonSize, weight: .bold))
                        .foregroundColor(Theme.primaryGold)
                        .padding(8)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(currentStepIndex == 0)
                .opacity(currentStepIndex == 0 ? 0.35 : 1.0)
                
                // Previous Step Button
                Button(action: {
                    if currentStepIndex > 0 {
                        currentStepIndex -= 1
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: Theme.iconButtonSize, weight: .bold))
                        .foregroundColor(Theme.primaryGold)
                        .padding(8)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(currentStepIndex == 0)
                .opacity(currentStepIndex == 0 ? 0.35 : 1.0)
                
                // Next Step Button
                Button(action: {
                    if currentStepIndex < buildSteps.count {
                        currentStepIndex += 1
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: Theme.iconButtonSize, weight: .bold))
                        .foregroundColor(Theme.primaryGold)
                        .padding(8)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(currentStepIndex == buildSteps.count)
                .opacity(currentStepIndex == buildSteps.count ? 0.35 : 1.0)
            }
        }
        .padding(.horizontal, 4)
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView(
            buildSteps: ["Step 1", "Step 2"],
            currentStepIndex: .constant(0)
        )
        .padding()
        .background(Color(red: 0.08, green: 0.08, blue: 0.12))
    }
}
