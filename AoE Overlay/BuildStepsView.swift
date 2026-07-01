import SwiftUI

struct BuildStepsView: View {
    @AppStorage("maxStepsPerPage") private var maxStepsPerPage: Int = 5
    
    let buildOrder: BuildOrder
    let currentStepIndex: Int
    
    var body: some View {
        let pages = buildOrder.computePages(maxPerPage: maxStepsPerPage)
        let pageIndex = activePageIndex(pages: pages)
        
        VStack(alignment: .leading, spacing: 12) {
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
                
                // Steps List
                VStack(spacing: 8) {
                    ForEach(activePageSteps) { step in
                        BuildStepRow(step: step)
                    }
                }
                
                // Render Page Resource Assignments after steps
                if let lastStep = activePageSteps.last {
                    let resources = lastStep.resources
                    let builders = max(0, lastStep.villagerCount - (resources.food + resources.wood + resources.gold + resources.stone))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Target Vils:")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                        ResourceGridView(resources: resources, builders: builders)
                    }
                    .padding(.top, 6)
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

    @AppStorage("buildStepsTextSize") private var textSize: Double = 12.0
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                // Step Notes
                if !step.notes.isEmpty {
                    ForEach(step.notes, id: \.self) { note in
                        RichTextView(note: note)
                            .foregroundColor(.white)
                    }
                } else {
                    Text("Villager Count: \(step.villagerCount)")
                        .font(.system(size: CGFloat(textSize)))
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .layoutPriority(1) // Force full width usage
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
    }
}

struct BuildStepsView_Previews: PreviewProvider {
    static var previews: some View {
        BuildStepsView(
            buildOrder: BuildOrder.mockBuildOrder,
            currentStepIndex: 0
        )
        .padding()
        .background(Color(red: 0.08, green: 0.08, blue: 0.12))
    }
}
