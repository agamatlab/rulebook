import SwiftUI

struct SectionHeader: View {
    let title: String
    let subtitle: String?
    let showSeeAll: Bool
    let onSeeAll: (() -> Void)?
    
    @Environment(\.themeManager) private var themeManager
    
    init(
        title: String,
        subtitle: String? = nil,
        showSeeAll: Bool = false,
        onSeeAll: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.showSeeAll = showSeeAll
        self.onSeeAll = onSeeAll
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(themeManager.textPrimary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(themeManager.textSecondary)
                }
            }
            
            Spacer()
            
            if showSeeAll {
                Button(action: {
                    onSeeAll?()
                }) {
                    HStack(spacing: 4) {
                        Text("See All")
                            .font(.system(size: 15, weight: .medium))
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundStyle(themeManager.accent)
                }
                .buttonStyle(SeeAllButtonStyle())
            }
        }
    }
}

// MARK: - Button Style

struct SeeAllButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.6 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Previews

#Preview("Basic") {
    VStack(spacing: 24) {
        SectionHeader(title: "Today's Rules")
        
        SectionHeader(
            title: "Today's Rules",
            subtitle: "3 active rules"
        )
        
        SectionHeader(
            title: "Today's Rules",
            subtitle: "3 active rules",
            showSeeAll: true,
            onSeeAll: {}
        )
        
        SectionHeader(
            title: "Recent Activity",
            showSeeAll: true,
            onSeeAll: {}
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("In Context") {
    ScrollView {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(
                title: "Today's Rules",
                subtitle: "3 active rules",
                showSeeAll: true,
                onSeeAll: {}
            )
            .padding(.horizontal)
            
            // Placeholder cards
            VStack(spacing: 12) {
                ForEach(0..<3, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .frame(height: 100)
                }
            }
            .padding(.horizontal)
            
            SectionHeader(
                title: "Insights",
                showSeeAll: false
            )
            .padding(.horizontal)
            .padding(.top, 8)
            
            // Placeholder insight
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .frame(height: 80)
                .padding(.horizontal)
        }
        .padding(.vertical)
    }
    .background(Color(.systemGroupedBackground))
}
