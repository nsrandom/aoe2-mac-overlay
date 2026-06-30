//
//  ResourceGridView.swift
//  AoE Overlay
//
//  Created by Antigravity on 6/30/26.
//

import SwiftUI

struct ResourceGridView: View {
    let resources: Resources
    
    var body: some View {
        HStack(spacing: 12) {
            ResourceItemView(iconPath: "resource/Aoe2de_food.png", count: resources.food, name: "Food")
            ResourceItemView(iconPath: "resource/Aoe2de_wood.png", count: resources.wood, name: "Wood")
            ResourceItemView(iconPath: "resource/Aoe2de_gold.png", count: resources.gold, name: "Gold")
            ResourceItemView(iconPath: "resource/Aoe2de_stone.png", count: resources.stone, name: "Stone")
        }
        .padding(.vertical, 4)
    }
}

private struct ResourceItemView: View {
    let iconPath: String
    let count: Int
    let name: String
    
    var body: some View {
        HStack(spacing: 4) {
            CachedImage(path: iconPath, width: 14, height: 14)
            Text("\(count)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .frame(minWidth: 45, alignment: .leading)
        .help(name)
    }
}

struct ResourceGridView_Previews: PreviewProvider {
    static var previews: some View {
        ResourceGridView(resources: Resources(wood: 4, food: 7, gold: 2, stone: 0))
            .padding()
            .background(Color.black)
    }
}
