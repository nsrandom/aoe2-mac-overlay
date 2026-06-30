//
//  BuildStepsView.swift
//  AoE Overlay
//
//  Created by Antigravity on 6/30/26.
//

import SwiftUI

struct BuildStepsView: View {
    let buildSteps: [String]
    let currentStepIndex: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tactical Build Steps")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(Theme.primaryGold)
                .textCase(.uppercase)
            
            ForEach(0..<buildSteps.count, id: \.self) { index in
                BuildStepView(
                    title: buildSteps[index],
                    isDone: index < currentStepIndex,
                    isCurrent: index == currentStepIndex
                )
            }
        }
        .padding(10)
        .background(Color.white.opacity(0.05))
        .cornerRadius(8)
    }
}

struct BuildStepView: View {
    let title: String
    let isDone: Bool
    var isCurrent: Bool = false
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isDone ? "checkmark.circle.fill" : (isCurrent ? "arrow.right.circle.fill" : "circle"))
                .foregroundColor(isDone ? Color.green : (isCurrent ? Theme.primaryGold : Color.gray))
                .font(.system(size: Theme.buildStepIconSize))
            
            Text(title)
                .font(.caption)
                .strikethrough(isDone)
                .foregroundColor(isDone ? .gray : (isCurrent ? .white : .gray.opacity(0.8)))
                .fontWeight(isCurrent ? .medium : .regular)
            
            Spacer()
        }
    }
}

struct BuildStepsView_Previews: PreviewProvider {
    static var previews: some View {
        BuildStepsView(
            buildSteps: ["Step 1", "Step 2"],
            currentStepIndex: 1
        )
        .padding()
        .background(Color(red: 0.08, green: 0.08, blue: 0.12))
    }
}
