//
//  NutritionAnalysisService.swift
//  Wellday
//
//  Mock nutrition analysis service - ready for API integration
//

import Foundation

struct NutritionAnalysisResult {
    let healthIndex: Double
    let tags: [String]
    let description: String
    let nutritionData: [String: Double]
}

class NutritionAnalysisService {
    
    // MARK: - Public Methods
    
    func analyzeFromText(_ text: String) async throws -> NutritionAnalysisResult {
        // Simulate API delay
        try await Task.sleep(nanoseconds: 800_000_000)
        
        let lowercaseText = text.lowercased()
        var healthIndex: Double = 50.0
        var tags: [String] = []
        
        // Positive indicators
        if containsAny(in: lowercaseText, keywords: [
            "salad", "vegetables", "fruit", "quinoa", "brown rice",
            "grilled", "steamed", "baked", "chicken breast", "salmon",
            "avocado", "leafy greens"
        ]) {
            healthIndex += Double.random(in: 10...30)
            tags.append("nutrient_dense")
        }
        
        if containsAny(in: lowercaseText, keywords: [
            "protein", "chicken", "fish", "tofu", "eggs", "beans", "lentils"
        ]) {
            healthIndex += 10
            tags.append("protein_packed")
        }
        
        if containsAny(in: lowercaseText, keywords: [
            "fiber", "whole grain", "oats", "beans", "vegetables"
        ]) {
            healthIndex += 8
            tags.append("fiber_rich")
        }
        
        // Negative indicators
        if containsAny(in: lowercaseText, keywords: [
            "fried", "deep fried", "fast food", "burger", "fries", "pizza"
        ]) {
            healthIndex -= Double.random(in: 15...25)
            tags.append("processed")
        }
        
        if containsAny(in: lowercaseText, keywords: [
            "soda", "candy", "dessert", "cake", "cookies", "ice cream"
        ]) {
            healthIndex -= 15
            tags.append("high_sugar")
        }
        
        if containsAny(in: lowercaseText, keywords: [
            "salty", "chips", "bacon", "soy sauce", "canned"
        ]) {
            healthIndex -= 8
            tags.append("high_sodium")
        }
        
        if containsAny(in: lowercaseText, keywords: [
            "pasta", "bread", "rice", "potatoes", "cereal"
        ]) {
            if !tags.contains("nutrient_dense") {
                tags.append("carb_dense")
            }
        }
        
        // Clamp health index
        healthIndex = max(20, min(95, healthIndex))
        
        // Generate nutrition data
        let nutritionData: [String: Double] = [
            "calories": Double(Int.random(in: 200...600)),
            "protein": Double(Int.random(in: 10...40)),
            "carbs": Double(Int.random(in: 20...70)),
            "fat": Double(Int.random(in: 5...25)),
            "fiber": Double(Int.random(in: 2...12)),
            "sodium": Double(Int.random(in: 200...1000))
        ]
        
        return NutritionAnalysisResult(
            healthIndex: healthIndex,
            tags: tags,
            description: generateDescription(for: healthIndex, tags: tags),
            nutritionData: nutritionData
        )
    }
    
    func analyzeFromPhoto(_ photoURL: String) async throws -> NutritionAnalysisResult {
        // Simulate longer API delay for photo analysis
        try await Task.sleep(nanoseconds: 1_200_000_000)
        
        // Random realistic analysis for MVP
        let healthIndex = Double.random(in: 30...90)
        let tags = generateRandomTags()
        
        let nutritionData: [String: Double] = [
            "calories": Double(Int.random(in: 250...650)),
            "protein": Double(Int.random(in: 15...45)),
            "carbs": Double(Int.random(in: 25...75)),
            "fat": Double(Int.random(in: 8...28)),
            "fiber": Double(Int.random(in: 3...13)),
            "sodium": Double(Int.random(in: 300...1100))
        ]
        
        return NutritionAnalysisResult(
            healthIndex: healthIndex,
            tags: tags,
            description: generateDescription(for: healthIndex, tags: tags),
            nutritionData: nutritionData
        )
    }
    
    func analyzeFromVoice(_ transcription: String) async throws -> NutritionAnalysisResult {
        // Use same logic as text analysis
        return try await analyzeFromText(transcription)
    }
    
    func analyzeRecipe(ingredients: [String], instructions: String?) async throws -> NutritionAnalysisResult {
        let combinedText = ingredients.joined(separator: " ") + " " + (instructions ?? "")
        return try await analyzeFromText(combinedText)
    }
    
    // MARK: - Private Helpers
    
    private func containsAny(in text: String, keywords: [String]) -> Bool {
        keywords.contains { text.contains($0) }
    }
    
    private func generateRandomTags() -> [String] {
        let allTags = [
            "protein_packed", "fiber_rich", "nutrient_dense",
            "high_sodium", "high_sugar", "carb_dense",
            "processed", "low_calorie", "balanced"
        ]
        
        let count = Int.random(in: 1...3)
        return Array(allTags.shuffled().prefix(count))
    }
    
    private func generateDescription(for healthIndex: Double, tags: [String]) -> String {
        switch healthIndex {
        case 80...:
            return "Excellent nutritional balance with quality ingredients"
        case 65..<80:
            return "Good meal choice with some healthy elements"
        case 50..<65:
            return "Balanced meal with room for improvement"
        case 35..<50:
            return "Consider adding more whole foods"
        default:
            return "Try to incorporate more nutritious options"
        }
    }
}

// MARK: - API Integration Notes
/*
 To integrate a real nutrition API (e.g., Edamam, Nutritionix):
 
 1. Add API credentials to Info.plist or use a Config.swift file
 2. Create URLSession requests to the API endpoint
 3. Parse the JSON response
 4. Map the response to NutritionAnalysisResult
 
 Example with Edamam:
 
 func analyzeFromText(_ text: String) async throws -> NutritionAnalysisResult {
     let url = URL(string: "https://api.edamam.com/api/nutrition-details")!
     var request = URLRequest(url: url)
     request.httpMethod = "POST"
     request.setValue("application/json", forHTTPHeaderField: "Content-Type")
     
     let body = [
         "title": "User Meal",
         "ingr": [text]
     ]
     request.httpBody = try JSONEncoder().encode(body)
     
     let (data, _) = try await URLSession.shared.data(for: request)
     let response = try JSONDecoder().decode(EdamamResponse.self, from: data)
     
     return NutritionAnalysisResult(
         healthIndex: calculateHealthIndex(from: response),
         tags: generateTags(from: response),
         description: generateDescription(from: response),
         nutritionData: extractNutritionData(from: response)
     )
 }
 */
