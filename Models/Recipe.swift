//
//  Recipe.swift
//  Wellday
//
//  Recipe model with health analysis
//

import Foundation

enum RecipeSource: String, Codable {
    case user
    case curated
    case community
}

struct Recipe: Identifiable, Codable {
    let id: UUID
    let title: String
    let ingredients: [String]
    let instructions: String?
    let healthIndex: Double
    let tags: [String]
    let prepTimeMinutes: Int?
    let estimatedCost: Double?
    let photoURL: String?
    let source: RecipeSource
    let createdAt: Date
    let authorId: String?
    var isFavorite: Bool
    
    var tier: MealTier {
        switch healthIndex {
        case 80...: return .excellent
        case 65..<80: return .good
        case 50..<65: return .neutral
        case 35..<50: return .needsImprovement
        default: return .poor
        }
    }
    
    var tierEmoji: String { tier.emoji }
    var tierLabel: String { tier.label }
    
    init(
        id: UUID = UUID(),
        title: String,
        ingredients: [String],
        instructions: String? = nil,
        healthIndex: Double,
        tags: [String] = [],
        prepTimeMinutes: Int? = nil,
        estimatedCost: Double? = nil,
        photoURL: String? = nil,
        source: RecipeSource = .user,
        createdAt: Date = Date(),
        authorId: String? = nil,
        isFavorite: Bool = false
    ) {
        self.id = id
        self.title = title
        self.ingredients = ingredients
        self.instructions = instructions
        self.healthIndex = healthIndex
        self.tags = tags
        self.prepTimeMinutes = prepTimeMinutes
        self.estimatedCost = estimatedCost
        self.photoURL = photoURL
        self.source = source
        self.createdAt = createdAt
        self.authorId = authorId
        self.isFavorite = isFavorite
    }
    
    func toMeal() -> Meal {
        Meal(
            name: title,
            inputType: .recipe,
            healthIndex: healthIndex,
            tags: tags,
            description: "Made from recipe: \(title)",
            photoURL: photoURL,      // ✅ FIXED: photoURL comes before recipeId
            recipeId: id
        )
    }
}

// MARK: - Sample Data
extension Recipe {
    static let sample = Recipe(
        title: "Grilled Chicken Salad",
        ingredients: [
            "2 chicken breasts",
            "4 cups mixed greens",
            "1 cup cherry tomatoes",
            "1/2 cucumber",
            "2 tbsp olive oil",
            "1 lemon"
        ],
        instructions: "1. Grill chicken until cooked through\n2. Chop vegetables\n3. Combine all ingredients\n4. Dress with olive oil and lemon",
        healthIndex: 88,
        tags: ["protein_packed", "low_carb", "nutrient_dense"],
        prepTimeMinutes: 25,
        estimatedCost: 12.50,
        source: .curated
    )
    
    static let curatedSamples = [
        Recipe(
            title: "Grilled Chicken Salad",
            ingredients: ["2 chicken breasts", "4 cups mixed greens", "1 cup cherry tomatoes", "1/2 cucumber", "2 tbsp olive oil", "1 lemon"],
            instructions: "1. Grill chicken until cooked through\n2. Chop vegetables\n3. Combine all ingredients\n4. Dress with olive oil and lemon",
            healthIndex: 88,
            tags: ["protein_packed", "low_carb", "nutrient_dense"],
            prepTimeMinutes: 25,
            estimatedCost: 12.50,
            source: .curated
        ),
        Recipe(
            title: "Quinoa Buddha Bowl",
            ingredients: ["1 cup quinoa", "1 can chickpeas", "1 sweet potato", "2 cups kale", "1/4 cup tahini", "Spices to taste"],
            instructions: "1. Cook quinoa according to package\n2. Roast sweet potato and chickpeas\n3. Massage kale with olive oil\n4. Assemble bowl and drizzle with tahini",
            healthIndex: 92,
            tags: ["fiber_rich", "plant_based", "balanced"],
            prepTimeMinutes: 35,
            estimatedCost: 8.75,
            source: .curated
        ),
        Recipe(
            title: "Salmon with Roasted Vegetables",
            ingredients: ["2 salmon fillets", "2 cups broccoli", "1 bell pepper", "1 zucchini", "2 tbsp olive oil", "Herbs and spices"],
            instructions: "1. Season salmon with herbs\n2. Chop vegetables\n3. Roast everything at 400°F for 20 minutes\n4. Serve hot",
            healthIndex: 90,
            tags: ["protein_packed", "omega_3", "low_carb"],
            prepTimeMinutes: 30,
            estimatedCost: 16.00,
            source: .curated
        ),
        Recipe(
            title: "Overnight Oats",
            ingredients: ["1/2 cup rolled oats", "1/2 cup milk", "1 tbsp chia seeds", "1/2 banana", "1 tbsp honey", "Berries for topping"],
            instructions: "1. Mix oats, milk, and chia seeds\n2. Refrigerate overnight\n3. Top with banana and berries\n4. Drizzle with honey",
            healthIndex: 82,
            tags: ["fiber_rich", "quick_prep", "breakfast"],
            prepTimeMinutes: 5,
            estimatedCost: 3.50,
            source: .curated
        ),
        Recipe(
            title: "Veggie Stir Fry",
            ingredients: ["2 cups mixed vegetables", "1 block tofu", "2 tbsp soy sauce", "1 tbsp ginger", "2 cloves garlic", "1 cup brown rice"],
            instructions: "1. Cook brown rice\n2. Press and cube tofu\n3. Stir fry tofu until golden\n4. Add vegetables and sauces\n5. Serve over rice",
            healthIndex: 85,
            tags: ["plant_based", "fiber_rich", "balanced"],
            prepTimeMinutes: 25,
            estimatedCost: 7.00,
            source: .curated
        )
    ]
}
