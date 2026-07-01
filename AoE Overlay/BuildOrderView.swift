//
//  BuildOrderView.swift
//  AoE Overlay
//
//  Created by Antigravity on 6/30/26.
//

import SwiftUI

struct BuildOrderView: View {
    let buildOrder: BuildOrder?
    let currentStepIndex: Int
    
    var body: some View {
        if let buildOrder = buildOrder {
            VStack(alignment: .leading, spacing: 10) {
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
            }
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
}

#if DEBUG
struct BuildOrderView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            BuildOrderView(buildOrder: nil, currentStepIndex: 0)
            Divider()
            BuildOrderView(buildOrder: BuildOrder.mockBuildOrder, currentStepIndex: 0)
        }
        .padding()
        .background(Color(red: 0.08, green: 0.08, blue: 0.12))
    }
}
#endif
