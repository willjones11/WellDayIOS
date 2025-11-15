
//
//  RecipeHubView.swift
//  Wellday
//
//  Recipe hub with Discover and My Recipes tabs
//

import SwiftUI

struct RecipeHubView: View {
    @EnvironmentObject var recipesViewModel: RecipesViewModel
    @State private var selectedTab = 0
    @State private var showingAddRecipe = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom Tab Bar
                tabBar

                // Content
                TabView(selection: $selectedTab) {
                    DiscoverTab()
                        .tag(0)
                    
                    MyRecipesTab()
                        .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .background(Theme.Colors.background)
            .navigationTitle("Recipes")
            .navigationBarTitleDisplayMode(.large)
            .background(Theme.Colors.background.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddRecipe = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(Theme.Colors.accentBackground)
                    }
                }
            }
            .sheet(isPresented: $showingAddRecipe) {
                AddRecipeView()
            }
        }
    }
    
    private var tabBar: some View {
        HStack(spacing: 0) {
            tabButton(title: "Discover", tag: 0)
            tabButton(title: "My Recipes", tag: 1)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .background(Theme.Colors.mutedBackground)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Theme.Colors.componentsBorder), alignment: .bottom
        )
    }

    private func tabButton(title: String, tag: Int) -> some View {
        Button(action: { selectedTab = tag }) {
            VStack(spacing: 8) {
                Text(title)
                    .font(Theme.Fonts.sans(size: 16, weight: selectedTab == tag ? .semibold : .regular))
                    .foregroundColor(selectedTab == tag ? Theme.Colors.accentBackground : Theme.Colors.mutedText)

                if selectedTab == tag {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Theme.Colors.accentBackground)
                        .frame(height: 3)
                } else {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 3)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Discover Tab
struct DiscoverTab: View {
    @EnvironmentObject var recipesViewModel: RecipesViewModel
    
    var body: some View {
        ScrollView {
            if recipesViewModel.isLoading {
                LoadingView("Loading recipes...")
                    .padding(40)
            } else if recipesViewModel.curatedRecipes.isEmpty {
                EmptyStateView(
                    icon: "book.closed",
                    title: "No curated recipes available",
                    message: "Check back soon for new recipes!"
                )
                .padding(40)
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(recipesViewModel.curatedRecipes) { recipe in
                        NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                            RecipeCard(recipe: recipe)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(16)
            }
        }
        .background(Theme.Colors.background)
    }
}

// MARK: - My Recipes Tab
struct MyRecipesTab: View {
    @EnvironmentObject var recipesViewModel: RecipesViewModel
    @State private var showingAddRecipe = false
    
    var body: some View {
        ScrollView {
            if recipesViewModel.isLoading {
                LoadingView("Loading your recipes...")
                    .padding(40)
            } else if recipesViewModel.userRecipes.isEmpty {
                EmptyStateView(
                    icon: "book",
                    title: "No recipes yet",
                    message: "Create your first recipe to get started",
                    buttonTitle: "Add Recipe",
                    action: { showingAddRecipe = true }
                )
                .padding(40)
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(recipesViewModel.userRecipes) { recipe in
                        NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                            RecipeCard(recipe: recipe)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(16)
            }
        }
        .background(Theme.Colors.background)
        .sheet(isPresented: $showingAddRecipe) {
            AddRecipeView()
        }
    }
}

// MARK: - Recipe Card
struct RecipeCard: View {
    let recipe: Recipe
    @EnvironmentObject var recipesViewModel: RecipesViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Photo or placeholder
            if let photoURL = recipe.photoURL {
                Theme.Colors.accentBackground.opacity(0.15)
                    .frame(height: 180)
                    .overlay(
                        Image(systemName: "photo")
                            .font(Theme.Fonts.sans(size: 60))
                            .foregroundColor(Theme.Colors.accentBackground.opacity(0.4))
                    )
            } else {
                Theme.Colors.accentBackground.opacity(0.15)
                    .frame(height: 180)
                    .overlay(
                        Image(systemName: "book.fill")
                            .font(Theme.Fonts.sans(size: 60))
                            .foregroundColor(Theme.Colors.accentBackground.opacity(0.4))
                    )
            }
            
            // Content
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    Text(recipe.title)
                        .font(Theme.Fonts.sans(size: 18, weight: .bold))
                        .foregroundColor(Theme.Colors.cardText)
                        .lineLimit(2)
                    
                    Spacer()
                    
                    Button(action: { try? recipesViewModel.toggleFavorite(recipe.id) }) {
                        Image(systemName: recipe.isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(recipe.isFavorite ? Theme.Colors.destructiveBackground : Theme.Colors.mutedText)
                    }
                }
                
                TierBadge(tier: recipe.tier, compact: true)
                
                if !recipe.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            ForEach(Array(recipe.tags.prefix(3)), id: \.self) { tag in
                                HealthTag(tag, small: true)
                            }
                        }
                    }
                }
                
                HStack(spacing: 16) {
                    if let prepTime = recipe.prepTimeMinutes {
                        Label("\(prepTime) min", systemImage: "clock")
                            .font(Theme.Fonts.sans(size: 13))
                            .foregroundColor(Theme.Colors.mutedText)
                    }

                    if let cost = recipe.estimatedCost {
                        Label("$\(String(format: "%.2f", cost))", systemImage: "dollarsign.circle")
                            .font(Theme.Fonts.sans(size: 13))
                            .foregroundColor(Theme.Colors.mutedText)
                    }

                    Label("\(recipe.ingredients.count) items", systemImage: "list.bullet")
                        .font(Theme.Fonts.sans(size: 13))
                        .foregroundColor(Theme.Colors.mutedText)
                }
            }
            .padding(16)
        }
        .background(Theme.Colors.cardBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Theme.Colors.componentsBorder, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Preview
struct RecipeHubView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeHubView()
            .environmentObject(RecipesViewModel())
    }
}
