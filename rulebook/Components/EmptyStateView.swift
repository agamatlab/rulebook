import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let headline: String
    let explanation: String
    let actionTitle: String?
    let onAction: (() -> Void)?
    
    @Environment(\.themeManager) private var themeManager
    
    init(
        icon: String,
        headline: String,
        explanation: String,
        actionTitle: String? = nil,
        onAction: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.headline = headline
        self.explanation = explanation
        self.actionTitle = actionTitle
        self.onAction = onAction
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // Icon
            Image(systemName: icon)
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(themeManager.textSecondary.opacity(0.5))
                .padding(.bottom, 8)
            
            // Text content
            VStack(spacing: 8) {
                Text(headline)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(themeManager.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(explanation)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(themeManager.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 32)
            
            // Action button
            if let actionTitle = actionTitle, let onAction = onAction {
                Button(action: onAction) {
                    Text(actionTitle)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(themeManager.accent)
                        )
                }
                .buttonStyle(EmptyStateButtonStyle())
                .padding(.top, 8)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Button Style

struct EmptyStateButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Previews

#Preview("No Rules") {
    EmptyStateView(
        icon: "book.closed",
        headline: "No rules yet",
        explanation: "Create your first rule to start building better habits.",
        actionTitle: "Create Rule",
        onAction: {}
    )
    .background(Color(.systemGroupedBackground))
}

#Preview("No Active Rules Today") {
    EmptyStateView(
        icon: "checkmark.circle",
        headline: "All done for today",
        explanation: "You've completed all your active rules. Great work!",
        actionTitle: nil,
        onAction: nil
    )
    .background(Color(.systemGroupedBackground))
}

#Preview("No Search Results") {
    EmptyStateView(
        icon: "magnifyingglass",
        headline: "No results found",
        explanation: "Try adjusting your search or filters to find what you're looking for.",
        actionTitle: "Clear Filters",
        onAction: {}
    )
    .background(Color(.systemGroupedBackground))
}

#Preview("No Archived Rules") {
    EmptyStateView(
        icon: "archivebox",
        headline: "No archived rules",
        explanation: "Rules you archive will appear here for future reference.",
        actionTitle: nil,
        onAction: nil
    )
    .background(Color(.systemGroupedBackground))
}

#Preview("No Activity") {
    EmptyStateView(
        icon: "chart.bar",
        headline: "No activity yet",
        explanation: "Start completing rules to see your progress and insights here.",
        actionTitle: "View Today's Rules",
        onAction: {}
    )
    .background(Color(.systemGroupedBackground))
}

#Preview("In Tab View") {
    TabView {
        EmptyStateView(
            icon: "book.closed",
            headline: "No rules yet",
            explanation: "Create your first rule to start building better habits.",
            actionTitle: "Create Rule",
            onAction: {}
        )
        .background(Color(.systemGroupedBackground))
        .tabItem {
            Label("Rules", systemImage: "book")
        }
    }
}
