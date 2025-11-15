//
//  UserViewModel.swift
//  Wellday
//
//  Manages user profile and authentication
//

import Foundation
import Combine

@MainActor
class UserViewModel: ObservableObject {
    @Published var profile: UserProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let storage = StorageService.shared
    
    var isAuthenticated: Bool {
        profile != nil
    }
    
    init() {
        loadProfile()
    }
    
    // MARK: - Public Methods
    
    func loadProfile() {
        isLoading = true
        profile = storage.loadUserProfile()
        isLoading = false
    }
    
    func createProfile(
        email: String,
        name: String? = nil,
        healthGoal: HealthGoal = .maintain,
        dailyBudget: Double? = nil,
        dietaryPreferences: [String] = []
    ) throws {
        let newProfile = UserProfile(
            email: email,
            name: name,
            healthGoal: healthGoal,
            dailyBudget: dailyBudget,
            dietaryPreferences: dietaryPreferences
        )
        
        try storage.saveUserProfile(newProfile)
        profile = newProfile
    }
    
    func updateProfile(
        name: String? = nil,
        healthGoal: HealthGoal? = nil,
        dailyBudget: Double? = nil,
        dietaryPreferences: [String]? = nil,
        unitSystem: UnitSystem? = nil
    ) throws {
        guard var currentProfile = profile else { return }
        
        if let name = name {
            currentProfile.name = name
        }
        if let healthGoal = healthGoal {
            currentProfile.healthGoal = healthGoal
        }
        if let dailyBudget = dailyBudget {
            currentProfile.dailyBudget = dailyBudget
        }
        if let dietaryPreferences = dietaryPreferences {
            currentProfile.dietaryPreferences = dietaryPreferences
        }
        if let unitSystem = unitSystem {
            currentProfile.unitSystem = unitSystem
        }
        
        try storage.saveUserProfile(currentProfile)
        profile = currentProfile
    }
    
    func updateStreak(_ currentStreak: Int) throws {
        guard var currentProfile = profile else { return }
        
        currentProfile.currentStreak = currentStreak
        if currentStreak > currentProfile.longestStreak {
            currentProfile.longestStreak = currentStreak
        }
        currentProfile.lastLoginAt = Date()
        
        try storage.saveUserProfile(currentProfile)
        profile = currentProfile
    }
    
    func logout() {
        storage.clearAll()
        profile = nil
    }
}
