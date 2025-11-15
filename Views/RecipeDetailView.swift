//
//  RecipeDetailView.swift
//  Wellday
//
//  Detailed recipe view with add to today functionality
//

import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var recipesViewModel: RecipesViewModel
    @EnvironmentObject var mealsViewModel: MealsViewModel
    
    @State private var showingSuccessAlert = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Photo or placeholder
                photoSection
                
                // Content
                VStack(alignment: .leading, spacing: 20) {
                    // Title and favorite
                    titleSection
                    
                    // Tier and tags
                    tierSection
                    
                    // Info cards
                    infoCards
                    
                    // Ingredients
                    ingredientsSection
                    
                    // Instructions
                    if let instructions = recipe.instructions {
                        instructionsSection(instructions)
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(16)
            }
        }
        .background(Theme.Colors.background)
        .navigationBarTitleDisplayMode(.inline)
        .background(Theme.Colors.background)
        .safeAreaInset(edge: .bottom) {
            addToTodayButton
                .padding(16)
                .background(Theme.Colors.mutedBackground)
        }
        .alert("Added to Today!", isPresented: $showingSuccessAlert) {
            Button("OK") { dismiss() }
        } message: {
            Text("\(recipe.title) has been added to today's meals")
        }
    }
    
    // MARK: - Photo Section
    
    private var photoSection: some View {
        Group {
            if let photoURL = recipe.photoURL {
                Theme.Colors.accentBackground.opacity(0.15)
                    .frame(height: 250)
                    .overlay(
                        Image(systemName: "photo")
                            .font(Theme.Fonts.sans(size: 80))
                            .foregroundColor(Theme.Colors.accentBackground.opacity(0.4))
                    )
            } else {
                Theme.Colors.accentBackground.opacity(0.15)
                    .frame(height: 250)
                    .overlay(
                        Image(systemName: "book.fill")
                            .font(Theme.Fonts.sans(size: 80))
                            .foregroundColor(Theme.Colors.accentBackground.opacity(0.4))
                    )
            }
        }
    }
    
    // MARK: - Title Section
    
    private var titleSection: some View {
        HStack(alignment: .top) {
            Text(recipe.title)
                .font(Theme.Fonts.sans(size: 26, weight: .bold))
                .foregroundColor(Theme.Colors.cardText)

            Spacer()

            Button(action: { try? recipesViewModel.toggleFavorite(recipe.id) }) {
                Image(systemName: recipe.isFavorite ? "heart.fill" : "heart")
                    .font(Theme.Fonts.sans(size: 24))
                    .foregroundColor(recipe.isFavorite ? Theme.Colors.destructiveBackground : Theme.Colors.mutedText)
            }
        }
    }
    
    // MARK: - Tier Section
    
    private var tierSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            TierBadge(tier: recipe.tier)
            
            if !recipe.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(recipe.tags, id: \.self) { tag in
                            HealthTag(tag)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Info Cards
    
    @ViewBuilder
    private var infoCards: some View {
        HStack(spacing: 12) {
            if let prepTime = recipe.prepTimeMinutes {
                infoCard(
                    icon: "clock.fill",
                    label: "Prep Time",
                    value: "\(prepTime) min"
                )
            }
            
            if let cost = recipe.estimatedCost {
                infoCard(
                    icon: "dollarsign.circle.fill",
                    label: "Est. Cost",
                    value: "$\(String(format: "%.2f", cost))"
                )
            }
        }
    }
    
    private func infoCard(icon: String, label: String, value: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(Theme.Fonts.sans(size: 28))
                .foregroundColor(Theme.Colors.accentBackground)

            Text(label)
                .font(Theme.Fonts.sans(size: 12))
                .foregroundColor(Theme.Colors.mutedText)

            Text(value)
                .font(Theme.Fonts.sans(size: 16, weight: .bold))
                .foregroundColor(Theme.Colors.cardText)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Theme.Colors.cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Theme.Colors.componentsBorder, lineWidth: 1)
        )
    }
    
    // MARK: - Ingredients Section
    
    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ingredients")
                .font(Theme.Fonts.sans(size: 20, weight: .bold))
                .foregroundColor(Theme.Colors.cardText)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(recipe.ingredients, id: \.self) { ingredient in
                    HStack(alignment: .top, spacing: 12) {
                        Circle()
                            .fill(Theme.Colors.accentBackground)
                            .frame(width: 6, height: 6)
                            .padding(.top, 6)

                        Text(ingredient)
                            .font(Theme.Fonts.sans(size: 15))
                            .foregroundColor(Theme.Colors.cardText)
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.Colors.cardBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Theme.Colors.componentsBorder, lineWidth: 1)
            )
        }
    }
    
    // MARK: - Instructions Section
    
    private func instructionsSection(_ instructions: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Instructions")
                .font(Theme.Fonts.sans(size: 20, weight: .bold))
                .foregroundColor(Theme.Colors.cardText)

            Text(instructions)
                .font(Theme.Fonts.sans(size: 15))
                .foregroundColor(Theme.Colors.cardText)
                .lineSpacing(6)
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Theme.Colors.cardBackground)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Theme.Colors.componentsBorder, lineWidth: 1)
                )
        }
    }
    
    // MARK: - Add to Today Button
    
    private var addToTodayButton: some View {
        Button(action: addMealFromRecipe) {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text("Add to Today")
            }
            .font(Theme.Fonts.sans(size: 16, weight: .semibold))
            .foregroundColor(Theme.Colors.primaryText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Theme.Colors.primaryBackground)
            .cornerRadius(12)
            .shadow(color: Theme.Colors.primaryBackground.opacity(0.4), radius: 10, x: 0, y: 4)
        }
    }
    
    // MARK: - Actions
    
    private func addMealFromRecipe() {
        let meal = recipesViewModel.createMealFromRecipe(recipe)
        
        do {
            try mealsViewModel.addMeal(meal)
            showingSuccessAlert = true
        } catch {
            // Handle error
        }
    }
}

// MARK: - Preview
struct RecipeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            RecipeDetailView(recipe: .sample)
                .environmentObject(RecipesViewModel())
                .environmentObject(MealsViewModel())
        }
    }
}
