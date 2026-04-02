import SwiftUI

// MARK: - New Rule Flow
// 6-step staged sheet flow for creating a new rule with thoughtful pacing

struct NewRuleFlow: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.themeManager) private var themeManager
    @EnvironmentObject var categoryManager: CategoryManager
    
    @State private var currentStep: FlowStep = .statement
    @State private var ruleStatement: String = ""
    @State private var selectedCategory: RuleCategory?
    @State private var selectedSchedule: ScheduleOption = .everyDay
    @State private var specificDays: Set<Int> = []
    @State private var successDefinition: String = ""
    @State private var reason: String = ""
    @State private var reminderType: ReminderType = .none
    @State private var reminderTime: Date = Date()
    
    @State private var showingTemplates = false
    @State private var showingCustomCategory = false
    
    // ML: Rule health analyzer
    @State private var healthAnalyzer = RuleHealthAnalyzer()
    @State private var currentHealthScore: RuleHealthScore?
    
    let onSave: (NewRule) -> Void
    
    enum FlowStep: Int, CaseIterable {
        case statement = 1
        case category = 2
        case schedule = 3
        case successDefinition = 4
        case reason = 5
        case review = 6
        
        var title: String {
            switch self {
            case .statement: return "What rule do you want to keep?"
            case .category: return "Which category does this belong to?"
            case .schedule: return "When does this rule apply?"
            case .successDefinition: return "What counts as keeping this rule?"
            case .reason: return "Why does this rule matter?"
            case .review: return "Review and save"
            }
        }
        
        var progress: Double {
            Double(rawValue) / 6.0
        }
    }
    
    enum ScheduleOption {
        case everyDay
        case weekdays
        case weekends
        case specificDays
        case timeBased
        case contextBased
        
        var displayName: String {
            switch self {
            case .everyDay: return "Every day"
            case .weekdays: return "Weekdays"
            case .weekends: return "Weekends"
            case .specificDays: return "Specific days"
            case .timeBased: return "At certain times"
            case .contextBased: return "In certain situations"
            }
        }
        
        var icon: String {
            switch self {
            case .everyDay: return "calendar"
            case .weekdays: return "briefcase"
            case .weekends: return "sun.max"
            case .specificDays: return "calendar.badge.clock"
            case .timeBased: return "clock"
            case .contextBased: return "location"
            }
        }
    }
    
    enum ReminderType {
        case none
        case timeBased
        case contextBased
        case quietNudge
        
        var displayName: String {
            switch self {
            case .none: return "None"
            case .timeBased: return "Time-based"
            case .contextBased: return "Context-based"
            case .quietNudge: return "Quiet nudge only"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.backgroundPrimary
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    progressBar
                    
                    ScrollView {
                        VStack(spacing: 32) {
                            stepContent
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 32)
                    }
                    
                    navigationButtons
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(themeManager.textSecondary)
                }
            }
        }
    }
    
    // MARK: - Progress Bar
    
    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(themeManager.stroke.opacity(0.3))
                    .frame(height: 3)
                
                Rectangle()
                    .fill(themeManager.accent)
                    .frame(width: geometry.size.width * currentStep.progress, height: 3)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentStep)
            }
        }
        .frame(height: 3)
    }
    
    // MARK: - Step Content
    
    @ViewBuilder
    private var stepContent: some View {
        VStack(spacing: 24) {
            stepTitle
            
            switch currentStep {
            case .statement:
                statementStep
            case .category:
                categoryStep
            case .schedule:
                scheduleStep
            case .successDefinition:
                successDefinitionStep
            case .reason:
                reasonStep
            case .review:
                reviewStep
            }
        }
    }
    
    private var stepTitle: some View {
        Text(currentStep.title)
            .font(.system(size: 28, weight: .semibold, design: .rounded))
            .foregroundStyle(themeManager.textPrimary)
            .multilineTextAlignment(.center)
            .padding(.top, 8)
    }
    
    // MARK: - Step 1: Statement
    
    private var statementStep: some View {
        VStack(spacing: 24) {
            TextEditor(text: $ruleStatement)
                .font(.system(size: 20, weight: .regular, design: .rounded))
                .foregroundStyle(themeManager.textPrimary)
                .frame(minHeight: 120)
                .padding(16)
                .background(themeManager.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(themeManager.stroke, lineWidth: 1)
                )
                .scrollContentBackground(.hidden)
                .onChange(of: ruleStatement) { _, newValue in
                    // Real-time health analysis
                    currentHealthScore = healthAnalyzer.analyze(newValue)
                }
            
            // ML: Show health score if rule text exists
            if let score = currentHealthScore, !ruleStatement.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                RuleHealthScoreView(score: score, theme: themeManager.currentTheme)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Examples:")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(themeManager.textSecondary)
                
                exampleText("Sleep before midnight on weekdays")
                exampleText("Wait 48 hours before buying tech")
                exampleText("No phone in the bedroom")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Button(action: { showingTemplates = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 14))
                    Text("Use a template")
                        .font(.system(size: 15, weight: .medium))
                }
                .foregroundStyle(themeManager.accent)
                .padding(.vertical, 12)
            }
            .sheet(isPresented: $showingTemplates) {
                TemplatesGalleryView(onSelectTemplate: { template in
                    ruleStatement = template.statement
                    successDefinition = template.successDefinition
                    if let category = categoryManager.categories.first(where: { $0.name == template.category }) {
                        selectedCategory = category
                    }
                    showingTemplates = false
                })
                .environmentObject(themeManager)
            }
        }
    }
    
    private func exampleText(_ text: String) -> some View {
        Text("• \(text)")
            .font(.system(size: 14, weight: .regular))
            .foregroundStyle(themeManager.textSecondary.opacity(0.7))
    }
    
    // MARK: - Step 2: Category
    
    private var categoryStep: some View {
        VStack(spacing: 20) {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                ForEach(categoryManager.categories) { category in
                    categoryTile(category)
                }
            }
            
            Button(action: { showingCustomCategory = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 16))
                    Text("Create custom category")
                        .font(.system(size: 15, weight: .medium))
                }
                .foregroundStyle(themeManager.accent)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .background(themeManager.accentSoft)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .sheet(isPresented: $showingCustomCategory) {
            CreateCustomCategorySheet(
                theme: themeManager.currentTheme,
                onCreate: { category in
                    categoryManager.addCustomCategory(
                        name: category.name,
                        symbolName: category.symbolName,
                        description: category.description
                    )
                    // Select the newly created category
                    if let newCategory = categoryManager.categories.last {
                        selectedCategory = newCategory
                    }
                }
            )
            .environmentObject(themeManager)
        }
    }
    
    private func categoryTile(_ category: RuleCategory) -> some View {
        let isRecommended = currentHealthScore?.recommendedCategory == category.name && (currentHealthScore?.categoryConfidence ?? 0) > 0.6
        let isSelected = selectedCategory?.id == category.id
        
        return Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                selectedCategory = category
            }
        }) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(isSelected ? themeManager.accent : (isRecommended ? themeManager.accentSoft : themeManager.accentSoft.opacity(0.5)))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: category.symbolName)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(isSelected ? .white : themeManager.accent)
                }
                
                Text(category.name)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(themeManager.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                // AI Recommendation badge
                if isRecommended {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 10, weight: .semibold))
                        Text("RECOMMENDED")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundStyle(themeManager.accent)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(themeManager.accentSoft)
                    .clipShape(Capsule())
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 140)
            .background(isRecommended ? themeManager.accentSoft.opacity(0.2) : themeManager.surface)
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(
                        isSelected ? themeManager.accent : (isRecommended ? themeManager.accent.opacity(0.5) : themeManager.stroke),
                        lineWidth: isSelected ? 2 : (isRecommended ? 2 : 1)
                    )
            )
            .overlay(
                isSelected ?
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(themeManager.accent)
                    .padding(8)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                : nil
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Step 3: Schedule
    
    private var scheduleStep: some View {
        VStack(spacing: 12) {
            ForEach([ScheduleOption.everyDay, .weekdays, .weekends, .specificDays, .timeBased, .contextBased], id: \.displayName) { option in
                scheduleOptionRow(option)
            }
            
            if selectedSchedule == .specificDays {
                specificDaysSelector
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
    
    private func scheduleOptionRow(_ option: ScheduleOption) -> some View {
        let isRecommended = isScheduleRecommended(option)
        let isSelected = selectedSchedule == option
        
        return Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                selectedSchedule = option
            }
        }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(isSelected ? themeManager.accent : (isRecommended ? themeManager.accentSoft : themeManager.accentSoft.opacity(0.5)))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: option.icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(isSelected ? .white : themeManager.accent)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(option.displayName)
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundStyle(themeManager.textPrimary)
                    
                    // AI Recommendation badge
                    if isRecommended {
                        HStack(spacing: 4) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 10, weight: .semibold))
                            Text("RECOMMENDED")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundStyle(themeManager.accent)
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(themeManager.accent)
                }
            }
            .padding(16)
            .background(isRecommended ? themeManager.accentSoft.opacity(0.2) : themeManager.surface)
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(
                        isSelected ? themeManager.accent : (isRecommended ? themeManager.accent.opacity(0.5) : themeManager.stroke),
                        lineWidth: isSelected ? 2 : (isRecommended ? 2 : 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    // Helper to check if schedule is recommended
    private func isScheduleRecommended(_ option: ScheduleOption) -> Bool {
        guard let recommendedSchedule = currentHealthScore?.recommendedSchedule,
              let confidence = currentHealthScore?.scheduleConfidence,
              confidence > 0.6 else {
            return false
        }
        
        let recommended = recommendedSchedule.lowercased()
        
        switch option {
        case .everyDay:
            return recommended.contains("every day") || recommended.contains("daily")
        case .weekdays:
            return recommended.contains("weekday")
        case .weekends:
            return recommended.contains("weekend")
        case .specificDays:
            return recommended.contains("specific days")
        case .timeBased:
            return recommended.contains("morning") || recommended.contains("evening") || recommended.contains("bedtime")
        case .contextBased:
            return recommended.contains("times per week") || recommended.contains("3-4")
        }
    }
    
    private var specificDaysSelector: some View {
        VStack(spacing: 12) {
            Text("Select days")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(themeManager.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 8) {
                ForEach(1...7, id: \.self) { day in
                    dayButton(day)
                }
            }
        }
        .padding(16)
        .background(themeManager.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
    
    private func dayButton(_ day: Int) -> some View {
        let dayName = ["S", "M", "T", "W", "T", "F", "S"][day - 1]
        let isSelected = specificDays.contains(day)
        
        return Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                if isSelected {
                    specificDays.remove(day)
                } else {
                    specificDays.insert(day)
                }
            }
        }) {
            Text(dayName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(isSelected ? .white : themeManager.textPrimary)
                .frame(width: 40, height: 40)
                .background(isSelected ? themeManager.accent : themeManager.surface)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .strokeBorder(themeManager.stroke, lineWidth: isSelected ? 0 : 1)
                )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Step 4: Success Definition
    
    private var successDefinitionStep: some View {
        VStack(spacing: 24) {
            TextEditor(text: $successDefinition)
                .font(.system(size: 17, weight: .regular, design: .rounded))
                .foregroundStyle(themeManager.textPrimary)
                .frame(minHeight: 140)
                .padding(16)
                .background(themeManager.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(themeManager.stroke, lineWidth: 1)
                )
                .scrollContentBackground(.hidden)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Helper examples:")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(themeManager.textSecondary)
                
                exampleText("In bed with lights off by 11:45pm")
                exampleText("Added item to cart but didn't purchase for 48 hours")
                exampleText("Phone stayed in living room all night")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 8) {
                Image(systemName: "info.circle")
                    .font(.system(size: 14))
                    .foregroundStyle(themeManager.accent)
                
                Text("Rulebook tracks days as yes or no, so make this definition clear")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(themeManager.textSecondary)
            }
            .padding(16)
            .background(themeManager.accentSoft.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
    
    // MARK: - Step 5: Reason & Reminder
    
    private var reasonStep: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                TextEditor(text: $reason)
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundStyle(themeManager.textPrimary)
                    .frame(minHeight: 100)
                    .padding(16)
                    .background(themeManager.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(themeManager.stroke, lineWidth: 1)
                    )
                    .scrollContentBackground(.hidden)
                
                Text("Optional – but helps you remember why this matters")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(themeManager.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Divider()
                .background(themeManager.stroke)
            
            VStack(spacing: 16) {
                Text("Would you like a reminder?")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(themeManager.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(spacing: 8) {
                    ForEach([ReminderType.none, .timeBased, .contextBased, .quietNudge], id: \.displayName) { type in
                        reminderOptionRow(type)
                    }
                }
                
                if reminderType == .timeBased {
                    DatePicker("Reminder time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.compact)
                        .padding(16)
                        .background(themeManager.backgroundSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
    }
    
    private func reminderOptionRow(_ type: ReminderType) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                reminderType = type
            }
        }) {
            HStack {
                Text(type.displayName)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(themeManager.textPrimary)
                
                Spacer()
                
                ZStack {
                    Circle()
                        .strokeBorder(themeManager.stroke, lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if reminderType == type {
                        Circle()
                            .fill(themeManager.accent)
                            .frame(width: 14, height: 14)
                    }
                }
            }
            .padding(16)
            .background(themeManager.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(
                        reminderType == type ? themeManager.accent.opacity(0.3) : themeManager.stroke,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Step 6: Review
    
    private var reviewStep: some View {
        VStack(spacing: 24) {
            rulePreviewCard
            
            HStack(spacing: 12) {
                Button(action: {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        currentStep = .statement
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "pencil")
                            .font(.system(size: 14))
                        Text("Edit")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundStyle(themeManager.accent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(themeManager.accentSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
                
                Button(action: saveRule) {
                    Text("Save Rule")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(themeManager.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var rulePreviewCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Statement
            VStack(alignment: .leading, spacing: 8) {
                Text("Rule")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(themeManager.textSecondary)
                    .textCase(.uppercase)
                
                Text(ruleStatement)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundStyle(themeManager.textPrimary)
            }
            
            Divider()
                .background(themeManager.stroke)
            
            // Category
            if let category = selectedCategory {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(themeManager.accentSoft)
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: category.symbolName)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(themeManager.accent)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Category")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(themeManager.textSecondary)
                        
                        Text(category.name)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(themeManager.textPrimary)
                    }
                }
            }
            
            // Schedule
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(themeManager.accentSoft)
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: selectedSchedule.icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(themeManager.accent)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Schedule")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(themeManager.textSecondary)
                    
                    Text(selectedSchedule.displayName)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(themeManager.textPrimary)
                }
            }
            
            Divider()
                .background(themeManager.stroke)
            
            // Success Definition
            VStack(alignment: .leading, spacing: 8) {
                Text("What counts as kept")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(themeManager.textSecondary)
                    .textCase(.uppercase)
                
                Text(successDefinition)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(themeManager.textPrimary)
            }
            
            // Reason (if provided)
            if !reason.isEmpty {
                Divider()
                    .background(themeManager.stroke)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Why it matters")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(themeManager.textSecondary)
                        .textCase(.uppercase)
                    
                    Text(reason)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(themeManager.textPrimary)
                }
            }
            
            // Reminder (if set)
            if reminderType != .none {
                Divider()
                    .background(themeManager.stroke)
                
                HStack(spacing: 12) {
                    Image(systemName: "bell")
                        .font(.system(size: 16))
                        .foregroundStyle(themeManager.accent)
                    
                    Text("Reminder: \(reminderType.displayName)")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(themeManager.textPrimary)
                }
            }
        }
        .padding(24)
        .background(themeManager.surface)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(themeManager.stroke, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
    }
    
    // MARK: - Navigation Buttons
    
    private var navigationButtons: some View {
        HStack(spacing: 16) {
            if currentStep != .statement {
                Button(action: goBack) {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundStyle(themeManager.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(themeManager.backgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
            }
            
            if currentStep != .review {
                Button(action: goNext) {
                    HStack(spacing: 8) {
                        Text("Continue")
                            .font(.system(size: 16, weight: .semibold))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(canProceed ? themeManager.accent : themeManager.textSecondary.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(!canProceed)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(themeManager.backgroundPrimary)
    }
    
    // MARK: - Navigation Logic
    
    private var canProceed: Bool {
        switch currentStep {
        case .statement:
            return !ruleStatement.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .category:
            return selectedCategory != nil
        case .schedule:
            if selectedSchedule == .specificDays {
                return !specificDays.isEmpty
            }
            return true
        case .successDefinition:
            return !successDefinition.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .reason:
            return true // Optional step
        case .review:
            return true
        }
    }
    
    private func goNext() {
        guard canProceed else { return }
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            if let nextStep = FlowStep(rawValue: currentStep.rawValue + 1) {
                currentStep = nextStep
            }
        }
    }
    
    private func goBack() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            if let previousStep = FlowStep(rawValue: currentStep.rawValue - 1) {
                currentStep = previousStep
            }
        }
    }
    
    private func saveRule() {
        // Convert schedule option to Schedule enum
        let schedule: Schedule
        switch selectedSchedule {
        case .everyDay:
            schedule = .everyDay
        case .weekdays:
            schedule = .weekdays
        case .weekends:
            schedule = .weekends
        case .specificDays:
            schedule = .specificDays(Array(specificDays))
        case .timeBased:
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: reminderTime)
            let minute = calendar.component(.minute, from: reminderTime)
            schedule = .timeBased(hour: hour, minute: minute)
        case .contextBased:
            schedule = .contextBased("Custom context")
        }
        
        // Create reminder settings if needed
        var reminderSettings: ReminderSettings?
        if reminderType == .timeBased {
            reminderSettings = ReminderSettings(
                enabled: true,
                time: reminderTime,
                daysOfWeek: [1, 2, 3, 4, 5, 6, 7]
            )
        }
        
        // Create the rule
        let newRule = NewRule(
            statement: ruleStatement,
            successDefinition: successDefinition,
            reason: reason,
            categoryId: selectedCategory?.id,
            schedule: schedule,
            reminderSettings: reminderSettings
        )
        
        // Animate card shrinking and flying away
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            onSave(newRule)
            dismiss()
        }
    }
}

// MARK: - Previews

#Preview("Step 1 - Statement") {
    NewRuleFlow { _ in }
}

#Preview("Step 2 - Category") {
    NewRuleFlow { _ in }
}
