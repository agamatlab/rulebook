import SwiftUI

struct CategoryDetailView: View {
    let category: RuleCategory
    @State private var selectedTab: DetailTab = .overview
    @State private var currentMonth: Date = Date()
    @State private var selectedDay: Date?
    @State private var showDaySheet = false
    @State private var ruleFilter: RuleFilter = .active
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var appState: AppState
    
    // Get actual rules from AppState
    private var categoryRules: [NewRule] {
        appState.rules.filter { rule in
            rule.categoryId == category.id
        }
    }
    
    // Computed property for rules (alias for compatibility)
    private var rules: [NewRule] {
        categoryRules
    }
    
    // Computed property for schedules
    private var schedules: [UUID: Schedule] {
        var dict: [UUID: Schedule] = [:]
        for rule in rules {
            if let schedule = rule.schedule {
                dict[rule.id] = schedule
            }
        }
        return dict
    }
    
    enum DetailTab: String, CaseIterable {
        case overview = "Overview"
        case calendar = "Calendar"
        case rules = "Rules"
    }
    
    enum RuleFilter: String, CaseIterable {
        case active = "Active"
        case paused = "Paused"
        case archived = "Archived"
    }
    
    var body: some View {
        ZStack {
            themeManager.currentTheme.backgroundPrimaryColor
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerSection
                
                segmentedControl
                
                ScrollView {
                    switch selectedTab {
                    case .overview:
                        overviewTab
                    case .calendar:
                        calendarTab
                    case .rules:
                        rulesTab
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showDaySheet) {
            if let day = selectedDay {
                DayDetailSheet(date: day, rules: filteredRulesForDay(day))
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(themeManager.currentTheme.textPrimaryColor)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            
            HStack(spacing: 16) {
                Image(systemName: category.symbolName)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(themeManager.currentTheme.accentColor)
                    .frame(width: 64, height: 64)
                    .background(themeManager.currentTheme.accentSoftColor)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(category.name)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(themeManager.currentTheme.textPrimaryColor)
                    
                    Text(monthlySummary)
                        .font(.system(size: 15))
                        .foregroundColor(themeManager.currentTheme.textSecondaryColor)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .background(themeManager.currentTheme.backgroundPrimaryColor)
    }
    
    // MARK: - Segmented Control
    
    private var segmentedControl: some View {
        HStack(spacing: 4) {
            ForEach(DetailTab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                }) {
                    Text(tab.rawValue)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(selectedTab == tab ? 
                            .white : 
                            themeManager.currentTheme.textSecondaryColor)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            selectedTab == tab ? 
                                themeManager.currentTheme.accentColor : 
                                Color.clear
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(themeManager.currentTheme.surfaceColor)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(themeManager.currentTheme.strokeColor, lineWidth: 1)
        )
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
    
    // MARK: - Overview Tab
    
    private var overviewTab: some View {
        VStack(spacing: 16) {
            summaryCard
            
            activeRulesSection
            
            insightCard
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .transition(.asymmetric(
            insertion: .opacity.combined(with: .move(edge: .trailing)),
            removal: .opacity.combined(with: .move(edge: .leading))
        ))
    }
    
    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This Month")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(themeManager.currentTheme.textSecondaryColor)
                .textCase(.uppercase)
                .tracking(0.5)
            
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("\(completedDays)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(themeManager.currentTheme.textPrimaryColor)
                
                Text("of \(scheduledDays)")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(themeManager.currentTheme.textSecondaryColor)
            }
            
            Text("scheduled days kept")
                .font(.system(size: 15))
                .foregroundColor(themeManager.currentTheme.textSecondaryColor)
            
            ProgressView(value: compliancePercentage)
                .tint(themeManager.currentTheme.accentColor)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(themeManager.currentTheme.surfaceColor)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var activeRulesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Active Rules")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(themeManager.currentTheme.textPrimaryColor)
                
                Spacer()
                
                Text("\(activeRules.count)")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(themeManager.currentTheme.textSecondaryColor)
            }
            
            ForEach(activeRules.prefix(4)) { rule in
                RuleRowView(rule: rule, theme: themeManager.currentTheme)
            }
        }
    }
    
    private var insightCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 14))
                    .foregroundColor(themeManager.currentTheme.accentColor)
                
                Text("Insight")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(themeManager.currentTheme.textSecondaryColor)
                    .textCase(.uppercase)
                    .tracking(0.5)
            }
            
            Text(insightText)
                .font(.system(size: 15))
                .foregroundColor(themeManager.currentTheme.textPrimaryColor)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(themeManager.currentTheme.surfaceElevatedColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    

    // MARK: - Calendar Tab
    
    private var calendarTab: some View {
        VStack(spacing: 16) {
            monthNavigation
            
            calendarGrid
            
            calendarLegend
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .transition(.asymmetric(
            insertion: .opacity.combined(with: .move(edge: .trailing)),
            removal: .opacity.combined(with: .move(edge: .leading))
        ))
    }
    
    private var monthNavigation: some View {
        HStack {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(themeManager.currentTheme.textPrimaryColor)
                    .frame(width: 44, height: 44)
            }
            
            Spacer()
            
            Text(monthYearString)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(themeManager.currentTheme.textPrimaryColor)
            
            Spacer()
            
            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(themeManager.currentTheme.textPrimaryColor)
                    .frame(width: 44, height: 44)
            }
        }
    }
    
    private var calendarGrid: some View {
        VStack(spacing: 8) {
            weekdayHeaders
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                ForEach(daysInMonth, id: \.self) { date in
                    if let date = date {
                        CalendarDayCell(
                            date: date,
                            state: stateForDate(date),
                            isToday: Calendar.current.isDateInToday(date),
                            theme: themeManager.currentTheme
                        )
                        .onTapGesture {
                            selectedDay = date
                            showDaySheet = true
                        }
                    } else {
                        Color.clear
                            .frame(height: 44)
                    }
                }
            }
        }
        .padding(16)
        .background(themeManager.currentTheme.surfaceColor)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var weekdayHeaders: some View {
        HStack(spacing: 8) {
            ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                Text(day)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(themeManager.currentTheme.textSecondaryColor)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.bottom, 4)
    }
    
    private var calendarLegend: some View {
        HStack(spacing: 24) {
            LegendItem(
                color: themeManager.currentTheme.calendarCompleteColor,
                label: "Kept",
                theme: themeManager.currentTheme
            )
            
            LegendItem(
                color: themeManager.currentTheme.calendarMissedColor,
                label: "Missed",
                theme: themeManager.currentTheme
            )
            
            LegendItem(
                color: themeManager.currentTheme.calendarNeutralColor,
                label: "Not Scheduled",
                theme: themeManager.currentTheme
            )
        }
        .padding(16)
        .background(themeManager.currentTheme.surfaceColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Rules Tab
    
    private var rulesTab: some View {
        VStack(spacing: 16) {
            filterChips
            
            ForEach(filteredRules) { rule in
                RuleRowView(rule: rule, theme: themeManager.currentTheme)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .transition(.asymmetric(
            insertion: .opacity.combined(with: .move(edge: .trailing)),
            removal: .opacity.combined(with: .move(edge: .leading))
        ))
    }
    
    private var filterChips: some View {
        HStack(spacing: 12) {
            ForEach(RuleFilter.allCases, id: \.self) { filter in
                Button(action: { 
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        ruleFilter = filter
                    }
                }) {
                    Text(filter.rawValue)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(ruleFilter == filter ? 
                            themeManager.currentTheme.accentColor : 
                            themeManager.currentTheme.textSecondaryColor)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            ruleFilter == filter ? 
                                themeManager.currentTheme.accentSoftColor : 
                                themeManager.currentTheme.surfaceColor
                        )
                        .clipShape(Capsule())
                }
            }
            
            Spacer()
        }
    }
    
    // MARK: - Computed Properties
    
    private var monthlySummary: String {
        "\(completedDays) of \(scheduledDays) scheduled days kept"
    }
    
    private var completedDays: Int {
        let calendar = Calendar.current
        let now = Date()
        
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)),
              let monthEnd = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: monthStart) else {
            return 0
        }
        
        var completedDaysSet = Set<Date>()
        
        for rule in rules {
            let relevantCheckIns = rule.checkIns.filter { checkIn in
                checkIn.date >= monthStart && checkIn.date <= monthEnd && checkIn.kept
            }
            
            for checkIn in relevantCheckIns {
                let dayStart = calendar.startOfDay(for: checkIn.date)
                completedDaysSet.insert(dayStart)
            }
        }
        
        return completedDaysSet.count
    }
    
    private var scheduledDays: Int {
        let calendar = Calendar.current
        
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)),
              let monthEnd = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: monthStart) else {
            return 0
        }
        
        var scheduledDaysSet = Set<Date>()
        var currentDate = monthStart
        
        while currentDate <= monthEnd {
            for rule in rules {
                if let schedule = rule.schedule, schedule.appliesOn(date: currentDate) {
                    let dayStart = calendar.startOfDay(for: currentDate)
                    scheduledDaysSet.insert(dayStart)
                    break
                }
            }
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }
        
        return scheduledDaysSet.count
    }
    
    private var compliancePercentage: Double {
        guard scheduledDays > 0 else { return 0 }
        return Double(completedDays) / Double(scheduledDays)
    }
    
    private var activeRules: [NewRule] {
        rules.filter { $0.status == .active }
    }
    
    private var filteredRules: [NewRule] {
        switch ruleFilter {
        case .active:
            return rules.filter { $0.status == .active }
        case .paused:
            return rules.filter { $0.status == .paused }
        case .archived:
            return rules.filter { $0.status == .archived }
        }
    }
    
    private var insightText: String {
        "You're most consistent on weekdays. Consider adding a weekend reminder to maintain momentum."
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }
    
    private var daysInMonth: [Date?] {
        let calendar = Calendar.current
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)),
              let range = calendar.range(of: .day, in: .month, for: currentMonth) else {
            return []
        }
        
        let firstWeekday = calendar.component(.weekday, from: monthStart)
        let leadingEmptyDays = Array(repeating: nil as Date?, count: firstWeekday - 1)
        
        let days = range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: monthStart)
        }
        
        return leadingEmptyDays + days
    }
    
    // MARK: - Helper Methods
    
    private func previousMonth() {
        let calendar = Calendar.current
        if let newMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    private func nextMonth() {
        let calendar = Calendar.current
        if let newMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    private func stateForDate(_ date: Date) -> CalendarDayState {
        // Calculate aggregate state for all rules in category on this date
        let scheduledRules = rules.filter { rule in
            guard let schedule = schedules[rule.id] else { return false }
            return schedule.appliesOn(date: date)
        }
        
        guard !scheduledRules.isEmpty else { return .notScheduled }
        
        let allKept = scheduledRules.allSatisfy { rule in
            rule.checkIns.contains { checkIn in
                Calendar.current.isDate(checkIn.date, inSameDayAs: date) && checkIn.kept
            }
        }
        
        if allKept {
            return .completed
        }
        
        let calendar = Calendar.current
        if calendar.startOfDay(for: date) < calendar.startOfDay(for: Date()) {
            return .missed
        }
        
        return .notScheduled
    }
    
    private func filteredRulesForDay(_ date: Date) -> [NewRule] {
        rules.filter { rule in
            guard let schedule = schedules[rule.id] else { return false }
            return schedule.appliesOn(date: date)
        }
    }
}

// MARK: - Supporting Views

struct RuleRowView: View {
    let rule: NewRule
    let theme: AppTheme
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(rule.statement)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(theme.textPrimaryColor)
                
                if let schedule = rule.schedule {
                    Text(schedule.displayName)
                        .font(.system(size: 13))
                        .foregroundColor(theme.textSecondaryColor)
                }
            }
            
            Spacer()
            
            if rule.status == .active {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(theme.successColor)
            }
        }
        .padding(16)
        .background(theme.surfaceColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct CalendarDayCell: View {
    let date: Date
    let state: CalendarDayState
    let isToday: Bool
    let theme: AppTheme
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.system(size: 15, weight: isToday ? .semibold : .regular))
                .foregroundColor(theme.textPrimaryColor)
            
            Circle()
                .fill(stateColor)
                .frame(width: 6, height: 6)
        }
        .frame(height: 44)
        .frame(maxWidth: .infinity)
        .background(isToday ? theme.accentSoftColor : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private var stateColor: Color {
        switch state {
        case .completed:
            return theme.calendarCompleteColor
        case .missed:
            return theme.calendarMissedColor
        case .notScheduled:
            return theme.calendarNeutralColor
        }
    }
}

struct MiniCalendarGrid: View {
    let month: Date
    let rules: [NewRule]
    let schedules: [UUID: Schedule]
    let theme: AppTheme
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
            ForEach(daysInMonth, id: \.self) { date in
                if let date = date {
                    Circle()
                        .fill(colorForDate(date))
                        .frame(width: 8, height: 8)
                } else {
                    Color.clear
                        .frame(width: 8, height: 8)
                }
            }
        }
    }
    
    private var daysInMonth: [Date?] {
        let calendar = Calendar.current
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: month)),
              let range = calendar.range(of: .day, in: .month, for: month) else {
            return []
        }
        
        let firstWeekday = calendar.component(.weekday, from: monthStart)
        let leadingEmptyDays = Array(repeating: nil as Date?, count: firstWeekday - 1)
        
        let days = range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: monthStart)
        }
        
        return leadingEmptyDays + days
    }
    
    private func colorForDate(_ date: Date) -> Color {
        let scheduledRules = rules.filter { rule in
            guard let schedule = schedules[rule.id] else { return false }
            return schedule.appliesOn(date: date)
        }
        
        guard !scheduledRules.isEmpty else { return theme.calendarNeutralColor }
        
        let allKept = scheduledRules.allSatisfy { rule in
            rule.checkIns.contains { checkIn in
                Calendar.current.isDate(checkIn.date, inSameDayAs: date) && checkIn.kept
            }
        }
        
        return allKept ? theme.calendarCompleteColor : theme.calendarMissedColor
    }
}

struct LegendItem: View {
    let color: Color
    let label: String
    let theme: AppTheme
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(theme.textSecondaryColor)
        }
    }
}

struct DayDetailSheet: View {
    let date: Date
    let rules: [NewRule]
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(dateString)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(themeManager.currentTheme.textPrimaryColor)
                    
                    Text("\(rules.count) rules scheduled")
                        .font(.system(size: 15))
                        .foregroundColor(themeManager.currentTheme.textSecondaryColor)
                }
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(themeManager.currentTheme.textSecondaryColor)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(rules) { rule in
                        RuleRowView(rule: rule, theme: themeManager.currentTheme)
                    }
                }
                .padding(.horizontal, 20)
            }
            
            Spacer()
        }
        .background(themeManager.currentTheme.backgroundPrimaryColor)
    }
    
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: date)
    }
}
