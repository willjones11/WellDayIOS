//
//  CommonComponents.swift
//  Wellday
//
//  Reusable UI components
//

import SwiftUI

// MARK: - Tier Badge
struct TierBadge: View {
    let tier: MealTier
    let compact: Bool
    
    init(tier: MealTier, compact: Bool = false) {
        self.tier = tier
        self.compact = compact
    }
    
    var body: some View {
        HStack(spacing: compact ? 4 : 8) {
            Text(tier.emoji)
                .font(Theme.Fonts.sans(size: compact ? 14 : 18))

            Text(tier.label)
                .font(Theme.Fonts.sans(size: compact ? 12 : 14, weight: .bold))
                .foregroundColor(Theme.Colors.cardText)
        }
        .padding(.horizontal, compact ? 8 : 12)
        .padding(.vertical, compact ? 4 : 8)
        .background(tierColor.opacity(0.15))
        .overlay(
            RoundedRectangle(cornerRadius: compact ? 12 : 16)
                .stroke(tierColor.opacity(0.3), lineWidth: 1.5)
        )
        .cornerRadius(compact ? 12 : 16)
    }

    private var tierColor: Color {
        switch tier {
        case .excellent: return Theme.Colors.primaryBackground
        case .good: return Theme.Colors.chartTwo
        case .neutral: return Theme.Colors.chartThree
        case .needsImprovement: return Theme.Colors.chartFour
        case .poor: return Theme.Colors.destructiveBackground
        }
    }
}

// MARK: - Health Tag
struct HealthTag: View {
    let tag: String
    let small: Bool
    
    init(_ tag: String, small: Bool = false) {
        self.tag = tag
        self.small = small
    }
    
    var body: some View {
        Text(formattedTag)
            .font(Theme.Fonts.sans(size: small ? 11 : 12, weight: .medium))
            .foregroundColor(tagColor)
            .padding(.horizontal, small ? 8 : 10)
            .padding(.vertical, small ? 4 : 6)
            .background(tagColor.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(tagColor.opacity(0.3), lineWidth: 1)
            )
            .cornerRadius(12)
    }
    
    private var formattedTag: String {
        tag.split(separator: "_")
            .map { String($0).capitalized }
            .joined(separator: " ")
    }
    
    private var tagColor: Color {
        if tag.contains("protein") || tag.contains("fiber") || tag.contains("nutrient") {
            return Theme.Colors.primaryBackground
        } else if tag.contains("sodium") || tag.contains("sugar") || tag.contains("processed") {
            return Theme.Colors.chartFour
        } else if tag.contains("carb") || tag.contains("balanced") {
            return Theme.Colors.chartThree
        }
        return Theme.Colors.mutedText
    }
}

// MARK: - Points Badge
struct PointsBadge: View {
    let points: Int
    let large: Bool
    
    init(points: Int, large: Bool = false) {
        self.points = points
        self.large = large
    }
    
    var body: some View {
        Text(points >= 0 ? "+\(points)" : "\(points)")
            .font(Theme.Fonts.mono(size: large ? 16 : 14, weight: .bold))
            .foregroundColor(pointsColor)
            .padding(.horizontal, large ? 12 : 8)
            .padding(.vertical, large ? 8 : 6)
            .background(pointsColor.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(pointsColor.opacity(0.4), lineWidth: 1.5)
            )
            .cornerRadius(12)
    }
    
    private var pointsColor: Color {
        if points >= 6 { return Theme.Colors.primaryBackground }
        if points >= 3 { return Theme.Colors.chartTwo }
        if points > 0 { return Theme.Colors.chartThree }
        return Theme.Colors.destructiveBackground
    }
}

// MARK: - Info Tile
struct InfoTile: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let action: (() -> Void)?
    
    init(
        title: String,
        value: String,
        icon: String,
        color: Color = .blue,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.value = value
        self.icon = icon
        self.color = color
        self.action = action
    }

    var body: some View {
        Button(action: { action?() }) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(Theme.Fonts.sans(size: 20, weight: .medium))

                    Text(title)
                        .font(Theme.Fonts.sans(size: 13, weight: .medium))
                        .foregroundColor(Theme.Colors.mutedText)
                }

                Text(value)
                    .font(Theme.Fonts.sans(size: 24, weight: .bold))
                    .foregroundColor(Theme.Colors.cardText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(Theme.Colors.cardBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Theme.Colors.componentsBorder, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 3)
        }
        .disabled(action == nil)
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Advisor Card
struct AdvisorCard: View {
    let message: AdvisorMessage
    
    var body: some View {
        HStack(spacing: 16) {
            Text(message.icon)
                .font(Theme.Fonts.sans(size: 32))

            Text(message.message)
                .font(Theme.Fonts.serifDisplay(size: 18))
                .foregroundColor(Theme.Colors.primaryText)
                .lineSpacing(4)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [Theme.Colors.primaryBackground, Theme.Colors.secondaryBackground],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .shadow(color: Theme.Colors.primaryBackground.opacity(0.4), radius: 12, x: 0, y: 6)
    }
}

// MARK: - Loading View
struct LoadingView: View {
    let message: String
    
    init(_ message: String = "Loading...") {
        self.message = message
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text(message)
                .font(Theme.Fonts.sans(size: 16))
                .foregroundColor(Theme.Colors.mutedText)
        }
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let buttonTitle: String?
    let action: (() -> Void)?
    
    init(
        icon: String,
        title: String,
        message: String,
        buttonTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.buttonTitle = buttonTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(Theme.Fonts.sans(size: 64))
                .foregroundColor(Theme.Colors.mutedText.opacity(0.8))

            Text(title)
                .font(Theme.Fonts.sans(size: 18, weight: .semibold))
                .foregroundColor(Theme.Colors.cardText)

            Text(message)
                .font(Theme.Fonts.sans(size: 14))
                .foregroundColor(Theme.Colors.mutedText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            if let buttonTitle = buttonTitle, let action = action {
                Button(action: action) {
                    Text(buttonTitle)
                        .font(Theme.Fonts.sans(size: 16, weight: .semibold))
                        .foregroundColor(Theme.Colors.primaryText)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Theme.Colors.accentBackground)
                        .cornerRadius(12)
                }
                .padding(.top, 8)
            }
        }
        .padding(32)
        .background(Theme.Colors.cardBackground)
        .cornerRadius(20)
    }
}

// MARK: - Preview Provider
struct CommonComponents_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            TierBadge(tier: .excellent)
            TierBadge(tier: .good, compact: true)

            HealthTag("protein_packed")
            HealthTag("high_sodium", small: true)

            PointsBadge(points: 10)
            PointsBadge(points: -3, large: true)

            InfoTile(
                title: "Streak",
                value: "5 days",
                icon: "flame.fill",
                color: Theme.Colors.chartFour
            )

            AdvisorCard(message: AdvisorMessage(
                message: "Great job yesterday! You're on track.",
                type: .encouragement,
                icon: "👏"
            ))
        }
        .padding()
        .background(Theme.Colors.background)
    }
}
