//
//  Meal.swift
//  Wellday
//
//  Core meal model with automatic tier and points calculation
//

import Foundation

enum MealTier: String, Codable {
    case excellent
    case good
    case neutral
    case needsImprovement
    case poor
    
    var emoji: String {
        switch self {
        case .excellent: return "🥇"
        case .good: return "🥈"
        case .neutral: return "⚪"
        case .needsImprovement: return "🟠"
        case .poor: return "🔴"
        }
    }
    
    var label: String {
        switch self {
        case .excellent: return "Excellent"
        case .good: return "Good"
        case .neutral: return "Neutral"
        case .needsImprovement: return "Needs Improvement"
        case .poor: return "Poor"
        }
    }
    
    var color: String {
        switch self {
        case .excellent: return "green"
        case .good: return "blue"
        case .neutral: return "gray"
        case .needsImprovement: return "orange"
        case .poor: return "red"
        }
    }
}

enum MealInputType: String, Codable {
    case photo
    case text
    case voice
    case recipe
    
    var icon: String {
        switch self {
        case .photo: return "camera.fill"
        case .text: return "note.text"
        case .voice: return "mic.fill"
        case .recipe: return "book.fill"
        }
    }
}

struct Meal: Identifiable, Codable {
    let id: UUID
    let name: String
    let timestamp: Date
    let inputType: MealInputType
    let healthIndex: Double
    let tags: [String]
    let description: String?
    let photoURL: String?
    let recipeId: UUID?
    let nutritionData: [String: Double]?
    
    var tier: MealTier {
        calculateTier(from: healthIndex)
    }
    
    var points: Int {
        calculatePoints(from: healthIndex)
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        timestamp: Date = Date(),
        inputType: MealInputType,
        healthIndex: Double,
        tags: [String] = [],
        description: String? = nil,
        photoURL: String? = nil,
        recipeId: UUID? = nil,
        nutritionData: [String: Double]? = nil
    ) {
        self.id = id
        self.name = name
        self.timestamp = timestamp
        self.inputType = inputType
        self.healthIndex = healthIndex
        self.tags = tags
        self.description = description
        self.photoURL = photoURL
        self.recipeId = recipeId
        self.nutritionData = nutritionData
    }
    
    private func calculateTier(from healthIndex: Double) -> MealTier {
        switch healthIndex {
        case 80...: return .excellent
        case 65..<80: return .good
        case 50..<65: return .neutral
        case 35..<50: return .needsImprovement
        default: return .poor
        }
    }
    
    private func calculatePoints(from healthIndex: Double) -> Int {
        switch healthIndex {
        case 80...: return 10
        case 65..<80: return 6
        case 50..<65: return 3
        case 35..<50: return 0
        default: return -3
        }
    }
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: timestamp)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter.string(from: timestamp)
    }
}

// MARK: - Sample Data
extension Meal {
    static let sample = Meal(
        name: "Grilled Chicken Salad",
        inputType: .text,
        healthIndex: 85,
        tags: ["protein_packed", "fiber_rich", "nutrient_dense"],
        description: "Mixed greens with grilled chicken breast, avocado, and olive oil dressing"
    )
    
    static let samples = [
        Meal(
            name: "Grilled Chicken Salad",
            inputType: .text,
            healthIndex: 85,
            tags: ["protein_packed", "fiber_rich"],
            description: "Healthy lunch option"
        ),
        Meal(
            name: "Overnight Oats",
            timestamp: Date().addingTimeInterval(-3600),
            inputType: .recipe,
            healthIndex: 78,
            tags: ["fiber_rich", "breakfast"],
            description: "Oats with berries and honey"
        ),
        Meal(
            name: "Salmon Bowl",
            timestamp: Date().addingTimeInterval(-7200),
            inputType: .photo,
            healthIndex: 90,
            tags: ["protein_packed", "omega_3", "balanced"],
            description: "Pan-seared salmon with vegetables"
        )
    ]
}
