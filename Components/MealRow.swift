//
//  MealRow.swift
//  Wellday
//
//  Meal list item component
//

import SwiftUI

struct MealRow: View {
    let meal: Meal
    let showDate: Bool
    let action: (() -> Void)?
    
    init(
        meal: Meal,
        showDate: Bool = false,
        action: (() -> Void)? = nil
    ) {
        self.meal = meal
        self.showDate = showDate
        self.action = action
    }
    
    var body: some View {
        Button(action: { action?() }) {
            HStack(spacing: 12) {
                // Icon or photo
                mealIcon
                    .frame(width: 60, height: 60)
                    .background(iconBackgroundColor.opacity(0.12))
                    .cornerRadius(8)

                // Content
                VStack(alignment: .leading, spacing: 6) {
                    // Name and time
                    HStack {
                        Text(meal.name)
                            .font(Theme.Fonts.sans(size: 16, weight: .semibold))
                            .foregroundColor(Theme.Colors.cardText)
                            .lineLimit(1)

                        Spacer()

                        Text(showDate ? meal.formattedDate : meal.formattedTime)
                            .font(Theme.Fonts.sans(size: 12))
                            .foregroundColor(Theme.Colors.mutedText)
                    }
                    
                    // Tags
                    if !meal.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 4) {
                                ForEach(Array(meal.tags.prefix(3)), id: \.self) { tag in
                                    HealthTag(tag, small: true)
                                }
                            }
                        }
                    }
                    
                    // Tier and points
                    HStack(spacing: 8) {
                        TierBadge(tier: meal.tier, compact: true)
                        PointsBadge(points: meal.points)
                    }
                }
            }
            .padding(12)
            .background(Theme.Colors.cardBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Theme.Colors.componentsBorder, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    @ViewBuilder
    private var mealIcon: some View {
        if let photoURL = meal.photoURL {
            // In production, load actual image from URL
            Image(systemName: "photo")
                .font(Theme.Fonts.sans(size: 30, weight: .medium))
                .foregroundColor(Theme.Colors.accentBackground)
        } else {
            Image(systemName: meal.inputType.icon)
                .font(Theme.Fonts.sans(size: 30, weight: .medium))
                .foregroundColor(iconColor)
        }
    }
    
    private var iconColor: Color {
        switch meal.inputType {
        case .photo: return Theme.Colors.accentBackground
        case .text: return Theme.Colors.primaryBackground
        case .voice: return Theme.Colors.chartFive
        case .recipe: return Theme.Colors.chartFour
        }
    }

    private var iconBackgroundColor: Color {
        iconColor
    }
}

// MARK: - Preview
struct MealRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 12) {
            MealRow(meal: Meal.sample)
            MealRow(meal: Meal.samples[1], showDate: true)
            MealRow(meal: Meal.samples[2])
        }
        .padding()
        .background(Theme.Colors.background)
    }
}
