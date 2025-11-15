//
//  DailyStats.swift
//  Wellday
//
//  Daily progress tracking
//

import Foundation

struct DailyStats: Codable, Identifiable {
    var id: String { dateString }
    
    let date: Date
    var totalPoints: Int
    var mealCount: Int
    var totalSpent: Double
    var tierCounts: [String: Int]
    var mealIds: [UUID]
    
    var hasCompletionBonus: Bool {
        mealCount >= 3
    }
    
    var finalPoints: Int {
        hasCompletionBonus ? totalPoints + 2 : totalPoints
    }
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
    
    init(
        date: Date,
        totalPoints: Int = 0,
        mealCount: Int = 0,
        totalSpent: Double = 0.0,
        tierCounts: [String: Int] = [:],
        mealIds: [UUID] = []
    ) {
        self.date = date
        self.totalPoints = totalPoints
        self.mealCount = mealCount
        self.totalSpent = totalSpent
        self.tierCounts = tierCounts
        self.mealIds = mealIds
    }
    
    static func calculate(from meals: [Meal], for date: Date) -> DailyStats {
        let totalPoints = meals.reduce(0) { $0 + $1.points }
        var tierCounts: [String: Int] = [:]
        
        for meal in meals {
            let tierKey = meal.tier.rawValue
            tierCounts[tierKey, default: 0] += 1
        }
        
        return DailyStats(
            date: date,
            totalPoints: totalPoints,
            mealCount: meals.count,
            totalSpent: 0.0,
            tierCounts: tierCounts,
            mealIds: meals.map { $0.id }
        )
    }
}

// MARK: - Sample Data
extension DailyStats {
    static let sample = DailyStats(
        date: Date(),
        totalPoints: 22,
        mealCount: 3,
        totalSpent: 25.50,
        tierCounts: [
            "excellent": 2,
            "good": 1
        ]
    )
    
    static let samples: [DailyStats] = {
        var stats: [DailyStats] = []
        for i in 0..<7 {
            let date = Calendar.current.date(byAdding: .day, value: -i, to: Date())!
            stats.append(DailyStats(
                date: date,
                totalPoints: Int.random(in: 10...30),
                mealCount: Int.random(in: 2...4),
                totalSpent: Double.random(in: 15...35)
            ))
        }
        return stats.reversed()
    }()
}
