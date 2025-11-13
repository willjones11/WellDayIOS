//
//  StorageService.swift
//  Wellday
//
//  Local data persistence using UserDefaults and JSON
//

import Foundation

class StorageService {
    static let shared = StorageService()
    
    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private enum Keys {
        static let userProfile = "userProfile"
        static let meals = "meals"
        static let recipes = "recipes"
        static let dailyStats = "dailyStats"
    }
    
    // MARK: - User Profile
    
    func saveUserProfile(_ profile: UserProfile) throws {
        let data = try encoder.encode(profile)
        defaults.set(data, forKey: Keys.userProfile)
    }
    
    func loadUserProfile() -> UserProfile? {
        guard let data = defaults.data(forKey: Keys.userProfile) else { return nil }
        return try? decoder.decode(UserProfile.self, from: data)
    }
    
    // MARK: - Meals
    
    func saveMeal(_ meal: Meal) throws {
        var meals = loadMeals()
        meals.removeAll { $0.id == meal.id }
        meals.append(meal)
        
        let data = try encoder.encode(meals)
        defaults.set(data, forKey: Keys.meals)
    }
    
    func loadMeals() -> [Meal] {
        guard let data = defaults.data(forKey: Keys.meals) else { return [] }
        return (try? decoder.decode([Meal].self, from: data)) ?? []
    }
    
    func deleteMeal(_ mealId: UUID) throws {
        var meals = loadMeals()
        meals.removeAll { $0.id == mealId }
        
        let data = try encoder.encode(meals)
        defaults.set(data, forKey: Keys.meals)
    }
    
    func loadMeals(for date: Date) -> [Meal] {
        let allMeals = loadMeals()
        return allMeals.filter { Calendar.current.isDate($0.timestamp, inSameDayAs: date) }
    }
    
    func loadMeals(from startDate: Date, to endDate: Date) -> [Meal] {
        let allMeals = loadMeals()
        return allMeals.filter { meal in
            meal.timestamp >= startDate && meal.timestamp <= endDate
        }
    }
    
    // MARK: - Recipes
    
    func saveRecipe(_ recipe: Recipe) throws {
        var recipes = loadRecipes()
        recipes.removeAll { $0.id == recipe.id }
        recipes.append(recipe)
        
        let data = try encoder.encode(recipes)
        defaults.set(data, forKey: Keys.recipes)
    }
    
    func loadRecipes() -> [Recipe] {
        guard let data = defaults.data(forKey: Keys.recipes) else { return [] }
        return (try? decoder.decode([Recipe].self, from: data)) ?? []
    }
    
    func deleteRecipe(_ recipeId: UUID) throws {
        var recipes = loadRecipes()
        recipes.removeAll { $0.id == recipeId }
        
        let data = try encoder.encode(recipes)
        defaults.set(data, forKey: Keys.recipes)
    }
    
    func loadRecipe(by id: UUID) -> Recipe? {
        loadRecipes().first { $0.id == id }
    }
    
    func loadRecipes(source: RecipeSource) -> [Recipe] {
        loadRecipes().filter { $0.source == source }
    }
    
    // MARK: - Daily Stats
    
    func saveDailyStats(_ stats: DailyStats) throws {
        var allStats = loadAllDailyStats()
        allStats.removeAll { Calendar.current.isDate($0.date, inSameDayAs: stats.date) }
        allStats.append(stats)
        
        let data = try encoder.encode(allStats)
        defaults.set(data, forKey: Keys.dailyStats)
    }
    
    func loadDailyStats(for date: Date) -> DailyStats? {
        let allStats = loadAllDailyStats()
        return allStats.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    func loadAllDailyStats() -> [DailyStats] {
        guard let data = defaults.data(forKey: Keys.dailyStats) else { return [] }
        return (try? decoder.decode([DailyStats].self, from: data)) ?? []
    }
    
    func loadDailyStats(from startDate: Date, to endDate: Date) -> [DailyStats] {
        let allStats = loadAllDailyStats()
        return allStats.filter { stat in
            stat.date >= startDate && stat.date <= endDate
        }.sorted { $0.date < $1.date }
    }
    
    // MARK: - Initialization & Reset
    
    func initializeWithSampleData() throws {
        // Only initialize if no profile exists
        guard loadUserProfile() == nil else { return }
        
        // Create demo profile
        let profile = UserProfile(
            email: "demo@wellday.app",
            name: "Demo User",
            healthGoal: .maintain,
            dailyBudget: 30.0
        )
        try saveUserProfile(profile)
        
        // Load curated recipes
        for recipe in Recipe.curatedSamples {
            try saveRecipe(recipe)
        }
    }
    
    func clearAll() {
        defaults.removeObject(forKey: Keys.userProfile)
        defaults.removeObject(forKey: Keys.meals)
        defaults.removeObject(forKey: Keys.recipes)
        defaults.removeObject(forKey: Keys.dailyStats)
    }
    
    func clearMeals() {
        defaults.removeObject(forKey: Keys.meals)
        defaults.removeObject(forKey: Keys.dailyStats)
    }
    
    func clearRecipes() {
        defaults.removeObject(forKey: Keys.recipes)
    }
}

// MARK: - Calendar Extension
extension Calendar {
    func isDate(_ date1: Date, inSameDayAs date2: Date) -> Bool {
        isDate(date1, equalTo: date2, toGranularity: .day)
    }
}
