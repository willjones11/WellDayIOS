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
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
        .safeAreaInset(edge: .bottom) {
            addToTodayButton
                .padding(16)
                .background(Color(.systemGroupedBackground))
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
                Color.blue.opacity(0.1)
                    .frame(height: 250)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 80))
                            .foregroundColor(.blue.opacity(0.3))
                    )
            } else {
                Color.blue.opacity(0.1)
                    .frame(height: 250)
                    .overlay(
                        Image(systemName: "book.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.blue.opacity(0.3))
                    )
            }
        }
    }
    
    // MARK: - Title Section
    
    private var titleSection: some View {
        HStack(alignment: .top) {
            Text(recipe.title)
                .font(.system(size: 26, weight: .bold))
            
            Spacer()
            
            Button(action: { try? recipesViewModel.toggleFavorite(recipe.id) }) {
                Image(systemName: recipe.isFavorite ? "heart.fill" : "heart")
                    .font(.system(size: 24))
                    .foregroundColor(recipe.isFavorite ? .red : .secondary)
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
                .font(.system(size: 28))
                .foregroundColor(.blue)
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Ingredients Section
    
    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ingredients")
                .font(.system(size: 20, weight: .bold))
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(recipe.ingredients, id: \.self) { ingredient in
                    HStack(alignment: .top, spacing: 12) {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 6, height: 6)
                            .padding(.top, 6)
                        
                        Text(ingredient)
                            .font(.system(size: 15))
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Instructions Section
    
    private func instructionsSection(_ instructions: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Instructions")
                .font(.system(size: 20, weight: .bold))
            
            Text(instructions)
                .font(.system(size: 15))
                .lineSpacing(6)
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemBackground))
                .cornerRadius(12)
        }
    }
    
    // MARK: - Add to Today Button
    
    private var addToTodayButton: some View {
        Button(action: addMealFromRecipe) {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text("Add to Today")
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.blue)
            .cornerRadius(12)
            .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
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
