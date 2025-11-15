//
//  CommonComponents.swift
//  Wellday
//
//  reusable UI components with modern interactions
//  Integrates with your existing Theme system
//

import SwiftUI

// MARK: - Animated Tier Badge with Glow Effect
struct AnimatedTierBadge: View {
    let tier: MealTier
    let compact: Bool
    @State private var isAnimating = false
    
    init(tier: MealTier, compact: Bool = false) {
        self.tier = tier
        self.compact = compact
    }
    
    var body: some View {
        HStack(spacing: compact ? 4 : 8) {
            Text(tier.emoji)
                .font(Theme.Fonts.sans(size: compact ? 14 : 18))
                .scaleEffect(isAnimating && tier == .excellent ? 1.1 : 1.0)
            
            Text(tier.label)
                .font(Theme.Fonts.sans(size: compact ? 12 : 14, weight: .bold))
                .foregroundColor(Theme.Colors.cardText)
        }
        .padding(.horizontal, compact ? 8 : 12)
        .padding(.vertical, compact ? 4 : 8)
        .background(
            ZStack {
                // Subtle gradient background
                LinearGradient(
                    colors: [tierColor.opacity(0.2), tierColor.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // Glass effect overlay
                tierColor.opacity(0.05)
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: compact ? 12 : 16)
                .stroke(
                    LinearGradient(
                        colors: [tierColor.opacity(0.6), tierColor.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .cornerRadius(compact ? 12 : 16)
        .shadow(color: tierColor.opacity(0.3), radius: 6, x: 0, y: 3)
        .onAppear {
            if tier == .excellent {
                withAnimation(
                    Animation.easeInOut(duration: 0.8)
                        .repeatForever(autoreverses: true)
                ) {
                    isAnimating = true
                }
            }
        }
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

// MARK: - Interactive Stat Card
struct InteractiveStatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    let action: (() -> Void)?
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            HapticManager.impact(style: .medium)
            action?()
        }) {
            VStack(spacing: 12) {
                // Icon with gradient background
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.3), color.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 52, height: 52)
                    
                    Image(systemName: icon)
                        .font(Theme.Fonts.sans(size: 24, weight: .semibold))
                        .foregroundColor(color)
                }
                
                Text(value)
                    .font(Theme.Fonts.sans(size: 22, weight: .bold))
                    .foregroundColor(Theme.Colors.cardText)
                
                Text(title)
                    .font(Theme.Fonts.sans(size: 12, weight: .medium))
                    .foregroundColor(Theme.Colors.mutedText)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Theme.Colors.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [color.opacity(0.4), color.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .cornerRadius(16)
            .shadow(
                color: isPressed ? .clear : .black.opacity(0.3),
                radius: isPressed ? 2 : 8,
                y: isPressed ? 1 : 4
            )
            .scaleEffect(isPressed ? 0.96 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(action == nil)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isPressed = false
                    }
                }
        )
    }
}

// MARK: - Modern Advisor Card
struct ModernAdvisorCard: View {
    let message: AdvisorMessage
    @State private var isVisible = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Animated icon with glow
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 60, height: 60)
                    .blur(radius: 8)
                
                Text(message.icon)
                    .font(Theme.Fonts.sans(size: 32))
            }
            
            Text(message.message)
                .font(Theme.Fonts.serifDisplay(size: 17))
                .foregroundColor(Theme.Colors.primaryText)
                .lineSpacing(5)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ZStack {
                // Main gradient
                LinearGradient(
                    colors: [
                        Theme.Colors.primaryBackground,
                        Theme.Colors.secondaryBackground
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // Subtle overlay for depth
                LinearGradient(
                    colors: [Color.white.opacity(0.1), Color.clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        )
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Theme.Colors.primaryBackground.opacity(0.5), radius: 12, x: 0, y: 6)
        .scaleEffect(isVisible ? 1 : 0.95)
        .opacity(isVisible ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                isVisible = true
            }
        }
    }
}

// MARK: - Meal Row with Swipe Actions
struct MealRow: View {
    let meal: Meal
    let showDate: Bool
    let onTap: (() -> Void)?
    let onDelete: (() -> Void)?
    let onShare: (() -> Void)?
    
    @State private var offset: CGFloat = 0
    @State private var isPressed = false
    
    init(
        meal: Meal,
        showDate: Bool = false,
        onTap: (() -> Void)? = nil,
        onDelete: (() -> Void)? = nil,
        onShare: (() -> Void)? = nil
    ) {
        self.meal = meal
        self.showDate = showDate
        self.onTap = onTap
        self.onDelete = onDelete
        self.onShare = onShare
    }
    
    var body: some View {
        ZStack(alignment: .trailing) {
            // Swipe actions background
            if onDelete != nil || onShare != nil {
                swipeActionsBackground
            }
            
            // Main content
            mainContent
                .offset(x: offset)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            let translation = gesture.translation.width
                            if translation < 0 {
                                offset = max(translation, -120)
                            }
                        }
                        .onEnded { _ in
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                if offset < -60 {
                                    offset = -120
                                } else {
                                    offset = 0
                                }
                            }
                        }
                )
        }
        .frame(height: 100)
        .clipped()
    }
    
    private var swipeActionsBackground: some View {
        HStack(spacing: 0) {
            Spacer()
            
            // Share button
            if onShare != nil {
                Button(action: {
                    HapticManager.impact(style: .light)
                    onShare?()
                    withAnimation(.spring()) {
                        offset = 0
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.up")
                            .font(Theme.Fonts.sans(size: 20))
                        Text("Share")
                            .font(Theme.Fonts.sans(size: 11, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .frame(width: 60)
                    .frame(maxHeight: .infinity)
                    .background(Theme.Colors.secondaryBackground)
                }
            }
            
            // Delete button
            if onDelete != nil {
                Button(action: {
                    HapticManager.notification(type: .warning)
                    onDelete?()
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "trash.fill")
                            .font(Theme.Fonts.sans(size: 20))
                        Text("Delete")
                            .font(Theme.Fonts.sans(size: 11, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .frame(width: 60)
                    .frame(maxHeight: .infinity)
                    .background(Theme.Colors.destructiveBackground)
                }
            }
        }
    }
    
    private var mainContent: some View {
        Button(action: {
            HapticManager.selection()
            onTap?()
        }) {
            HStack(spacing: 12) {
                // Meal icon with gradient
                mealIconView
                
                // Content
                VStack(alignment: .leading, spacing: 6) {
                    // Header row
                    HStack {
                        Text(meal.name)
                            .font(Theme.Fonts.sans(size: 16, weight: .semibold))
                            .foregroundColor(Theme.Colors.cardText)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Text(showDate ? meal.formattedDate : meal.formattedTime)
                            .font(Theme.Fonts.mono(size: 11))
                            .foregroundColor(Theme.Colors.mutedText)
                    }
                    
                    // Tags scroll
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
                        AnimatedTierBadge(tier: meal.tier, compact: true)
                        PointsBadge(points: meal.points)
                    }
                }
            }
            .padding(12)
            .background(Theme.Colors.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Theme.Colors.componentsBorder, lineWidth: 1)
            )
            .cornerRadius(12)
            .shadow(
                color: isPressed ? .clear : .black.opacity(0.25),
                radius: isPressed ? 2 : 6,
                y: isPressed ? 1 : 3
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isPressed = false
                    }
                }
        )
    }
    
    private var mealIconView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    LinearGradient(
                        colors: [iconColor.opacity(0.3), iconColor.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Image(systemName: meal.inputType.icon)
                .font(Theme.Fonts.sans(size: 24, weight: .semibold))
                .foregroundStyle(iconColor)
        }
        .frame(width: 64, height: 64)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(iconColor.opacity(0.4), lineWidth: 1.5)
        )
    }
    
    private var iconColor: Color {
        switch meal.inputType {
        case .photo: return Theme.Colors.accentBackground
        case .text: return Theme.Colors.primaryBackground
        case .voice: return Theme.Colors.chartFive
        case .recipe: return Theme.Colors.chartFour
        }
    }
}

// MARK: - Animated Bar Chart
struct AnimatedBarChart: View {
    let stats: [DailyStats]
    @State private var animatedHeights: [CGFloat] = []
    
    var body: some View {
        let maxPoints = stats.map { $0.finalPoints }.max() ?? 1
        
        HStack(alignment: .bottom, spacing: 0) {
            ForEach(0..<7) { index in
                if index < stats.count {
                    let stat = stats[index]
                    let targetHeight = CGFloat(stat.finalPoints) / CGFloat(maxPoints) * 90
                    let animatedHeight = index < animatedHeights.count ? animatedHeights[index] : 0
                    
                    VStack(spacing: 6) {
                        Text("\(stat.finalPoints)")
                            .font(Theme.Fonts.mono(size: 12, weight: .semibold))
                            .foregroundColor(Theme.Colors.mutedText)
                            .opacity(animatedHeight > 10 ? 1 : 0)
                        
                        // Animated bar with gradient
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    colors: barColors(for: stat.finalPoints),
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .frame(height: max(animatedHeight, 4))
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                            .shadow(color: barColors(for: stat.finalPoints)[0].opacity(0.4), radius: 4, y: 2)
                        
                        Text(stat.dayOfWeek.prefix(1))
                            .font(Theme.Fonts.sans(size: 11, weight: .medium))
                            .foregroundColor(Theme.Colors.mutedText)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .frame(height: 140)
        .onAppear {
            animatedHeights = Array(repeating: 0, count: stats.count)
            
            for (index, stat) in stats.enumerated() {
                let targetHeight = CGFloat(stat.finalPoints) / CGFloat(maxPoints) * 90
                
                withAnimation(
                    .spring(response: 0.6, dampingFraction: 0.7)
                    .delay(Double(index) * 0.08)
                ) {
                    if index < animatedHeights.count {
                        animatedHeights[index] = targetHeight
                    }
                }
            }
        }
    }
    
    private func barColors(for points: Int) -> [Color] {
        if points >= 25 {
            return [Theme.Colors.chartOne, Theme.Colors.chartTwo]
        } else if points >= 15 {
            return [Theme.Colors.chartTwo, Theme.Colors.chartThree]
        } else {
            return [Theme.Colors.chartThree, Theme.Colors.chartFour]
        }
    }
}

// MARK: - Modern Empty State
struct ModernEmptyState: View {
    let icon: String
    let title: String
    let message: String
    let action: (() -> Void)?
    
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(Theme.Fonts.sans(size: 64))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Theme.Colors.accentBackground.opacity(0.7),
                            Theme.Colors.secondaryBackground.opacity(0.7)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .scaleEffect(isAnimating ? 1.05 : 0.95)
                .animation(
                    Animation.easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true),
                    value: isAnimating
                )
            
            VStack(spacing: 8) {
                Text(title)
                    .font(Theme.Fonts.sans(size: 20, weight: .bold))
                    .foregroundColor(Theme.Colors.cardText)
                
                Text(message)
                    .font(Theme.Fonts.sans(size: 15))
                    .foregroundColor(Theme.Colors.mutedText)
                    .multilineTextAlignment(.center)
            }
            
            if let action = action {
                Button(action: {
                    HapticManager.impact(style: .medium)
                    action()
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add First Meal")
                    }
                    .font(Theme.Fonts.sans(size: 16, weight: .semibold))
                    .foregroundColor(Theme.Colors.primaryText)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [Theme.Colors.primaryBackground, Theme.Colors.secondaryBackground],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: Theme.Colors.primaryBackground.opacity(0.4), radius: 8, y: 4)
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.top, 8)
            }
        }
        .padding(.vertical, 32)
        .padding(.horizontal, 24)
        .background(Theme.Colors.cardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Theme.Colors.componentsBorder, lineWidth: 1)
        )
        .cornerRadius(20)
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Shimmer Loading Effect
struct ShimmerView: View {
    @State private var phase: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Theme.Colors.componentsBorder.opacity(0.3),
                            Theme.Colors.componentsBorder.opacity(0.6),
                            Theme.Colors.componentsBorder.opacity(0.3)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .mask(
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: .clear, location: phase - 0.3),
                                    .init(color: .white, location: phase),
                                    .init(color: .clear, location: phase + 0.3)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
                .onAppear {
                    withAnimation(
                        Animation.linear(duration: 1.5)
                            .repeatForever(autoreverses: false)
                    ) {
                        phase = 1.3
                    }
                }
        }
    }
}

// MARK: - Haptic Manager
class HapticManager {
    static func impact(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    static func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}

// MARK: - Custom Button Styles
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct PulseButtonStyle: ButtonStyle {
    @State private var isPulsing = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .scaleEffect(isPulsing ? 1.03 : 1.0)
            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isPulsing)
            .onAppear {
                isPulsing = true
            }
    }
}

// MARK: - Preview Provider
struct Components_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Theme.Colors.background.ignoresSafeArea()
            
            VStack(spacing: 20) {
                AnimatedTierBadge(tier: .excellent)
                
                InteractiveStatCard(
                    icon: "flame.fill",
                    title: "Streak",
                    value: "7 days",
                    color: Theme.Colors.chartFour,
                    action: nil
                )
                .frame(width: 160)
                
                ModernAdvisorCard(message: AdvisorMessage(
                    message: "Great job! You're on track.",
                    type: .encouragement,
                    icon: "👏"
                ))
                
                 MealRow(
                    meal: Meal.sample,
                    onTap: {},
                    onDelete: {},
                    onShare: {}
                )
            }
            .padding()
        }
    }
}
