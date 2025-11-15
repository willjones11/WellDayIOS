//
//  HomeView.swift
//  Wellday
//
//  home screen with modern UI/UX - Dark Theme Edition
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var mealsViewModel: MealsViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    
    @State private var showingAddMeal = false
    @State private var isRefreshing = false
    @State private var headerOpacity: Double = 1.0
    
    private let advisorService = AdvisorService()
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                // Main ScrollView with pull-to-refresh
                ScrollViewWithRefresh(isRefreshing: $isRefreshing, onRefresh: refreshData) {
                    LazyVStack(spacing: 20) {
                        // Animated header greeting
                        headerGreeting
                            .opacity(headerOpacity)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        
                        // Advisor card with entrance animation
                        advisorCard
                            .transition(.scale.combined(with: .opacity))
                        
                        // Stats grid with staggered animation
                        statsGrid
                            .transition(.move(edge: .leading).combined(with: .opacity))
                        
                        // 7-Day trend chart
                        trendChart
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                        
                        // Today's meals section
                        todayMealsSection
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        
                        // Bottom spacing for FAB
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
                .background(Theme.Colors.background.ignoresSafeArea())
                
                // Floating Action Button with pulse animation
                floatingActionButton
                    .padding(20)
            }
            .navigationTitle("Wellday")
            .navigationBarTitleDisplayMode(.large)
            .background(Theme.Colors.background.ignoresSafeArea())
            .sheet(isPresented: $showingAddMeal) {
                AddMealView()
            }
        }
    }
    
    // MARK: - Header Greeting
    
    private var headerGreeting: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(greetingMessage)
                    .font(Theme.Fonts.sans(size: 15, weight: .medium))
                    .foregroundColor(Theme.Colors.mutedText)
                
                if let userName = userViewModel.profile?.displayName {
                    Text(userName)
                        .font(Theme.Fonts.sans(size: 30, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Theme.Colors.accentBackground, Theme.Colors.secondaryBackground],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
            }
            
            Spacer()
            
            // Profile avatar with animated ring
            profileAvatar
        }
        .padding(.bottom, 8)
    }
    
    private var greetingMessage: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        default: return "Good Evening"
        }
    }
    
    private var profileAvatar: some View {
        ZStack {
            // Animated ring
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            Theme.Colors.accentBackground.opacity(0.7),
                            Theme.Colors.secondaryBackground.opacity(0.7)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )
                .frame(width: 54, height: 54)
            
            // Avatar
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Theme.Colors.accentBackground.opacity(0.2),
                            Theme.Colors.secondaryBackground.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 50, height: 50)
                .overlay(
                    Text(userViewModel.profile?.initials ?? "U")
                        .font(Theme.Fonts.sans(size: 18, weight: .bold))
                        .foregroundColor(Theme.Colors.accentBackground)
                )
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
        
        return ModernAdvisorCard(message: message)
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
                InteractiveStatCard(
                    icon: "flame.fill",
                    title: "Day Streak",
                    value: "\(streak)",
                    color: Theme.Colors.chartFour,
                    action: nil
                )
                
                InteractiveStatCard(
                    icon: "star.fill",
                    title: "Today's Points",
                    value: "\(points)",
                    color: Theme.Colors.chartThree,
                    action: nil
                )
            }
            
            HStack(spacing: 12) {
                InteractiveStatCard(
                    icon: "fork.knife",
                    title: "Meals Today",
                    value: "\(meals) / 3",
                    color: Theme.Colors.primaryBackground,
                    action: { showingAddMeal = true }
                )
                
                InteractiveStatCard(
                    icon: "dollarsign.circle.fill",
                    title: "Budget",
                    value: budget != nil ? "$\(Int(spent))" : "Not set",
                    color: Theme.Colors.chartFive,
                    action: nil
                )
            }
        }
    }
    
    // MARK: - Trend Chart
    
    private var trendChart: some View {
        let stats = mealsViewModel.getLast7DaysStats()
        
        guard !stats.isEmpty else {
            return AnyView(EmptyView())
        }
        
        return AnyView(
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("7-Day Progress")
                        .font(Theme.Fonts.sans(size: 18, weight: .bold))
                        .foregroundColor(Theme.Colors.cardText)
                    
                    Spacer()
                    
                    // Average indicator
                    if !stats.isEmpty {
                        let avg = stats.reduce(0) { $0 + $1.finalPoints } / stats.count
                        HStack(spacing: 4) {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(Theme.Fonts.sans(size: 12))
                            Text("Avg: \(avg)")
                                .font(Theme.Fonts.mono(size: 12, weight: .semibold))
                        }
                        .foregroundColor(Theme.Colors.mutedText)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Theme.Colors.mutedBackground)
                        .cornerRadius(8)
                    }
                }
                
                AnimatedBarChart(stats: stats)
            }
            .padding(16)
            .background(Theme.Colors.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Theme.Colors.componentsBorder, lineWidth: 1)
            )
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
        )
    }
    
    // MARK: - Today's Meals
    
    private var todayMealsSection: some View {
        let todayMeals = mealsViewModel.getTodayMeals()
        
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Today's Meals")
                    .font(Theme.Fonts.sans(size: 22, weight: .bold))
                    .foregroundColor(Theme.Colors.cardText)
                
                Spacer()
                
                if !todayMeals.isEmpty {
                    Text("\(todayMeals.count) meal\(todayMeals.count == 1 ? "" : "s")")
                        .font(Theme.Fonts.mono(size: 13, weight: .medium))
                        .foregroundColor(Theme.Colors.mutedText)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Theme.Colors.mutedBackground)
                        .cornerRadius(10)
                }
            }
            
            if todayMeals.isEmpty {
                ModernEmptyState(
                    icon: "fork.knife.circle.fill",
                    title: "No meals yet",
                    message: "Start your day by logging your first meal",
                    action: { showingAddMeal = true }
                )
            } else {
                ForEach(Array(todayMeals.enumerated()), id: \.element.id) { index, meal in
                    MealRow(
                        meal: meal,
                        onTap: { /* Navigate to detail */ },
                        onDelete: {
                            withAnimation(.spring()) {
                                try? mealsViewModel.deleteMeal(meal.id)
                            }
                        },
                        onShare: { /* Share meal */ }
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                }
            }
        }
    }
    
    // MARK: - Floating Action Button
    
    private var floatingActionButton: some View {
        Button(action: {
            HapticManager.impact(style: .medium)
            showingAddMeal = true
        }) {
            HStack(spacing: 10) {
                Image(systemName: "plus")
                    .font(Theme.Fonts.sans(size: 18, weight: .bold))
                Text("Add Meal")
                    .font(Theme.Fonts.sans(size: 16, weight: .semibold))
            }
            .foregroundColor(Theme.Colors.primaryText)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(
                ZStack {
                    // Main gradient
                    LinearGradient(
                        colors: [Theme.Colors.primaryBackground, Theme.Colors.secondaryBackground],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    
                    // Subtle highlight
                    LinearGradient(
                        colors: [Color.white.opacity(0.2), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
            )
            .cornerRadius(28)
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: Theme.Colors.primaryBackground.opacity(0.5), radius: 12, y: 6)
        }
        .buttonStyle(PulseButtonStyle())
    }
    
    // MARK: - Actions
    
    private func refreshData() {
        HapticManager.impact(style: .light)
        mealsViewModel.loadMeals()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isRefreshing = false
        }
    }
}

// MARK: - Scroll View with Pull to Refresh

struct ScrollViewWithRefresh<Content: View>: View {
    @Binding var isRefreshing: Bool
    let onRefresh: () -> Void
    let content: Content
    
    @State private var offset: CGFloat = 0
    
    init(
        isRefreshing: Binding<Bool>,
        onRefresh: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self._isRefreshing = isRefreshing
        self.onRefresh = onRefresh
        self.content = content()
    }
    
    var body: some View {
        ScrollView {
            ZStack(alignment: .top) {
                // Refresh indicator
                if offset > 60 || isRefreshing {
                    ProgressView()
                        .tint(Theme.Colors.accentBackground)
                        .padding(.top, 20)
                }
                
                content
            }
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(
                            key: ScrollOffsetPreferenceKey.self,
                            value: geometry.frame(in: .named("scroll")).minY
                        )
                }
            )
        }
        .coordinateSpace(name: "scroll")
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
            offset = value
            
            if value > 100 && !isRefreshing {
                isRefreshing = true
                HapticManager.impact(style: .medium)
                onRefresh()
            }
        }
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Preview

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(MealsViewModel())
            .environmentObject(UserViewModel())
            .preferredColorScheme(.dark)
    }
}
