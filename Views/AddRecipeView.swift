//
//  AddRecipeView.swift
//  Wellday
//
//  Create new recipe form
//

import SwiftUI
import PhotosUI

struct AddRecipeView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var recipesViewModel: RecipesViewModel
    
    @State private var title = ""
    @State private var ingredientText = ""
    @State private var ingredients: [String] = []
    @State private var instructions = ""
    @State private var prepTime = ""
    @State private var cost = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoURL: String?
    @State private var selectedDietTags: Set<String> = []
    
    @State private var isSaving = false
    @State private var errorMessage: String?
    
    private let availableDietTags = [
        "vegetarian", "vegan", "gluten_free", "dairy_free",
        "low_carb", "high_protein", "keto", "paleo"
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                // Photo Section
                Section {
                    photoSection
                }
                
                // Basic Info
                Section("Basic Information") {
                    TextField("Recipe Title", text: $title)
                    
                    HStack {
                        TextField("Prep Time (min)", text: $prepTime)
                            .keyboardType(.numberPad)
                        
                        TextField("Est. Cost ($)", text: $cost)
                            .keyboardType(.decimalPad)
                    }
                }
                
                // Ingredients
                Section("Ingredients") {
                    HStack {
                        TextField("Add ingredient", text: $ingredientText)
                        
                        Button(action: addIngredient) {
                            Image(systemName: "plus.circle.fill")
                                .font(Theme.Fonts.sans(size: 28))
                                .foregroundColor(Theme.Colors.accentBackground)
                        }
                        .disabled(ingredientText.isEmpty)
                    }
                    
                    if !ingredients.isEmpty {
                        ForEach(ingredients, id: \.self) { ingredient in
                            HStack {
                                Text(ingredient)
                                Spacer()
                                Button(action: { ingredients.removeAll { $0 == ingredient } }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(Theme.Colors.destructiveBackground)
                                }
                            }
                        }
                    }
                }
                
                // Instructions
                Section("Instructions") {
                    TextEditor(text: $instructions)
                        .frame(minHeight: 120)
                        .foregroundColor(Theme.Colors.cardText)
                        .background(Theme.Colors.cardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Theme.Colors.componentsBorder, lineWidth: 1)
                        )
                }
                
                // Diet Tags
                Section("Diet Tags (Optional)") {
                    ForEach(availableDietTags, id: \.self) { tag in
                        Button(action: { toggleDietTag(tag) }) {
                            HStack {
                                Text(formatTag(tag))
                                    .foregroundColor(Theme.Colors.cardText)
                                Spacer()
                                if selectedDietTags.contains(tag) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(Theme.Colors.accentBackground)
                                }
                            }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.Colors.background)
            .tint(Theme.Colors.accentBackground)
            .navigationTitle("Add Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Theme.Colors.mutedText)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(action: saveRecipe) {
                        Text("Save")
                            .font(Theme.Fonts.sans(size: 16, weight: .semibold))
                    }
                    .disabled(!canSave || isSaving)
                }
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
            .background(Theme.Colors.background.ignoresSafeArea())
        }
    }
    
    // MARK: - Photo Section
    
    private var photoSection: some View {
        VStack {
            if let photoURL = photoURL {
                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Theme.Colors.cardBackground)
                        .frame(height: 200)
                        .overlay(
                            Image(systemName: "photo")
                                .font(Theme.Fonts.sans(size: 48))
                                .foregroundColor(Theme.Colors.accentBackground)
                        )

                    Button(action: { self.photoURL = nil; selectedPhoto = nil }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(Theme.Fonts.sans(size: 28))
                            .foregroundColor(Theme.Colors.mutedText)
                    }
                    .padding(8)
                }
            } else {
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Theme.Colors.cardBackground)
                        .frame(height: 200)
                        .overlay(
                            VStack(spacing: 8) {
                                Image(systemName: "camera")
                                    .font(Theme.Fonts.sans(size: 48))
                                    .foregroundColor(Theme.Colors.mutedText)

                                Text("Add Photo (Optional)")
                                    .font(Theme.Fonts.sans(size: 14))
                                    .foregroundColor(Theme.Colors.mutedText)
                            }
                        )
                }
                .onChange(of: selectedPhoto) { oldValue, newValue in
                    if newValue != nil {
                        photoURL = "recipe_\(UUID().uuidString)"
                    }
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private var canSave: Bool {
        !title.isEmpty && !ingredients.isEmpty
    }
    
    private func addIngredient() {
        let trimmed = ingredientText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        ingredients.append(trimmed)
        ingredientText = ""
    }
    
    private func toggleDietTag(_ tag: String) {
        if selectedDietTags.contains(tag) {
            selectedDietTags.remove(tag)
        } else {
            selectedDietTags.insert(tag)
        }
    }
    
    private func formatTag(_ tag: String) -> String {
        tag.split(separator: "_")
            .map { String($0).capitalized }
            .joined(separator: " ")
    }
    
    private func saveRecipe() {
        Task {
            isSaving = true
            
            do {
                let prepTimeInt = Int(prepTime)
                let costDouble = Double(cost)
                
                _ = try await recipesViewModel.createRecipe(
                    title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                    ingredients: ingredients,
                    instructions: instructions.isEmpty ? nil : instructions.trimmingCharacters(in: .whitespacesAndNewlines),
                    prepTimeMinutes: prepTimeInt,
                    estimatedCost: costDouble,
                    photoURL: photoURL,
                    dietTags: Array(selectedDietTags)
                )
                
                dismiss()
            } catch {
                errorMessage = "Error saving recipe: \(error.localizedDescription)"
            }
            
            isSaving = false
        }
    }
}

// MARK: - Preview
struct AddRecipeView_Previews: PreviewProvider {
    static var previews: some View {
        AddRecipeView()
            .environmentObject(RecipesViewModel())
    }
}
