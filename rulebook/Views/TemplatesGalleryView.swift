import SwiftUI

// MARK: - Templates Gallery View
// Thoughtful library of starter rules grouped by category
// Each template shows category icon, rule statement, and brief explanation
// Tapping a template prefills the NewRuleFlow

struct TemplatesGalleryView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    let onSelectTemplate: (RuleTemplate) -> Void
    
    private var theme: AppTheme {
        themeManager.currentTheme
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    // Header
                    headerSection
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                    
                    // Template categories
                    ForEach(RuleTemplate.groupedByCategory, id: \.category) { group in
                        templateCategorySection(group)
                    }
                }
                .padding(.bottom, 40)
            }
            .background(theme.backgroundPrimaryColor)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(theme.accentColor)
                }
            }
        }
    }
    
    // MARK: - Components
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Start from a useful rule")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(theme.textPrimaryColor)
            
            Text("Tap any template to customize it for yourself")
                .font(.system(size: 16))
                .foregroundColor(theme.textSecondaryColor)
        }
    }
    
    private func templateCategorySection(_ group: TemplateGroup) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Category header
            HStack(spacing: 8) {
                Image(systemName: group.categoryIcon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(theme.accentColor)
                
                Text(group.category)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(theme.textPrimaryColor)
            }
            .padding(.horizontal, 20)
            
            // Template cards
            VStack(spacing: 12) {
                ForEach(group.templates) { template in
                    templateCard(template)
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private func templateCard(_ template: RuleTemplate) -> some View {
        Button {
            onSelectTemplate(template)
            dismiss()
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                // Category badge
                HStack(spacing: 6) {
                    Image(systemName: template.categoryIcon)
                        .font(.system(size: 12, weight: .medium))
                    
                    Text(template.category)
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundColor(theme.accentColor)
                
                // Rule statement
                Text(template.statement)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(theme.textPrimaryColor)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                
                // Explanation
                Text(template.explanation)
                    .font(.system(size: 14))
                    .foregroundColor(theme.textSecondaryColor)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(theme.surfaceColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(theme.strokeColor, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Template Models

struct RuleTemplate: Identifiable {
    let id = UUID()
    let category: String
    let categoryIcon: String
    let statement: String
    let explanation: String
    let successDefinition: String
    let suggestedSchedule: Schedule
}

struct TemplateGroup {
    let category: String
    let categoryIcon: String
    let templates: [RuleTemplate]
}

// MARK: - Template Data

extension RuleTemplate {
    static let allTemplates: [RuleTemplate] = [
        // Sleep & Recovery
        RuleTemplate(
            category: "Sleep & Recovery",
            categoryIcon: "bed.double",
            statement: "No screens after 11 PM",
            explanation: "Better sleep quality by reducing blue light exposure",
            successDefinition: "All screens off by 11 PM",
            suggestedSchedule: .everyDay
        ),
        RuleTemplate(
            category: "Sleep & Recovery",
            categoryIcon: "bed.double",
            statement: "In bed by 10:30 PM on weeknights",
            explanation: "Consistent sleep schedule for better rest",
            successDefinition: "In bed with lights off by 10:30 PM",
            suggestedSchedule: .weekdays
        ),
        
        // Physical Health
        RuleTemplate(
            category: "Physical Health",
            categoryIcon: "figure.walk",
            statement: "Walk for 10 minutes after lunch",
            explanation: "Improve digestion and break up sedentary time",
            successDefinition: "10-minute walk completed after lunch",
            suggestedSchedule: .everyDay
        ),
        RuleTemplate(
            category: "Physical Health",
            categoryIcon: "figure.walk",
            statement: "Take stairs instead of elevator",
            explanation: "Build movement into daily routine",
            successDefinition: "Used stairs for all trips under 5 floors",
            suggestedSchedule: .everyDay
        ),
        
        // Nutrition
        RuleTemplate(
            category: "Nutrition",
            categoryIcon: "fork.knife",
            statement: "Drink water with every meal",
            explanation: "Stay hydrated throughout the day",
            successDefinition: "Full glass of water with each meal",
            suggestedSchedule: .everyDay
        ),
        RuleTemplate(
            category: "Nutrition",
            categoryIcon: "fork.knife",
            statement: "No snacking after 8 PM",
            explanation: "Better digestion and sleep quality",
            successDefinition: "No food consumed after 8 PM",
            suggestedSchedule: .everyDay
        ),
        
        // Mental Health
        RuleTemplate(
            category: "Mental Health",
            categoryIcon: "brain.head.profile",
            statement: "5 minutes of morning meditation",
            explanation: "Start the day with calm and focus",
            successDefinition: "5 minutes of quiet meditation before breakfast",
            suggestedSchedule: .everyDay
        ),
        
        // Focus & Deep Work
        RuleTemplate(
            category: "Focus & Deep Work",
            categoryIcon: "brain",
            statement: "No meetings before 10 AM",
            explanation: "Protect morning hours for deep work",
            successDefinition: "Calendar clear until 10 AM",
            suggestedSchedule: .weekdays
        ),
        RuleTemplate(
            category: "Focus & Deep Work",
            categoryIcon: "brain",
            statement: "Phone on Do Not Disturb during focused work",
            explanation: "Minimize interruptions for better concentration",
            successDefinition: "DND enabled during work blocks",
            suggestedSchedule: .weekdays
        ),
        
        // Money & Spending
        RuleTemplate(
            category: "Money & Spending",
            categoryIcon: "dollarsign.circle",
            statement: "Wait 48 hours before non-essential purchases",
            explanation: "Reduce impulse buying and save money",
            successDefinition: "No purchases over $50 without 48-hour wait",
            suggestedSchedule: .everyDay
        ),
        
        // Digital Hygiene
        RuleTemplate(
            category: "Digital Hygiene",
            categoryIcon: "iphone",
            statement: "No phone during meals",
            explanation: "Be present and mindful while eating",
            successDefinition: "Phone away during all meals",
            suggestedSchedule: .everyDay
        ),
        RuleTemplate(
            category: "Digital Hygiene",
            categoryIcon: "iphone",
            statement: "Check email only twice per day",
            explanation: "Reduce constant context switching",
            successDefinition: "Email checked at 10 AM and 3 PM only",
            suggestedSchedule: .weekdays
        ),
        
        // Relationships
        RuleTemplate(
            category: "Relationships",
            categoryIcon: "person.2",
            statement: "Call a friend or family member weekly",
            explanation: "Maintain meaningful connections",
            successDefinition: "One meaningful call completed this week",
            suggestedSchedule: .specificDays([1])
        )
    ]
    
    static var groupedByCategory: [TemplateGroup] {
        let grouped = Dictionary(grouping: allTemplates) { $0.category }
        return grouped.map { category, templates in
            TemplateGroup(
                category: category,
                categoryIcon: templates.first?.categoryIcon ?? "circle",
                templates: templates
            )
        }.sorted { $0.category < $1.category }
    }
}

// MARK: - Preview

#Preview {
    TemplatesGalleryView(onSelectTemplate: { _ in })
        .environmentObject(ThemeManager())
}
