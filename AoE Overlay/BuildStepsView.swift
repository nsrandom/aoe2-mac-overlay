//
//  BuildStepsView.swift
//  AoE Overlay
//
//  Created by Antigravity on 6/30/26.
//

import SwiftUI

struct BuildStepsView: View {
    @AppStorage("maxStepsPerPage") private var maxStepsPerPage: Int = 5
    
    let buildOrder: BuildOrder
    let currentStepIndex: Int
    
    var body: some View {
        let pages = buildOrder.computePages(maxPerPage: maxStepsPerPage)
        let pageIndex = activePageIndex(pages: pages)
        
        VStack(alignment: .leading, spacing: 10) {
            // Header: Active Age and Page indicators
            HStack {
                Text(currentAgeName(pages: pages, pageIndex: pageIndex))
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.primaryGold)
                    .textCase(.uppercase)
                
                Spacer()
                
                if pages.count > 1 {
                    Text("Page \(pageIndex + 1) of \(pages.count)")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            
            if pages.isEmpty {
                Text("No steps available")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                let activePageSteps = pages[pageIndex]
                
                VStack(spacing: 8) {
                    ForEach(activePageSteps) { step in
                        let stepIndex = buildOrder.buildOrder.firstIndex(where: { $0.id == step.id }) ?? 0
                        let isDone = stepIndex < currentStepIndex
                        let isCurrent = stepIndex == currentStepIndex
                        
                        BuildStepRow(
                            step: step,
                            isDone: isDone,
                            isCurrent: isCurrent
                        )
                    }
                }
            }
        }
        .padding(10)
        .background(Color.white.opacity(0.05))
        .cornerRadius(8)
    }
    
    private func activePageIndex(pages: [[BuildOrderStep]]) -> Int {
        guard currentStepIndex < buildOrder.buildOrder.count else { return 0 }
        let activeStep = buildOrder.buildOrder[currentStepIndex]
        for (index, page) in pages.enumerated() {
            if page.contains(where: { $0.id == activeStep.id }) {
                return index
            }
        }
        return 0
    }
    
    private func currentAgeName(pages: [[BuildOrderStep]], pageIndex: Int) -> String {
        guard pageIndex < pages.count, let firstStep = pages[pageIndex].first else {
            return "Dark Age"
        }
        switch firstStep.age {
        case 1: return "Dark Age"
        case 2: return "Feudal Age"
        case 3: return "Castle Age"
        case 4: return "Imperial Age"
        default: return "Unknown Age"
        }
    }
}

struct BuildStepRow: View {
    let step: BuildOrderStep
    let isDone: Bool
    let isCurrent: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top, spacing: 8) {
                // Status Checkmark / Arrow indicator
                Image(systemName: isDone ? "checkmark.circle.fill" : (isCurrent ? "arrow.right.circle.fill" : "circle"))
                    .foregroundColor(isDone ? Color.green : (isCurrent ? Theme.primaryGold : Color.gray))
                    .font(.system(size: Theme.buildStepIconSize))
                    .padding(.top, 2)
                
                VStack(alignment: .leading, spacing: 4) {
                    // Step Notes
                    if !step.notes.isEmpty {
                        ForEach(step.notes, id: \.self) { note in
                            RichTextView(note: note)
                                .strikethrough(isDone)
                                .foregroundColor(isDone ? .gray : (isCurrent ? .white : .gray.opacity(0.8)))
                        }
                    } else {
                        Text("Villager Count: \(step.villagerCount)")
                            .font(.caption)
                            .foregroundColor(isDone ? .gray : (isCurrent ? .white : .gray.opacity(0.8)))
                    }
                    
                    // Resource Assignments Grid
                    ResourceGridView(resources: step.resources)
                        .opacity(isDone ? 0.6 : (isCurrent ? 1.0 : 0.7))
                }
                
                Spacer()
                
                // Population Counter badge
                Text("\(step.villagerCount)")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(isCurrent ? .white : .gray)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(Color.white.opacity(isCurrent ? 0.15 : 0.05))
                    .cornerRadius(4)
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.white.opacity(isCurrent ? 0.06 : 0.02))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(
                    isCurrent ? Theme.primaryGold.opacity(0.5) : Color.clear,
                    lineWidth: 1
                )
        )
        .opacity(isDone ? 0.65 : (isCurrent ? 1.0 : 0.45))
    }
}

struct BuildStepsView_Previews: PreviewProvider {
    static var previews: some View {
        BuildStepsView(
            buildOrder: BuildOrder.defaultBuildOrder,
            currentStepIndex: 0
        )
        .padding()
        .background(Color(red: 0.08, green: 0.08, blue: 0.12))
    }
}
