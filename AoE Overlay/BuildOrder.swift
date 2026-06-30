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
    
    /// Default fallback build order loaded from the bundle resources, or a static raw JSON template.
    static var defaultBuildOrder: BuildOrder {
        if let url = Bundle.main.url(forResource: "fc-lancers", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let bo = try? JSONDecoder().decode(BuildOrder.self, from: data) {
            return bo
        }
        
        // Minimal fallback JSON structure to prevent launch failures
        let fallbackJSON = """
        {
            "name": "Fast Castle Double Barracks Fire Lancers",
            "civilization": "Any",
            "author": "Morley Games",
            "source": "https://www.youtube.com/watch?v=9ZF-vpOUiIE",
            "description": "A slight adaptation of Morley Games' KFC build order.",
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
