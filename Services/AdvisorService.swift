//
//  AdvisorService.swift
//  Wellday
//
//  Rule-based advisor system for personalized guidance
//

import Foundation

struct AdvisorMessage {
    let message: String
    let type: MessageType
    let icon: String
    
    enum MessageType {
        case encouragement
        case suggestion
        case celebration
        case insight
    }
}

class AdvisorService {
    
    // MARK: - Daily Message
    
    func generateDailyMessage(
        todayMeals: [Meal],
        yesterdayStats: DailyStats?,
        todayStats: DailyStats?,
        currentStreak: Int,
        dailyBudget: Double?
    ) -> AdvisorMessage {
        
        // Priority 1: Celebrate streaks
        if currentStreak >= 7 {
            return AdvisorMessage(
                message: "🔥 Amazing! \(currentStreak) day streak! You're building incredible habits.",
                type: .celebration,
                icon: "🎉"
            )
        }
        
        if currentStreak >= 3 {
            return AdvisorMessage(
                message: "Great work! You're on a \(currentStreak) day streak. Keep it going!",
                type: .celebration,
                icon: "✨"
            )
        }
        
        // Priority 2: Yesterday's performance
        if let yesterdayStats = yesterdayStats, yesterdayStats.finalPoints >= 30 {
            return AdvisorMessage(
                message: "Great job yesterday! You earned \(yesterdayStats.finalPoints) points. You're on track for a strong day.",
                type: .encouragement,
                icon: "👏"
            )
        }
        
        // Priority 3: Today's progress
        if todayMeals.isEmpty {
            let greetings = [
                "Good morning! Start your day with a nutritious breakfast.",
                "Ready for a great day? Log your first meal to get started!",
                "New day, fresh start! What's on the menu today?"
            ]
            return AdvisorMessage(
                message: greetings.randomElement()!,
                type: .suggestion,
                icon: "☀️"
            )
        }
        
        if todayMeals.count == 1 {
            return AdvisorMessage(
                message: "Good start! Add 2 more meals today to earn your completion bonus.",
                type: .encouragement,
                icon: "💪"
            )
        }
        
        if todayMeals.count == 2 {
            return AdvisorMessage(
                message: "Almost there! One more meal to unlock your +2 bonus points.",
                type: .encouragement,
                icon: "🎯"
            )
        }
        
        // Priority 4: Nutritional insights
        let insights = analyzeNutritionalPatterns(meals: todayMeals)
        if let firstInsight = insights.first {
            return firstInsight
        }
        
        // Priority 5: Budget tracking
        if let dailyBudget = dailyBudget, let todayStats = todayStats {
            let remaining = dailyBudget - todayStats.totalSpent
            if remaining < 0 {
                return AdvisorMessage(
                    message: "You're $\(String(format: "%.2f", abs(remaining))) over budget today. Try a cost-effective dinner!",
                    type: .insight,
                    icon: "💰"
                )
            } else if remaining < dailyBudget * 0.2 {
                return AdvisorMessage(
                    message: "Nice! You have $\(String(format: "%.2f", remaining)) left in your budget.",
                    type: .insight,
                    icon: "💰"
                )
            }
        }
        
        // Default: Generic encouragement
        let defaultMessages = [
            "You're doing great! Keep making healthy choices.",
            "Every meal is a chance to nourish your body.",
            "Consistency is key. You've got this!"
        ]
        return AdvisorMessage(
            message: defaultMessages.randomElement()!,
            type: .encouragement,
            icon: "🌟"
        )
    }
    
    // MARK: - Meal Feedback
    
    func generateMealFeedback(for meal: Meal) -> AdvisorMessage {
        switch meal.tier {
        case .excellent:
            let messages = [
                "Excellent choice! This meal is perfectly balanced.",
                "Wow! This is a top-tier healthy meal. Great work!",
                "Perfect! This meal has everything your body needs."
            ]
            return AdvisorMessage(
                message: messages.randomElement()!,
                type: .celebration,
                icon: "🥇"
            )
            
        case .good:
            let messages = [
                "Nice! This is a solid, healthy choice.",
                "Good pick! You're making progress toward your goals.",
                "Well done! This meal supports your health journey."
            ]
            return AdvisorMessage(
                message: messages.randomElement()!,
                type: .encouragement,
                icon: "✅"
            )
            
        case .neutral:
            return AdvisorMessage(
                message: "Decent choice. Consider adding more vegetables or lean protein next time.",
                type: .suggestion,
                icon: "ℹ️"
            )
            
        case .needsImprovement:
            return AdvisorMessage(
                message: "This meal could be better. Try swapping processed items for whole foods.",
                type: .suggestion,
                icon: "💡"
            )
            
        case .poor:
            return AdvisorMessage(
                message: "Let's aim higher next time! Small swaps can make a big difference.",
                type: .suggestion,
                icon: "🔄"
            )
        }
    }
    
    // MARK: - Weekly Summary
    
    func generateWeeklySummary(weekStats: [DailyStats], currentStreak: Int) -> [String] {
        var insights: [String] = []
        
        let totalPoints = weekStats.reduce(0) { $0 + $1.finalPoints }
        let avgPoints = weekStats.isEmpty ? 0 : Double(totalPoints) / Double(weekStats.count)
        
        insights.append("You earned \(totalPoints) points this week (avg: \(String(format: "%.1f", avgPoints))/day)")
        
        if currentStreak >= 7 {
            insights.append("🔥 Maintained a full week streak! Incredible consistency.")
        }
        
        let totalMeals = weekStats.reduce(0) { $0 + $1.mealCount }
        insights.append("Logged \(totalMeals) meals this week")
        
        let excellentMeals = weekStats.reduce(0) { $0 + ($1.tierCounts["excellent"] ?? 0) }
        if excellentMeals > 0 {
            insights.append("\(excellentMeals) excellent meals this week! 🥇")
        }
        
        return insights
    }
    
    // MARK: - Private Helpers
    
    private func analyzeNutritionalPatterns(meals: [Meal]) -> [AdvisorMessage] {
        var messages: [AdvisorMessage] = []
        
        guard !meals.isEmpty else { return messages }
        
        // Check for protein
        let hasProtein = meals.contains { $0.tags.contains("protein_packed") }
        if !hasProtein && meals.count >= 2 {
            messages.append(AdvisorMessage(
                message: "Consider adding a protein source to your next meal for better balance.",
                type: .suggestion,
                icon: "🥩"
            ))
        }
        
        // Check sodium
        let highSodiumCount = meals.filter { $0.tags.contains("high_sodium") }.count
        if highSodiumCount >= 2 {
            messages.append(AdvisorMessage(
                message: "Sodium has been trending high today. Consider a lighter option for your next meal.",
                type: .suggestion,
                icon: "🧂"
            ))
        }
        
        // Check processed foods
        let processedCount = meals.filter { $0.tags.contains("processed") }.count
        if processedCount >= 2 {
            messages.append(AdvisorMessage(
                message: "Try incorporating more whole foods in your next meal.",
                type: .suggestion,
                icon: "🥗"
            ))
        }
        
        // Celebrate excellent meals
        let excellentCount = meals.filter { $0.tier == .excellent }.count
        if excellentCount >= 2 {
            messages.append(AdvisorMessage(
                message: "You're crushing it today! Two excellent meals already. 🎉",
                type: .celebration,
                icon: "🥇"
            ))
        }
        
        // Check for fiber
        let hasFiber = meals.contains { $0.tags.contains("fiber_rich") }
        if !hasFiber && meals.count >= 2 {
            messages.append(AdvisorMessage(
                message: "Add some fiber-rich foods like vegetables or whole grains to your next meal.",
                type: .suggestion,
                icon: "🥦"
            ))
        }
        
        return messages
    }
}
