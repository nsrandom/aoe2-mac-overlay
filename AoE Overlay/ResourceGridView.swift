import SwiftUI

struct ResourceGridView: View {
    let resources: Resources
    let builders: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ResourceItemView(iconPath: "resource/Aoe2de_food.png", count: resources.food, name: "Food")
            ResourceItemView(iconPath: "resource/Aoe2de_wood.png", count: resources.wood, name: "Wood")
            ResourceItemView(iconPath: "resource/Aoe2de_gold.png", count: resources.gold, name: "Gold")
            ResourceItemView(iconPath: "resource/Aoe2de_stone.png", count: resources.stone, name: "Stone")
            ResourceItemView(iconPath: "resource/Aoe2de_hammer.png", count: builders, name: "Builders")
        }
        .padding(8)
        .background(Color.white.opacity(0.04))
        .cornerRadius(6)
    }
}

private struct ResourceItemView: View {
    let iconPath: String
    let count: Int
    let name: String
    
    @AppStorage("buildStepsIconSize") private var iconSize: Double = 18.0
    @AppStorage("buildStepsTextSize") private var textSize: Double = 12.0
    
    var body: some View {
        HStack(spacing: 3) {
            CachedImage(path: iconPath, width: CGFloat(iconSize), height: CGFloat(iconSize))
            Text("\(count)")
                .font(.system(size: CGFloat(textSize)))
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .help(name)
    }
}

struct ResourceGridView_Previews: PreviewProvider {
    static var previews: some View {
        ResourceGridView(
            resources: Resources(wood: 4, food: 7, gold: 2, stone: 0),
            builders: 2
        )
        .padding()
        .background(Color.black)
    }
}
