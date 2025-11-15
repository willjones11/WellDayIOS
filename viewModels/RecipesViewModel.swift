//
//  RecipesViewModel.swift
//  Wellday
//
//  Manages recipe data and operations
//

import Foundation
import Combine

@MainActor
class RecipesViewModel: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let storage = StorageService.shared
    private let nutritionService = NutritionAnalysisService()
    
    var userRecipes: [Recipe] {
        recipes.filter { $0.source == .user }
    }
    
    var curatedRecipes: [Recipe] {
        recipes.filter { $0.source == .curated }
    }
    
    var favoriteRecipes: [Recipe] {
        recipes.filter { $0.isFavorite }
    }
    
    init() {
        loadRecipes()
    }
    
    // MARK: - Public Methods
    
    func loadRecipes() {
        isLoading = true
        recipes = storage.loadRecipes()
        
        // Load curated recipes if none exist
        if curatedRecipes.isEmpty {
            loadCuratedRecipes()
        }
        
        isLoading = false
    }
    
    func createRecipe(
        title: String,
        ingredients: [String],
        instructions: String? = nil,
        prepTimeMinutes: Int? = nil,
        estimatedCost: Double? = nil,
        photoURL: String? = nil,
        dietTags: [String] = []
    ) async throws -> Recipe {
        // Analyze recipe
        let result = try await nutritionService.analyzeRecipe(
            ingredients: ingredients,
            instructions: instructions
        )
        
        let recipe = Recipe(
            title: title,
            ingredients: ingredients,
            instructions: instructions,
            healthIndex: result.healthIndex,
            tags: result.tags + dietTags,
            prepTimeMinutes: prepTimeMinutes,
            estimatedCost: estimatedCost,
            photoURL: photoURL,
            source: .user
        )
        
        try storage.saveRecipe(recipe)
        recipes.insert(recipe, at: 0)
        return recipe
    }
    
    func updateRecipe(_ recipe: Recipe) throws {
        try storage.saveRecipe(recipe)
        if let index = recipes.firstIndex(where: { $0.id == recipe.id }) {
            recipes[index] = recipe
        }
    }
    
    func deleteRecipe(_ recipeId: UUID) throws {
        try storage.deleteRecipe(recipeId)
        recipes.removeAll { $0.id == recipeId }
    }
    
    func toggleFavorite(_ recipeId: UUID) throws {
        guard let index = recipes.firstIndex(where: { $0.id == recipeId }) else { return }
        var recipe = recipes[index]
        let updatedRecipe = Recipe(
            id: recipe.id,
            title: recipe.title,
            ingredients: recipe.ingredients,
            instructions: recipe.instructions,
            healthIndex: recipe.healthIndex,
            tags: recipe.tags,
            prepTimeMinutes: recipe.prepTimeMinutes,
            estimatedCost: recipe.estimatedCost,
            photoURL: recipe.photoURL,
            source: recipe.source,
            createdAt: recipe.createdAt,
            authorId: recipe.authorId,
            isFavorite: !recipe.isFavorite
        )
        try updateRecipe(updatedRecipe)
    }
    
    func getRecipe(by id: UUID) -> Recipe? {
        recipes.first { $0.id == id }
    }
    
    func createMealFromRecipe(_ recipe: Recipe) -> Meal {
        recipe.toMeal()
    }
    
    // MARK: - Private Helpers
    
    private func loadCuratedRecipes() {
        for recipe in Recipe.curatedSamples {
            try? storage.saveRecipe(recipe)
            recipes.append(recipe)
        }
    }
}
