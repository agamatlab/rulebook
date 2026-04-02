import SwiftUI

struct ChipRow<Item: Identifiable & Hashable>: View {
    let items: [Item]
    let selectedItem: Item?
    let displayText: (Item) -> String
    let onSelect: (Item) -> Void
    
    @Environment(\.themeManager) private var themeManager
    @Namespace private var animation
    
    init(
        items: [Item],
        selectedItem: Item?,
        displayText: @escaping (Item) -> String,
        onSelect: @escaping (Item) -> Void
    ) {
        self.items = items
        self.selectedItem = selectedItem
        self.displayText = displayText
        self.onSelect = onSelect
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(items) { item in
                    chipButton(for: item)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
    
    @ViewBuilder
    private func chipButton(for item: Item) -> some View {
        let isSelected = selectedItem?.id == item.id
        
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                onSelect(item)
            }
        }) {
            Text(displayText(item))
                .font(.system(size: 15, weight: isSelected ? .semibold : .medium))
                .foregroundStyle(isSelected ? themeManager.accent : themeManager.textSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Group {
                        if isSelected {
                            Capsule()
                                .fill(themeManager.accentSoft)
                                .matchedGeometryEffect(id: "selectedChip", in: animation)
                        } else {
                            Capsule()
                                .fill(themeManager.stroke.opacity(0.3))
                        }
                    }
                )
        }
        .buttonStyle(ChipButtonStyle())
    }
}

// MARK: - Button Style

struct ChipButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Preview Models

struct ChipItem: Identifiable, Hashable {
    let id: String
    let name: String
}

// MARK: - Previews

#Preview("Category Filters") {
    let categories = [
        ChipItem(id: "all", name: "All"),
        ChipItem(id: "sleep", name: "Sleep"),
        ChipItem(id: "health", name: "Health"),
        ChipItem(id: "work", name: "Work"),
        ChipItem(id: "money", name: "Money"),
        ChipItem(id: "social", name: "Social")
    ]
    
    return VStack(spacing: 24) {
        ChipRow(
            items: categories,
            selectedItem: categories[0],
            displayText: { $0.name },
            onSelect: { _ in }
        )
        
        ChipRow(
            items: categories,
            selectedItem: categories[2],
            displayText: { $0.name },
            onSelect: { _ in }
        )
        
        ChipRow(
            items: categories,
            selectedItem: nil,
            displayText: { $0.name },
            onSelect: { _ in }
        )
    }
    .background(Color(.systemGroupedBackground))
}

#Preview("Schedule Filters") {
    let schedules = [
        ChipItem(id: "all", name: "All Days"),
        ChipItem(id: "weekdays", name: "Weekdays"),
        ChipItem(id: "weekends", name: "Weekends"),
        ChipItem(id: "daily", name: "Every Day"),
        ChipItem(id: "custom", name: "Custom")
    ]
    
    return ChipRow(
        items: schedules,
        selectedItem: schedules[1],
        displayText: { $0.name },
        onSelect: { _ in }
    )
    .background(Color(.systemGroupedBackground))
}

#Preview("Status Filters") {
    let statuses = [
        ChipItem(id: "all", name: "All"),
        ChipItem(id: "active", name: "Active"),
        ChipItem(id: "paused", name: "Paused"),
        ChipItem(id: "archived", name: "Archived")
    ]
    
    return ChipRow(
        items: statuses,
        selectedItem: statuses[1],
        displayText: { $0.name },
        onSelect: { _ in }
    )
    .background(Color(.systemGroupedBackground))
}

#Preview("In Context") {
    ScrollView {
        VStack(alignment: .leading, spacing: 16) {
            Text("Filter Rules")
                .font(.system(size: 20, weight: .semibold))
                .padding(.horizontal)
            
            ChipRow(
                items: [
                    ChipItem(id: "all", name: "All"),
                    ChipItem(id: "sleep", name: "Sleep"),
                    ChipItem(id: "health", name: "Health"),
                    ChipItem(id: "work", name: "Work"),
                    ChipItem(id: "money", name: "Money")
                ],
                selectedItem: ChipItem(id: "health", name: "Health"),
                displayText: { $0.name },
                onSelect: { _ in }
            )
            
            // Placeholder cards
            VStack(spacing: 12) {
                ForEach(0..<3, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .frame(height: 100)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
    .background(Color(.systemGroupedBackground))
}

#Preview("Interactive Demo") {
    struct InteractiveDemo: View {
        @State private var selectedCategory: ChipItem?
        
        let categories = [
            ChipItem(id: "all", name: "All"),
            ChipItem(id: "sleep", name: "Sleep"),
            ChipItem(id: "health", name: "Health"),
            ChipItem(id: "work", name: "Work"),
            ChipItem(id: "money", name: "Money"),
            ChipItem(id: "social", name: "Social")
        ]
        
        var body: some View {
            VStack(spacing: 24) {
                ChipRow(
                    items: categories,
                    selectedItem: selectedCategory,
                    displayText: { $0.name },
                    onSelect: { selectedCategory = $0 }
                )
                
                if let selected = selectedCategory {
                    Text("Selected: \(selected.name)")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.secondary)
                } else {
                    Text("No selection")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
            .background(Color(.systemGroupedBackground))
        }
    }
    
    return InteractiveDemo()
}
