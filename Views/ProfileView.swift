
//
//  ProfileView.swift
//  Wellday
//
//  User profile and settings
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var mealsViewModel: MealsViewModel
    
    @State private var showingHealthGoalSheet = false
    @State private var showingBudgetSheet = false
    @State private var showingDietarySheet = false
    @State private var showingUnitsSheet = false
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                // Profile Header
                Section {
                    profileHeader
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }
                
                // Stats Section
                Section {
                    statsSection
                }
                
                // Settings Section
                Section("Settings") {
                    settingsRow(
                        icon: "flag.fill",
                        title: "Health Goal",
                        value: userViewModel.profile?.healthGoal.label ?? "Not set",
                        action: { showingHealthGoalSheet = true }
                    )
                    
                    settingsRow(
                        icon: "dollarsign.circle.fill",
                        title: "Daily Food Budget",
                        value: budgetValue,
                        action: { showingBudgetSheet = true }
                    )
                    
                    settingsRow(
                        icon: "fork.knife",
                        title: "Dietary Preferences",
                        value: dietaryValue,
                        action: { showingDietarySheet = true }
                    )
                    
                    settingsRow(
                        icon: "ruler.fill",
                        title: "Units",
                        value: userViewModel.profile?.unitSystem.label ?? "Imperial",
                        action: { showingUnitsSheet = true }
                    )
                }
                
                // Logout Section
                Section {
                    Button(action: { showingLogoutAlert = true }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(Theme.Colors.destructiveBackground)
                            Text("Logout")
                                .foregroundColor(Theme.Colors.destructiveBackground)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.Colors.background)
            .tint(Theme.Colors.accentBackground)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingHealthGoalSheet) {
                HealthGoalSheet()
            }
            .sheet(isPresented: $showingBudgetSheet) {
                BudgetSheet()
            }
            .sheet(isPresented: $showingDietarySheet) {
                DietarySheet()
            }
            .sheet(isPresented: $showingUnitsSheet) {
                UnitsSheet()
            }
            .alert("Logout", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Logout", role: .destructive) {
                    userViewModel.logout()
                }
            } message: {
                Text("Are you sure you want to logout? Your data will be cleared.")
            }
            .background(Theme.Colors.background.ignoresSafeArea())
        }
    }
    
    // MARK: - Profile Header
    
    private var profileHeader: some View {
        HStack {
            Circle()
                .fill(Theme.Colors.accentBackground.opacity(0.2))
                .frame(width: 80, height: 80)
                .overlay(
                    Text(userViewModel.profile?.initials ?? "U")
                        .font(Theme.Fonts.sans(size: 32, weight: .bold))
                        .foregroundColor(Theme.Colors.accentBackground)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(userViewModel.profile?.displayName ?? "User")
                    .font(Theme.Fonts.sans(size: 22, weight: .bold))
                    .foregroundColor(Theme.Colors.cardText)

                Text(userViewModel.profile?.email ?? "")
                    .font(Theme.Fonts.sans(size: 14))
                    .foregroundColor(Theme.Colors.mutedText)
            }

            Spacer()
        }
        .padding()
        .background(Theme.Colors.cardBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Theme.Colors.componentsBorder, lineWidth: 1)
        )
    }
    
    // MARK: - Stats Section
    
    private var statsSection: some View {
        let streak = mealsViewModel.getCurrentStreak()
        let longestStreak = userViewModel.profile?.longestStreak ?? 0
        
        return HStack(spacing: 20) {
            statItem(
                icon: "flame.fill",
                label: "Current Streak",
                value: "\(streak) days",
                color: Theme.Colors.chartFour
            )
            
            Divider()
            
            statItem(
                icon: "star.fill",
                label: "Longest Streak",
                value: "\(longestStreak) days",
                color: Theme.Colors.chartFive
            )
        }
        .padding(.vertical, 8)
    }

    private func statItem(icon: String, label: String, value: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(Theme.Fonts.sans(size: 32))
                .foregroundColor(color)

            Text(value)
                .font(Theme.Fonts.sans(size: 20, weight: .bold))
                .foregroundColor(Theme.Colors.cardText)

            Text(label)
                .font(Theme.Fonts.sans(size: 12))
                .foregroundColor(Theme.Colors.mutedText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Settings Row
    
    private func settingsRow(icon: String, title: String, value: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Theme.Colors.accentBackground)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(Theme.Fonts.sans(size: 16, weight: .medium))
                        .foregroundColor(Theme.Colors.cardText)

                    Text(value)
                        .font(Theme.Fonts.sans(size: 14))
                        .foregroundColor(Theme.Colors.mutedText)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(Theme.Fonts.sans(size: 14))
                    .foregroundColor(Theme.Colors.mutedText)
            }
        }
    }
    
    // MARK: - Computed Values
    
    private var budgetValue: String {
        if let budget = userViewModel.profile?.dailyBudget {
            return "$\(String(format: "%.2f", budget))"
        }
        return "Not set"
    }
    
    private var dietaryValue: String {
        let preferences = userViewModel.profile?.dietaryPreferences ?? []
        return preferences.isEmpty ? "None selected" : preferences.joined(separator: ", ")
    }
}

// MARK: - Health Goal Sheet
struct HealthGoalSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userViewModel: UserViewModel
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(HealthGoal.allCases, id: \.self) { goal in
                    Button(action: {
                        try? userViewModel.updateProfile(healthGoal: goal)
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: goal.icon)
                                .foregroundColor(Theme.Colors.accentBackground)

                            Text(goal.label)
                                .foregroundColor(Theme.Colors.cardText)

                            Spacer()

                            if userViewModel.profile?.healthGoal == goal {
                                Image(systemName: "checkmark")
                                    .foregroundColor(Theme.Colors.accentBackground)
                            }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.Colors.background)
            .tint(Theme.Colors.accentBackground)
            .navigationTitle("Health Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Theme.Colors.mutedText)
                }
            }
            .background(Theme.Colors.background.ignoresSafeArea())
        }
    }
}

// MARK: - Budget Sheet
struct BudgetSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userViewModel: UserViewModel
    @State private var budgetText = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Daily Budget ($)", text: $budgetText)
                        .keyboardType(.decimalPad)
                } footer: {
                    Text("Optional: Set a daily food budget to track spending")
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.Colors.background)
            .tint(Theme.Colors.accentBackground)
            .navigationTitle("Daily Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Theme.Colors.mutedText)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let budget = Double(budgetText)
                        try? userViewModel.updateProfile(dailyBudget: budget)
                        dismiss()
                    }
                    .disabled(budgetText.isEmpty)
                }
            }
            .onAppear {
                if let budget = userViewModel.profile?.dailyBudget {
                    budgetText = String(format: "%.2f", budget)
                }
            }
            .background(Theme.Colors.background.ignoresSafeArea())
        }
    }
}

// MARK: - Dietary Sheet
struct DietarySheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userViewModel: UserViewModel
    @State private var selectedPreferences: Set<String> = []
    
    private let availablePreferences = [
        "Vegetarian", "Vegan", "Gluten-Free", "Dairy-Free",
        "Nut-Free", "Kosher", "Halal"
    ]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(availablePreferences, id: \.self) { pref in
                    Button(action: { togglePreference(pref) }) {
                        HStack {
                            Text(pref)
                                .foregroundColor(Theme.Colors.cardText)

                            Spacer()

                            if selectedPreferences.contains(pref) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(Theme.Colors.accentBackground)
                            }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.Colors.background)
            .tint(Theme.Colors.accentBackground)
            .navigationTitle("Dietary Preferences")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Theme.Colors.mutedText)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        try? userViewModel.updateProfile(dietaryPreferences: Array(selectedPreferences))
                        dismiss()
                    }
                }
            }
            .onAppear {
                selectedPreferences = Set(userViewModel.profile?.dietaryPreferences ?? [])
            }
            .background(Theme.Colors.background.ignoresSafeArea())
        }
    }
    
    private func togglePreference(_ pref: String) {
        if selectedPreferences.contains(pref) {
            selectedPreferences.remove(pref)
        } else {
            selectedPreferences.insert(pref)
        }
    }
}

// MARK: - Units Sheet
struct UnitsSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userViewModel: UserViewModel
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(UnitSystem.allCases, id: \.self) { unit in
                    Button(action: {
                        try? userViewModel.updateProfile(unitSystem: unit)
                        dismiss()
                    }) {
                        HStack {
                            Text(unit.label)
                                .foregroundColor(Theme.Colors.cardText)

                            Spacer()

                            if userViewModel.profile?.unitSystem == unit {
                                Image(systemName: "checkmark")
                                    .foregroundColor(Theme.Colors.accentBackground)
                            }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.Colors.background)
            .tint(Theme.Colors.accentBackground)
            .navigationTitle("Units")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Theme.Colors.mutedText)
                }
            }
            .background(Theme.Colors.background.ignoresSafeArea())
        }
    }
}

// MARK: - Preview
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(UserViewModel())
            .environmentObject(MealsViewModel())
    }
}
