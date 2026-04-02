import SwiftUI

struct CategoryTile: View {
    let category: RuleCategory
    let completedDays: Int
    let totalDays: Int
    let weekPreview: [DayStatus]
    let isSelected: Bool
    let isEmpty: Bool
    let isDisabled: Bool
    let onTap: () -> Void
    
    @Environment(\.themeManager) private var themeManager
    @State private var isPressed = false
    @State private var glowOpacity: Double = 0.0
    
    enum DayStatus {
        case completed
        case missed
        case notScheduled
        case future
    }
    
    var body: some View {
        Button(action: {
            guard !isDisabled else { return }
            onTap()
        }) {
            VStack(alignment: .leading, spacing: 12) {
                iconBadge
                
                Spacer()
                
                categoryInfo
                
                if !isEmpty {
                    monthlySummary
                    weekPreviewRow
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 160)
            .background(tileBackground)
            .overlay(tileStroke)
            .overlay(selectionGlow)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(TileButtonStyle(isPressed: $isPressed))
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.5 : 1.0)
        .onChange(of: isSelected) { newValue in
            if newValue {
                animateSelectionGlow()
            }
        }
    }
    
    // MARK: - Icon Badge
    
    private var iconBadge: some View {
        ZStack {
            Circle()
                .fill(badgeBackground)
                .frame(width: 44, height: 44)
            
            Image(systemName: category.symbolName)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(badgeIconColor)
        }
    }
    
    private var badgeBackground: Color {
        if isEmpty {
            return themeManager.stroke.opacity(0.5)
        }
        return themeManager.accentSoft
    }
    
    private var badgeIconColor: Color {
        if isEmpty {
            return themeManager.textSecondary.opacity(0.5)
        }
        return themeManager.accent
    }
    
    // MARK: - Category Info
    
    private var categoryInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(category.name)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(themeManager.textPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            if isEmpty {
                Text("No rules yet")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(themeManager.textSecondary.opacity(0.7))
            }
        }
    }
    
    // MARK: - Monthly Summary
    
    private var monthlySummary: some View {
        HStack(spacing: 4) {
            Text("\(completedDays)")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(themeManager.accent)
            
            Text("/")
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(themeManager.textSecondary)
            
            Text("\(totalDays)")
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(themeManager.textSecondary)
            
            Text("days")
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(themeManager.textSecondary)
        }
    }
    
    // MARK: - Week Preview Row
    
    private var weekPreviewRow: some View {
        HStack(spacing: 6) {
            ForEach(0..<7, id: \.self) { index in
                if index < weekPreview.count {
                    dayPreviewDot(status: weekPreview[index])
                } else {
                    dayPreviewDot(status: .future)
                }
            }
        }
    }
    
    private func dayPreviewDot(status: DayStatus) -> some View {
        Circle()
            .fill(dotColor(for: status))
            .frame(width: 8, height: 8)
            .overlay(
                Circle()
                    .strokeBorder(dotStroke(for: status), lineWidth: 1)
            )
    }
    
    private func dotColor(for status: DayStatus) -> Color {
        switch status {
        case .completed:
            return themeManager.calendarComplete
        case .missed:
            return .clear
        case .notScheduled:
            return .clear
        case .future:
            return .clear
        }
    }
    
    private func dotStroke(for status: DayStatus) -> Color {
        switch status {
        case .completed:
            return .clear
        case .missed:
            return themeManager.calendarMissed.opacity(0.6)
        case .notScheduled:
            return themeManager.calendarNeutral.opacity(0.4)
        case .future:
            return themeManager.stroke.opacity(0.3)
        }
    }
    
    // MARK: - Tile Styling
    
    private var tileBackground: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(themeManager.surface)
            .shadow(
                color: Color.black.opacity(0.04),
                radius: 8,
                x: 0,
                y: 2
            )
    }
    
    private var tileStroke: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .strokeBorder(
                isSelected ? themeManager.accent.opacity(0.3) : themeManager.stroke,
                lineWidth: isSelected ? 2 : 1
            )
    }
    
    private var selectionGlow: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .stroke(themeManager.accent, lineWidth: 3)
            .blur(radius: 8)
            .opacity(isSelected ? glowOpacity : 0)
    }
    
    // MARK: - Animations
    
    private func animateSelectionGlow() {
        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
            glowOpacity = 0.4
        }
    }
}

// MARK: - Button Style

struct TileButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { newValue in
                isPressed = newValue
            }
    }
}

// MARK: - Previews

#Preview("Default State") {
    CategoryTile(
        category: RuleCategory(
            name: "Physical Health & Movement",
            symbolName: "figure.walk",
            description: "Exercise and movement"
        ),
        completedDays: 18,
        totalDays: 24,
        weekPreview: [.completed, .completed, .missed, .completed, .notScheduled, .completed, .completed],
        isSelected: false,
        isEmpty: false,
        isDisabled: false,
        onTap: {}
    )
    .frame(width: 180, height: 180)
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Selected State") {
    CategoryTile(
        category: RuleCategory(
            name: "Mental Health",
            symbolName: "brain.head.profile",
            description: "Mental wellness"
        ),
        completedDays: 22,
        totalDays: 24,
        weekPreview: [.completed, .completed, .completed, .completed, .completed, .completed, .completed],
        isSelected: true,
        isEmpty: false,
        isDisabled: false,
        onTap: {}
    )
    .frame(width: 180, height: 180)
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Empty State") {
    CategoryTile(
        category: RuleCategory(
            name: "Digital Hygiene",
            symbolName: "iphone",
            description: "Screen time management"
        ),
        completedDays: 0,
        totalDays: 0,
        weekPreview: [],
        isSelected: false,
        isEmpty: true,
        isDisabled: false,
        onTap: {}
    )
    .frame(width: 180, height: 180)
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Disabled State") {
    CategoryTile(
        category: RuleCategory(
            name: "Work Boundaries",
            symbolName: "briefcase",
            description: "Work-life balance"
        ),
        completedDays: 12,
        totalDays: 24,
        weekPreview: [.completed, .missed, .completed, .notScheduled, .completed, .missed, .completed],
        isSelected: false,
        isEmpty: false,
        isDisabled: true,
        onTap: {}
    )
    .frame(width: 180, height: 180)
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Grid Layout") {
    ScrollView {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ], spacing: 12) {
            ForEach(RuleCategory.defaultCategories.prefix(6)) { category in
                CategoryTile(
                    category: category,
                    completedDays: Int.random(in: 10...24),
                    totalDays: 24,
                    weekPreview: (0..<7).map { _ in
                        [CategoryTile.DayStatus.completed, .missed, .notScheduled].randomElement()!
                    },
                    isSelected: false,
                    isEmpty: false,
                    isDisabled: false,
                    onTap: {}
                )
                .frame(height: 180)
            }
        }
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}
