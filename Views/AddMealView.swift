
//
//  AddMealView.swift
//  Wellday
//
//  Multi-modal meal input view
//

import SwiftUI
import PhotosUI

struct AddMealView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var mealsViewModel: MealsViewModel
    
    @State private var selectedType: MealInputType = .text
    @State private var mealName = ""
    @State private var mealDescription = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoURL: String?
    
    @State private var isAnalyzing = false
    @State private var analyzedMeal: Meal?
    @State private var errorMessage: String?
    
    private let advisorService = AdvisorService()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Input Type Selector
                    inputTypeSelector
                    
                    // Input Area or Analysis Result
                    if analyzedMeal == nil {
                        inputArea
                        analyzeButton
                    } else {
                        analysisResult
                    }
                }
                .padding(16)
            }
            .background(Theme.Colors.background)
            .navigationTitle("Add Meal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Theme.Colors.mutedText)
                }
            }
            .background(Theme.Colors.background.ignoresSafeArea())
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }
    
    // MARK: - Input Type Selector
    
    private var inputTypeSelector: some View {
        HStack(spacing: 0) {
            typeButton(.text, icon: "note.text", label: "Text")
            typeButton(.photo, icon: "camera.fill", label: "Photo")
            typeButton(.voice, icon: "mic.fill", label: "Voice")
            typeButton(.recipe, icon: "book.fill", label: "Recipe")
        }
        .padding(4)
        .background(Theme.Colors.cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Theme.Colors.componentsBorder, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 3)
    }
    
    private func typeButton(_ type: MealInputType, icon: String, label: String) -> some View {
        Button(action: {
            selectedType = type
            analyzedMeal = nil
            photoURL = nil
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(Theme.Fonts.sans(size: 24))
                Text(label)
                    .font(Theme.Fonts.sans(size: 12, weight: selectedType == type ? .semibold : .regular))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .foregroundColor(selectedType == type ? Theme.Colors.primaryText : Theme.Colors.mutedText)
            .background(selectedType == type ? Theme.Colors.accentBackground : Color.clear)
            .cornerRadius(8)
        }
    }
    
    // MARK: - Input Area
    
    @ViewBuilder
    private var inputArea: some View {
        switch selectedType {
        case .text:
            textInput
        case .photo:
            photoInput
        case .voice:
            voiceInput
        case .recipe:
            recipeInput
        }
    }
    
    private var textInput: some View {
        VStack(spacing: 12) {
            TextField("Meal Name", text: $mealName)
                .textFieldStyle(RoundedTextFieldStyle())

            TextEditor(text: $mealDescription)
                .frame(height: 120)
                .padding(12)
                .foregroundColor(Theme.Colors.cardText)
                .background(Theme.Colors.cardBackground)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Theme.Colors.componentsBorder, lineWidth: 1)
                )
                .overlay(alignment: .topLeading) {
                    if mealDescription.isEmpty {
                        Text("Describe your meal (ingredients, preparation, etc.)")
                            .foregroundColor(Theme.Colors.mutedText)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 20)
                            .allowsHitTesting(false)
                    }
                }
        }
    }
    
    private var photoInput: some View {
        VStack(spacing: 16) {
            TextField("Meal Name", text: $mealName)
                .textFieldStyle(RoundedTextFieldStyle())
            
            if let photoURL = photoURL {
                ZStack(alignment: .topTrailing) {
                    // Placeholder for photo
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Theme.Colors.cardBackground)
                        .frame(height: 200)
                        .overlay(
                            Image(systemName: "photo")
                                .font(Theme.Fonts.sans(size: 48))
                                .foregroundColor(Theme.Colors.accentBackground)
                        )

                    Button(action: { self.photoURL = nil }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(Theme.Fonts.sans(size: 28))
                            .foregroundColor(Theme.Colors.mutedText)
                    }
                    .padding(8)
                }
            } else {
                VStack(spacing: 16) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Theme.Colors.cardBackground)
                        .frame(height: 200)
                        .overlay(
                            VStack(spacing: 12) {
                                Image(systemName: "camera")
                                    .font(Theme.Fonts.sans(size: 48))
                                    .foregroundColor(Theme.Colors.mutedText)

                                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                                    Text("Take Photo or Choose from Library")
                                        .font(Theme.Fonts.sans(size: 16, weight: .semibold))
                                        .foregroundColor(Theme.Colors.primaryText)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 12)
                                        .background(Theme.Colors.accentBackground)
                                        .cornerRadius(12)
                                }
                            }
                        )
                }
                .onChange(of: selectedPhoto) { oldValue, newValue in
                    if newValue != nil {
                        photoURL = "photo_\(UUID().uuidString)"
                    }
                }
            }
        }
    }
    
    private var voiceInput: some View {
        VStack(spacing: 16) {
            TextField("Meal Name", text: $mealName)
                .textFieldStyle(RoundedTextFieldStyle())

            VStack(spacing: 16) {
                Image(systemName: "mic.fill")
                    .font(Theme.Fonts.sans(size: 64))
                    .foregroundColor(Theme.Colors.secondaryBackground)

                Button(action: recordVoice) {
                    Text("Tap to Record")
                        .font(Theme.Fonts.sans(size: 16, weight: .semibold))
                        .foregroundColor(Theme.Colors.primaryText)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .background(Theme.Colors.secondaryBackground)
                        .cornerRadius(12)
                }

                Text("Describe your meal with voice")
                    .font(Theme.Fonts.sans(size: 14))
                    .foregroundColor(Theme.Colors.mutedText)
            }
            .padding(32)
            .frame(maxWidth: .infinity)
            .background(Theme.Colors.cardBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Theme.Colors.componentsBorder, lineWidth: 1)
            )
        }
    }
    
    private var recipeInput: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.fill")
                .font(Theme.Fonts.sans(size: 64))
                .foregroundColor(Theme.Colors.chartFive)

            Text("Choose from Recipe Hub")
                .font(Theme.Fonts.sans(size: 18, weight: .semibold))
                .foregroundColor(Theme.Colors.cardText)

            Text("Browse your saved recipes or discover new ones")
                .font(Theme.Fonts.sans(size: 14))
                .foregroundColor(Theme.Colors.mutedText)
                .multilineTextAlignment(.center)

            Button(action: {
                dismiss()
                // TODO: Navigate to recipes tab
            }) {
                HStack {
                    Text("Go to Recipes")
                    Image(systemName: "arrow.right")
                }
                .font(Theme.Fonts.sans(size: 16, weight: .semibold))
                .foregroundColor(Theme.Colors.primaryText)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Theme.Colors.secondaryBackground)
                .cornerRadius(12)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Theme.Colors.cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Theme.Colors.componentsBorder, lineWidth: 1)
        )
    }
    
    // MARK: - Analyze Button
    
    private var analyzeButton: some View {
        Button(action: analyzeMeal) {
            if isAnalyzing {
                ProgressView()
                    .tint(Theme.Colors.primaryText)
            } else {
                Text("Analyze Meal")
                    .font(Theme.Fonts.sans(size: 16, weight: .semibold))
            }
        }
        .foregroundColor(Theme.Colors.primaryText)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(canAnalyze ? Theme.Colors.primaryBackground : Theme.Colors.componentsBorder)
        .cornerRadius(12)
        .disabled(!canAnalyze || isAnalyzing)
    }
    
    private var canAnalyze: Bool {
        !mealName.isEmpty && (selectedType == .photo ? photoURL != nil : !mealDescription.isEmpty)
    }
    
    // MARK: - Analysis Result
    
    private var analysisResult: some View {
        guard let meal = analyzedMeal else { return AnyView(EmptyView()) }
        
        let feedback = advisorService.generateMealFeedback(for: meal)
        
        return AnyView(
            VStack(alignment: .leading, spacing: 16) {
                // Feedback Card
                HStack(spacing: 12) {
                    Text(feedback.icon)
                        .font(Theme.Fonts.sans(size: 28))

                    Text(feedback.message)
                        .font(Theme.Fonts.serifDisplay(size: 18))
                        .foregroundColor(Theme.Colors.primaryText)
                        .lineSpacing(4)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    LinearGradient(colors: [Theme.Colors.primaryBackground, Theme.Colors.secondaryBackground], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .cornerRadius(16)
                .shadow(color: Theme.Colors.primaryBackground.opacity(0.4), radius: 8, x: 0, y: 4)

                Divider()

                // Meal Info
                VStack(alignment: .leading, spacing: 12) {
                    Text(meal.name)
                        .font(Theme.Fonts.sans(size: 20, weight: .bold))
                        .foregroundColor(Theme.Colors.cardText)

                    HStack(spacing: 12) {
                        TierBadge(tier: meal.tier)
                        PointsBadge(points: meal.points, large: true)
                    }
                    
                    if !meal.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                ForEach(meal.tags, id: \.self) { tag in
                                    HealthTag(tag)
                                }
                            }
                        }
                    }
                    
                    if let description = meal.description {
                        Text(description)
                            .font(Theme.Fonts.sans(size: 14))
                            .foregroundColor(Theme.Colors.mutedText)
                            .lineSpacing(4)
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

                // Action Buttons
                HStack(spacing: 12) {
                    Button(action: { analyzedMeal = nil }) {
                        Text("Try Again")
                            .font(Theme.Fonts.sans(size: 16, weight: .semibold))
                            .foregroundColor(Theme.Colors.accentBackground)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Theme.Colors.accentBackground, lineWidth: 2)
                            )
                    }

                    Button(action: saveMeal) {
                        HStack {
                            Image(systemName: "checkmark")
                            Text("Save to Day")
                        }
                        .font(Theme.Fonts.sans(size: 16, weight: .semibold))
                        .foregroundColor(Theme.Colors.primaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Theme.Colors.primaryBackground)
                        .cornerRadius(12)
                    }
                }
            }
        )
    }
    
    // MARK: - Actions
    
    private func recordVoice() {
        // Mock voice recording
        mealDescription = "I had a smoothie with banana, spinach, protein powder, and almond milk"
    }
    
    private func analyzeMeal() {
        Task {
            isAnalyzing = true
            
            do {
                let meal: Meal
                
                switch selectedType {
                case .text:
                    meal = try await mealsViewModel.analyzeMealFromText(mealDescription, name: mealName)
                case .photo:
                    meal = try await mealsViewModel.analyzeMealFromPhoto(photoURL!, name: mealName)
                case .voice:
                    meal = try await mealsViewModel.analyzeMealFromVoice(mealDescription, name: mealName)
                case .recipe:
                    return
                }
                
                analyzedMeal = meal
            } catch {
                errorMessage = "Error analyzing meal: \(error.localizedDescription)"
            }
            
            isAnalyzing = false
        }
    }
    
    private func saveMeal() {
        guard let meal = analyzedMeal else { return }
        
        do {
            try mealsViewModel.addMeal(meal)
            dismiss()
        } catch {
            errorMessage = "Error saving meal: \(error.localizedDescription)"
        }
    }
}

// MARK: - Rounded Text Field Style
struct RoundedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .foregroundColor(Theme.Colors.cardText)
            .padding(12)
            .background(Theme.Colors.inputBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Theme.Colors.inputBorder, lineWidth: 1)
            )
    }
}

// MARK: - Preview
struct AddMealView_Previews: PreviewProvider {
    static var previews: some View {
        AddMealView()
            .environmentObject(MealsViewModel())
    }
}
