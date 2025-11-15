///
//  UserProfile.swift
//  Wellday
//
//  User profile and settings
//

import Foundation

enum HealthGoal: String, Codable, CaseIterable {
    case lose
    case maintain
    case gain
    
    var label: String {
        switch self {
        case .lose: return "Lose Weight"
        case .maintain: return "Maintain Weight"
        case .gain: return "Gain Weight"
        }
    }
    
    var icon: String {
        switch self {
        case .lose: return "arrow.down.circle.fill"
        case .maintain: return "equal.circle.fill"
        case .gain: return "arrow.up.circle.fill"
        }
    }
}

enum UnitSystem: String, Codable, CaseIterable {
    case metric
    case imperial
    
    var label: String {
        switch self {
        case .metric: return "Metric"
        case .imperial: return "Imperial"
        }
    }
}

struct UserProfile: Codable {
    let id: String
    let email: String
    var name: String?
    var healthGoal: HealthGoal
    var dailyBudget: Double?
    var dietaryPreferences: [String]
    var unitSystem: UnitSystem
    var currentStreak: Int
    var longestStreak: Int
    let createdAt: Date
    var lastLoginAt: Date?
    
    init(
        id: String = UUID().uuidString,
        email: String,
        name: String? = nil,
        healthGoal: HealthGoal = .maintain,
        dailyBudget: Double? = nil,
        dietaryPreferences: [String] = [],
        unitSystem: UnitSystem = .imperial,
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        createdAt: Date = Date(),
        lastLoginAt: Date? = nil
    ) {
        self.id = id
        self.email = email
        self.name = name
        self.healthGoal = healthGoal
        self.dailyBudget = dailyBudget
        self.dietaryPreferences = dietaryPreferences
        self.unitSystem = unitSystem
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.createdAt = createdAt
        self.lastLoginAt = lastLoginAt
    }
    
    var displayName: String {
        name ?? email.components(separatedBy: "@").first ?? "User"
    }
    
    var initials: String {
        let name = displayName
        let components = name.components(separatedBy: " ")
        if components.count > 1 {
            return String(components[0].prefix(1) + components[1].prefix(1)).uppercased()
        }
        return String(name.prefix(1)).uppercased()
    }
}

// MARK: - Sample Data
extension UserProfile {
    static let sample = UserProfile(
        email: "demo@wellday.app",
        name: "Demo User",
        healthGoal: .maintain,
        dailyBudget: 30.0,
        currentStreak: 5,
        longestStreak: 12
    )
}
