//
//  MealsViewModel.swift
//  Wellday
//
//  Manages meal data and daily statistics
//

import Foundation
import Combine

@MainActor
class MealsViewModel: ObservableObject {
    @Published var meals: [Meal] = []
    @Published var dailyStatsCache: [String: DailyStats] = [:]
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let storage = StorageService.shared
    private let nutritionService = NutritionAnalysisService()
    
    init() {
        loadMeals()
    }
    
    // MARK: - Public Methods
    
    func loadMeals() {
        isLoading = true
        meals = storage.loadMeals().sorted { $0.timestamp > $1.timestamp }
        updateDailyStatsCache()
        isLoading = false
    }
    
    func getMeals(for date: Date) -> [Meal] {
        meals.filter { Calendar.current.isDate($0.timestamp, inSameDayAs: date) }
            .sorted { $0.timestamp < $1.timestamp }
    }
    
    func getTodayMeals() -> [Meal] {
        getMeals(for: Date())
    }
    
    func getDailyStats(for date: Date) -> DailyStats? {
        let key = dateKey(for: date)
        return dailyStatsCache[key]
    }
    
    func getTodayStats() -> DailyStats? {
        getDailyStats(for: Date())
    }
    
    func getYesterdayStats() -> DailyStats? {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        return getDailyStats(for: yesterday)
    }
    
    func getLast7DaysStats() -> [DailyStats] {
        var stats: [DailyStats] = []
        for i in 6...0 {
            let date = Calendar.current.date(byAdding: .day, value: -i, to: Date())!
            if let stat = getDailyStats(for: date) {
                stats.append(stat)
            }
        }
        return stats
    }
    
    func getCurrentStreak() -> Int {
        var streak = 0
        var checkDate = Date()
        
        while streak < 365 { // Prevent infinite loop
            if let stats = getDailyStats(for: checkDate), stats.mealCount >= 3 {
                streak += 1
                checkDate = Calendar.current.date(byAdding: .day, value: -1, to: checkDate)!
            } else {
                break
            }
        }
        
        return streak
    }
    
    // MARK: - Analysis Methods
    
    func analyzeMealFromText(_ text: String, name: String) async throws -> Meal {
        let result = try await nutritionService.analyzeFromText(text)
        return Meal(
            name: name,
            inputType: .text,
            healthIndex: result.healthIndex,
            tags: result.tags,
            description: result.description,
            nutritionData: result.nutritionData
        )
    }
    
    func analyzeMealFromPhoto(_ photoURL: String, name: String) async throws -> Meal {
        let result = try await nutritionService.analyzeFromPhoto(photoURL)
        return Meal(
            name: name,
            inputType: .photo,
            healthIndex: result.healthIndex,
            tags: result.tags,
            description: result.description,
            photoURL: photoURL,
            nutritionData: result.nutritionData
        )
    }
    
    func analyzeMealFromVoice(_ transcription: String, name: String) async throws -> Meal {
        let result = try await nutritionService.analyzeFromVoice(transcription)
        return Meal(
            name: name,
            inputType: .voice,
            healthIndex: result.healthIndex,
            tags: result.tags,
            description: result.description,
            nutritionData: result.nutritionData
        )
    }
    
    // MARK: - CRUD Operations
    
    func addMeal(_ meal: Meal) throws {
        try storage.saveMeal(meal)
        meals.insert(meal, at: 0)
        meals.sort { $0.timestamp > $1.timestamp }
        updateDailyStats(for: meal.timestamp)
    }
    
    func updateMeal(_ meal: Meal) throws {
        try storage.saveMeal(meal)
        if let index = meals.firstIndex(where: { $0.id == meal.id }) {
            meals[index] = meal
            updateDailyStats(for: meal.timestamp)
        }
    }
    
    func deleteMeal(_ mealId: UUID) throws {
        guard let meal = meals.first(where: { $0.id == mealId }) else { return }
        try storage.deleteMeal(mealId)
        meals.removeAll { $0.id == mealId }
        updateDailyStats(for: meal.timestamp)
    }
    
    // MARK: - Private Helpers
    
    private func updateDailyStatsCache() {
        dailyStatsCache.removeAll()
        
        // Group meals by date
        let groupedMeals = Dictionary(grouping: meals) { meal in
            dateKey(for: meal.timestamp)
        }
        
        // Calculate stats for each day
        for (key, dayMeals) in groupedMeals {
            guard let firstMeal = dayMeals.first else { continue }
            let stats = DailyStats.calculate(from: dayMeals, for: firstMeal.timestamp)
            dailyStatsCache[key] = stats
            try? storage.saveDailyStats(stats)
        }
    }
    
    private func updateDailyStats(for date: Date) {
        let key = dateKey(for: date)
        let dayMeals = getMeals(for: date)
        let stats = DailyStats.calculate(from: dayMeals, for: date)
        dailyStatsCache[key] = stats
        try? storage.saveDailyStats(stats)
    }
    
    private func dateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
