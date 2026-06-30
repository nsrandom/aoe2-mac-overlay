//
//  BuildOrder.swift
//  AoE Overlay
//
//  Created by Antigravity on 6/30/26.
//

import Foundation

struct BuildOrder: Codable, Identifiable {
    var id: String { name }
    let name: String
    let civilization: String
    let author: String
    let source: String?
    let description: String?
    let buildOrder: [BuildOrderStep]
    
    enum CodingKeys: String, CodingKey {
        case name, civilization, author, source, description
        case buildOrder = "build_order"
    }
}

struct BuildOrderStep: Codable, Identifiable {
    var id = UUID()
    let villagerCount: Int
    let age: Int
    let resources: Resources
    let notes: [String]
    
    enum CodingKeys: String, CodingKey {
        case villagerCount = "villager_count"
        case age, resources, notes
    }
    
    // Add custom decoder to assign a unique ID since UUID is not in the JSON
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.villagerCount = try container.decode(Int.self, forKey: .villagerCount)
        self.age = try container.decode(Int.self, forKey: .age)
        self.resources = try container.decode(Resources.self, forKey: .resources)
        self.notes = try container.decode([String].self, forKey: .notes)
        self.id = UUID()
    }
}

struct Resources: Codable {
    let wood: Int
    let food: Int
    let gold: Int
    let stone: Int
}

extension BuildOrder {
    /// Segment steps into pages based on maximum steps limit and age boundaries.
    func computePages(maxPerPage: Int) -> [[BuildOrderStep]] {
        var pages: [[BuildOrderStep]] = []
        var currentPage: [BuildOrderStep] = []
        
        for step in buildOrder {
            if !currentPage.isEmpty {
                let lastStep = currentPage.last!
                // Start a new page if:
                // 1. Current page has reached the max capacity
                // 2. The step age changes
                if currentPage.count >= maxPerPage || step.age != lastStep.age {
                    pages.append(currentPage)
                    currentPage = []
                }
            }
            currentPage.append(step)
        }
        if !currentPage.isEmpty {
            pages.append(currentPage)
        }
        return pages
    }
    
#if DEBUG
extension BuildOrder {
    /// A mockup build order loaded from the static raw JSON template for SwiftUI Previews.
    static var mockBuildOrder: BuildOrder {
        let fallbackJSON = """
        {
            "name": "Fast Castle Double Barracks Fire Lancers",
            "civilization": "Any",
            "author": "Morley Games",
            "source": "https://www.youtube.com/watch?v=9ZF-vpOUiIE",
            "description": "A slight adaptation of Morley Games' KFC build order, which should work for any civ with fire lancers.",
            "build_order": [
                {
                    "villager_count": 6,
                    "age": 1,
                    "resources": {
                        "wood": 0,
                        "food": 6,
                        "gold": 0,
                        "stone": 0
                    },
                    "notes": [
                        "Create 6 @resource/MaleVillDE.jpg@ on @animal/Sheep_aoe2DE.png@"
                    ]
                },
                {
                    "villager_count": 7,
                    "age": 1,
                    "resources": {
                        "wood": 0,
                        "food": 7,
                        "gold": 0,
                        "stone": 0
                    },
                    "notes": [
                        "Create 1 @resource/MaleVillDE.jpg@ on @animal/Boar_aoe2DE.png@"
                    ]
                },
                {
                    "villager_count": 11,
                    "age": 1,
                    "resources": {
                        "wood": 4,
                        "food": 7,
                        "gold": 0,
                        "stone": 0
                    },
                    "notes": [
                        "Create 4 @resource/MaleVillDE.jpg@ on @resource/Aoe2de_wood.png@"
                    ]
                },
                {
                    "villager_count": 14,
                    "age": 1,
                    "resources": {
                        "wood": 4,
                        "food": 10,
                        "gold": 0,
                        "stone": 0
                    },
                    "notes": [
                        "Create 3 @resource/MaleVillDE.jpg@ on @resource/BerryBushDE.png@"
                    ]
                },
                {
                    "villager_count": 15,
                    "age": 1,
                    "resources": {
                        "wood": 4,
                        "food": 11,
                        "gold": 0,
                        "stone": 0
                    },
                    "notes": [
                        "Create 1 @resource/MaleVillDE.jpg@ on @animal/Boar_aoe2DE.png@"
                    ]
                },
                {
                    "villager_count": 16,
                    "age": 1,
                    "resources": {
                        "wood": 4,
                        "food": 12,
                        "gold": 0,
                        "stone": 0
                    },
                    "notes": [
                        "Create 1 @resource/MaleVillDE.jpg@ on foodUnderTC",
                        "Move 4 @resource/MaleVillDE.jpg@ from @animal/Boar_aoe2DE.png@ to chicken"
                    ]
                },
                {
                    "villager_count": 18,
                    "age": 1,
                    "resources": {
                        "wood": 4,
                        "food": 14,
                        "gold": 0,
                        "stone": 0
                    },
                    "notes": [
                        "Create 2 @resource/MaleVillDE.jpg@ on @resource/BerryBushDE.png@"
                    ]
                },
                {
                    "villager_count": 20,
                    "age": 1,
                    "resources": {
                        "wood": 4,
                        "food": 14,
                        "gold": 2,
                        "stone": 0
                    },
                    "notes": [
                        "Create 2 @resource/MaleVillDE.jpg@ on @resource/Aoe2de_gold.png@"
                    ]
                },
                {
                    "villager_count": 22,
                    "age": 1,
                    "resources": {
                        "wood": 6,
                        "food": 14,
                        "gold": 2,
                        "stone": 0
                    },
                    "notes": [
                        "Create 2 @resource/MaleVillDE.jpg@ on @resource/Aoe2de_wood.png@",
                        "Research @town_center/LoomDE.png@",
                        "Click up to feudalAge"
                    ]
                },
                {
                    "villager_count": 22,
                    "age": 2,
                    "resources": {
                        "wood": 6,
                        "food": 14,
                        "gold": 2,
                        "stone": 0
                    },
                    "notes": [
                        "Before @age/FeudalAgeIconDE_alpha.png@",
                        "Move 1 @resource/MaleVillDE.jpg@ from @animal/Sheep_aoe2DE.png@ to @mill/FarmDE.png@",
                        "Move 4 @resource/MaleVillDE.jpg@ from chicken to @animal/Sheep_aoe2DE.png@"
                    ]
                },
                {
                    "villager_count": 22,
                    "age": 2,
                    "resources": {
                        "wood": 6,
                        "food": 14,
                        "gold": 2,
                        "stone": 0
                    },
                    "notes": [
                        "In @age/FeudalAgeIconDE_alpha.png@",
                        "@resource/Aoe2de_hammer.png@ 1 market, 1 @blacksmith/Blacksmith_aoe2de.png@"
                    ]
                },
                {
                    "villager_count": 24,
                    "age": 2,
                    "resources": {
                        "wood": 6,
                        "food": 16,
                        "gold": 2,
                        "stone": 0
                    },
                    "notes": [
                        "Create 2 @resource/MaleVillDE.jpg@ on @animal/Sheep_aoe2DE.png@",
                        "Click up to castleAge"
                    ]
                },
                {
                    "villager_count": 24,
                    "age": 3,
                    "resources": {
                        "wood": 12,
                        "food": 6,
                        "gold": 6,
                        "stone": 0
                    },
                    "notes": [
                        "Before @age/CastleAgeIconDE_alpha.png@",
                        "Move 4 @resource/MaleVillDE.jpg@ from @animal/Sheep_aoe2DE.png@ to @resource/Aoe2de_gold.png@",
                        "Move 6 @resource/MaleVillDE.jpg@ from @animal/Sheep_aoe2DE.png@ to @resource/Aoe2de_wood.png@",
                        "@resource/Aoe2de_hammer.png@ 1 watchTower",
                        "@resource/Aoe2de_hammer.png@ 2 @barracks/Barracks_aoe2DE.png@",
                        "Research doubleBitAxe"
                    ]
                },
                {
                    "villager_count": 24,
                    "age": 3,
                    "resources": {
                        "wood": 12,
                        "food": 6,
                        "gold": 6,
                        "stone": 0
                    },
                    "notes": [
                        "In @age/CastleAgeIconDE_alpha.png@",
                        "Train Fire Lancers from Both @barracks/Barracks_aoe2DE.png@"
                    ]
                },
                {
                    "villager_count": 28,
                    "age": 3,
                    "resources": {
                        "wood": 12,
                        "food": 6,
                        "gold": 10,
                        "stone": 0
                    },
                    "notes": [
                        "Create 4 @resource/MaleVillDE.jpg@ on @resource/Aoe2de_gold.png@",
                        "Move 5 @resource/MaleVillDE.jpg@ from @resource/Aoe2de_food.png@ to @mill/FarmDE.png@",
                        "New Vils Can Go to Straggler Trees and Make @mill/FarmDE.png@ with Spare @resource/Aoe2de_wood.png@",
                        "Research scaleMailArmor, squires",
                        "Make Forward @siege_workshop/Siege_workshop_aoe2DE.png@ and Rocket Carts"
                    ]
                }
            ]
        }
        """
        
        if let data = fallbackJSON.data(using: .utf8),
           let bo = try? JSONDecoder().decode(BuildOrder.self, from: data) {
            return bo
        }
        
        return BuildOrder(
            name: "Default Build Order",
            civilization: "Any",
            author: "System",
            source: nil,
            description: nil,
            buildOrder: []
        )
    }
}
#endif
