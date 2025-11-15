//
//  HomeView.swift
//  Wellday
//
//  Main home screen with daily stats and advisor
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var mealsViewModel: MealsViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @State private var showingAddMeal = false
    
    private let advisorService = AdvisorService()
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(spacing: 16) {
                        // Advisor Message
                        advisorCard
                        
                        // Stats Grid
                        statsGrid
                        
                        // 7-Day Trend
                        sevenDayTrend
                        
                        // Today's Meals Section
                        todayMealsSection
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
                .background(Theme.Colors.background)

                // Floating Add Button
                Button(action: { showingAddMeal = true }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Meal")
                    }
                    .font(Theme.Fonts.sans(size: 16, weight: .semibold))
                    .foregroundColor(Theme.Colors.primaryText)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(Theme.Colors.primaryBackground)
                    .cornerRadius(25)
                    .shadow(color: Theme.Colors.primaryBackground.opacity(0.4), radius: 10, x: 0, y: 4)
                }
                .padding(16)
            }
            .navigationTitle("Wellday")
            .navigationBarTitleDisplayMode(.large)
            .background(Theme.Colors.background.ignoresSafeArea())
            .sheet(isPresented: $showingAddMeal) {
                AddMealView()
            }
        }
    }
    
    // MARK: - Advisor Card
    
    private var advisorCard: some View {
        let todayMeals = mealsViewModel.getTodayMeals()
        let yesterdayStats = mealsViewModel.getYesterdayStats()
        let todayStats = mealsViewModel.getTodayStats()
        let streak = mealsViewModel.getCurrentStreak()
        
        let message = advisorService.generateDailyMessage(
            todayMeals: todayMeals,
            yesterdayStats: yesterdayStats,
            todayStats: todayStats,
            currentStreak: streak,
            dailyBudget: userViewModel.profile?.dailyBudget
        )
        
        return AdvisorCard(message: message)
            .onAppear {
                // Update streak in profile
                if let profile = userViewModel.profile, profile.currentStreak != streak {
                    try? userViewModel.updateStreak(streak)
                }
            }
    }
    
    // MARK: - Stats Grid
    
    private var statsGrid: some View {
        let todayStats = mealsViewModel.getTodayStats()
        let streak = mealsViewModel.getCurrentStreak()
        let points = todayStats?.finalPoints ?? 0
        let meals = todayStats?.mealCount ?? 0
        let budget = userViewModel.profile?.dailyBudget
        let spent = todayStats?.totalSpent ?? 0
        
        return VStack(spacing: 12) {
            HStack(spacing: 12) {
                InfoTile(
                    title: "Streak",
                    value: "\(streak) days",
                    icon: "flame.fill",
                    color: Theme.Colors.chartFour
                )

                InfoTile(
                    title: "Today's Points",
                    value: "\(points) pts",
                    icon: "star.fill",
                    color: Theme.Colors.chartThree
                )
            }
            
            HStack(spacing: 12) {
                InfoTile(
                    title: "Meals",
                    value: "\(meals) / 3",
                    icon: "fork.knife",
                    color: Theme.Colors.primaryBackground
                )

                InfoTile(
                    title: "Budget",
                    value: budget != nil ? "$\(Int(spent)) / $\(Int(budget!))" : "Not set",
                    icon: "dollarsign.circle.fill",
                    color: Theme.Colors.chartFive
                )
            }
        }
    }
    
    // MARK: - 7-Day Trend
    
    private var sevenDayTrend: some View {
        let stats = mealsViewModel.getLast7DaysStats()
        
        guard !stats.isEmpty else {
            return AnyView(EmptyView())
        }
        
        let maxPoints = stats.map { $0.finalPoints }.max() ?? 1
        
        return AnyView(
            VStack(alignment: .leading, spacing: 16) {
                Text("7-Day Trend")
                    .font(Theme.Fonts.sans(size: 16, weight: .bold))
                    .foregroundColor(Theme.Colors.cardText)

                HStack(alignment: .bottom, spacing: 0) {
                    ForEach(0..<7) { index in
                        VStack(spacing: 4) {
                            if index < stats.count {
                                let stat = stats[index]
                                let height = CGFloat(stat.finalPoints) / CGFloat(maxPoints) * 80

                                Text("\(stat.finalPoints)")
                                    .font(Theme.Fonts.mono(size: 12, weight: .semibold))
                                    .foregroundColor(Theme.Colors.mutedText)

                                RoundedRectangle(cornerRadius: 4)
                                    .fill(stat.finalPoints >= 20 ? Theme.Colors.chartOne : stat.finalPoints >= 10 ? Theme.Colors.chartTwo : Theme.Colors.componentsBorder)
                                    .frame(height: max(height, 4))

                                Text(stat.dayOfWeek.prefix(1))
                                    .font(Theme.Fonts.sans(size: 11))
                                    .foregroundColor(Theme.Colors.mutedText)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 120)
            }
            .padding(16)
            .background(Theme.Colors.cardBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Theme.Colors.componentsBorder, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 3)
        )
    }
    
    // MARK: - Today's Meals Section
    
    private var todayMealsSection: some View {
        let todayMeals = mealsViewModel.getTodayMeals()
        
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Today's Meals")
                    .font(Theme.Fonts.sans(size: 20, weight: .bold))
                    .foregroundColor(Theme.Colors.cardText)

                Spacer()

                if !todayMeals.isEmpty {
                    Text("\(todayMeals.count) meal\(todayMeals.count == 1 ? "" : "s")")
                        .font(Theme.Fonts.sans(size: 14))
                        .foregroundColor(Theme.Colors.mutedText)
                }
            }

            if todayMeals.isEmpty {
                EmptyStateView(
                    icon: "fork.knife",
                    title: "No meals logged yet today",
                    message: "Tap the + button to add your first meal"
                )
                .padding(.vertical, 20)
            } else {
                ForEach(todayMeals) { meal in
                    MealRow(meal: meal) {
                        // Navigate to meal detail
                    }
                }
            }
        }
        .padding(16)
        .background(Theme.Colors.cardBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Theme.Colors.componentsBorder, lineWidth: 1)
        )
    }
}

// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(MealsViewModel())
            .environmentObject(UserViewModel())
    }
}
