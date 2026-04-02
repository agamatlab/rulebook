import SwiftUI

// MARK: - Today View
// Daily dashboard for keeping promises
// Large title compresses naturally, smooth scrolling with airy spacing
// Cards soften at viewport edges, generous bottom inset for floating button

struct TodayView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var categoryManager: CategoryManager
    
    @State private var selectedRule: NewRule?
    @State private var heroCardAppeared = false
    @State private var cardsAppeared = false
    @State private var selectedDate: Date = Date()
    @State private var showDatePicker = false
    
    private var theme: AppTheme {
        themeManager.currentTheme
    }
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }
    
    private var dateTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: selectedDate)
    }
    
    private var dateDisplayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: selectedDate)
    }
    
    private var relevantRules: [NewRule] {
        appState.activeRules.filter { rule in
            guard rule.status == .active else { return false }
            guard let schedule = rule.schedule else { return true }
            return schedule.appliesOn(date: selectedDate)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Title header
                HStack {
                    Text(isToday ? "Today" : dateTitle)
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(themeManager.textPrimary)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 8)
                
                // Date selector
                dateSelector
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                
                // Hero card
                heroCard
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                    .opacity(heroCardAppeared ? 1 : 0)
                    .offset(y: heroCardAppeared ? 0 : 20)
                
                // Relevant now section
                relevantNowSection
                    .padding(.bottom, 32)
                    .opacity(cardsAppeared ? 1 : 0)
                    .offset(y: cardsAppeared ? 0 : 20)
                
                // Categories section
                categoriesSection
                    .padding(.bottom, 32)
                    .opacity(cardsAppeared ? 1 : 0)
                    .offset(y: cardsAppeared ? 0 : 20)
                
                // Insight card
                insightCard
                    .padding(.horizontal, 20)
                    .padding(.bottom, 120) // Generous bottom inset
                    .opacity(cardsAppeared ? 1 : 0)
                    .offset(y: cardsAppeared ? 0 : 20)
            }
        }
        .background(theme.backgroundPrimaryColor)
        .scrollIndicators(.hidden)
        .sheet(item: $selectedRule) { rule in
            DailyCheckInSheet(rule: rule) { kept, notRelevant in
                if !notRelevant {
                    appState.checkInRule(id: rule.id, kept: kept, date: selectedDate)
                }
            }
            .environmentObject(themeManager)
        }
        .sheet(isPresented: $showDatePicker) {
            DatePickerSheet(selectedDate: $selectedDate, theme: theme)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                heroCardAppeared = true
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
                cardsAppeared = true
            }
        }
    }
    
    // MARK: - Date Selector
    
    private var dateSelector: some View {
        HStack(spacing: 12) {
            // Previous day button
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
                }
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(theme.textPrimaryColor)
                    .frame(width: 40, height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(theme.surfaceColor)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .strokeBorder(theme.strokeColor, lineWidth: 1)
                    )
            }
            
            // Date display / picker button
            Button(action: {
                showDatePicker = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .font(.system(size: 15, weight: .medium))
                    
                    Text(isToday ? "Today" : dateDisplayString)
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundStyle(theme.textPrimaryColor)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(theme.surfaceColor)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(isToday ? theme.accentColor : theme.strokeColor, lineWidth: isToday ? 2 : 1)
                )
            }
            
            // Next day button
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                }
            }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(theme.textPrimaryColor)
                    .frame(width: 40, height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(theme.surfaceColor)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .strokeBorder(theme.strokeColor, lineWidth: 1)
                    )
            }
            .disabled(Calendar.current.isDateInToday(selectedDate))
            .opacity(Calendar.current.isDateInToday(selectedDate) ? 0.3 : 1.0)
        }
    }
    
    // MARK: - Hero Card
    
    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Date and greeting
            VStack(alignment: .leading, spacing: 4) {
                Text(todayDateString)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(theme.textSecondaryColor)
                
                Text(greetingText)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(theme.textPrimaryColor)
            }
            
            // Week preview with opacity-based compliance dots
            weekCompliancePreview
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(theme.surfaceColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [theme.accentColor.opacity(0.2), theme.strokeColor],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 4)
    }
    
    private var todayDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }
    
    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 {
            return "Good morning"
        } else if hour < 18 {
            return "Good afternoon"
        } else {
            return "Good evening"
        }
    }
    
    private var weekCompliancePreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This Week")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(theme.textSecondaryColor)
                .textCase(.uppercase)
            
            HStack(spacing: 8) {
                ForEach(-6...0, id: \.self) { dayOffset in
                    weekDayDot(dayOffset: dayOffset)
                }
            }
        }
    }
    
    private func weekDayDot(dayOffset: Int) -> some View {
        let calendar = Calendar.current
        guard let date = calendar.date(byAdding: .day, value: dayOffset, to: Date()) else {
            return AnyView(EmptyView())
        }
        
        let dayStart = calendar.startOfDay(for: date)
        let isToday = calendar.isDateInToday(date)
        
        // Calculate compliance for this day
        let compliance = calculateDayCompliance(for: dayStart)
        
        return AnyView(
            VStack(spacing: 6) {
                Text(dayLetter(for: date))
                    .font(.system(size: 11, weight: isToday ? .bold : .medium))
                    .foregroundStyle(isToday ? theme.accentColor : theme.textSecondaryColor)
                
                ZStack {
                    // Outer glow for today
                    if isToday {
                        Circle()
                            .fill(theme.accentColor.opacity(0.2))
                            .frame(width: 38, height: 38)
                            .scaleEffect(heroCardAppeared ? 1.0 : 0.8)
                    }
                    
                    // Main circle
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: compliance > 0 ? 
                                    [theme.accentColor.opacity(max(0.3, compliance)), 
                                     theme.accentColor.opacity(max(0.1, compliance * 0.7))] :
                                    [theme.strokeColor.opacity(0.3), theme.strokeColor.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 32, height: 32)
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    compliance > 0 ? theme.accentColor.opacity(0.4) : theme.strokeColor,
                                    lineWidth: 1.5
                                )
                        )
                        .overlay(
                            Text(compliance > 0 ? "\(Int(compliance * 100))" : "")
                                .font(.system(size: 9, weight: .bold, design: .rounded))
                                .foregroundStyle(compliance > 0.5 ? .white : theme.textPrimaryColor)
                        )
                        .scaleEffect(heroCardAppeared ? 1.0 : 0.5)
                }
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(Double(dayOffset + 6) * 0.05), value: heroCardAppeared)
        )
    }
    
    private func calculateDayCompliance(for date: Date) -> Double {
        let calendar = Calendar.current
        let activeRules = appState.rules.filter { $0.status == .active }
        
        var scheduledCount = 0
        var keptCount = 0
        
        for rule in activeRules {
            // Check if rule is scheduled for this day
            if let schedule = rule.schedule, schedule.appliesOn(date: date) {
                scheduledCount += 1
                
                // Check if there's a check-in for this day
                if let checkIn = rule.checkIns.first(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
                    if checkIn.kept {
                        keptCount += 1
                    }
                }
            }
        }
        
        return scheduledCount > 0 ? Double(keptCount) / Double(scheduledCount) : 0
    }
    
    private func dayLetter(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return String(formatter.string(from: date).prefix(1))
    }
    
    // MARK: - Relevant Now Section
    
    private var relevantNowSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !relevantRules.isEmpty {
                Text("Relevant Now")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundStyle(theme.textPrimaryColor)
                    .padding(.horizontal, 20)
                
                VStack(spacing: 12) {
                    ForEach(relevantRules) { rule in
                        RuleCardView(rule: rule, theme: theme, selectedDate: selectedDate) {
                            selectedRule = rule
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - Categories Section
    
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Categories")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundStyle(theme.textPrimaryColor)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(categoryManager.categories) { category in
                        let rules = appState.rules(forCategory: category.id)
                        let completedDays = calculateCompletedDays(for: category.id)
                        NavigationLink(destination: CategoryDetailView(category: category)) {
                            CategoryTile(
                                category: category,
                                completedDays: completedDays,
                                totalDays: 30,
                                weekPreview: calculateWeekPreview(for: category.id),
                                isSelected: false,
                                isEmpty: rules.isEmpty,
                                isDisabled: false,
                                onTap: {}
                            )
                            .environmentObject(themeManager)
                            .id("\(category.id)-\(themeManager.currentTheme.id)")
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
            }
            .mask(
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: .clear, location: 0),
                        .init(color: .black, location: 0.05),
                        .init(color: .black, location: 0.95),
                        .init(color: .clear, location: 1)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        }
    }
    
    // MARK: - Helper Methods
    
    private func calculateCompletedDays(for categoryId: UUID) -> Int {
        let rules = appState.rules(forCategory: categoryId)
        let calendar = Calendar.current
        let now = Date()
        
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
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
    
    private func calculateWeekPreview(for categoryId: UUID) -> [CategoryTile.DayStatus] {
        let rules = appState.rules(forCategory: categoryId)
        let calendar = Calendar.current
        let today = Date()
        
        var weekStatuses: [CategoryTile.DayStatus] = []
        
        for dayOffset in -6...0 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: today) else {
                weekStatuses.append(.future)
                continue
            }
            
            let dayStart = calendar.startOfDay(for: date)
            var dayHasCompleted = false
            var dayHasMissed = false
            var dayHasScheduled = false
            
            for rule in rules {
                if let schedule = rule.schedule, schedule.appliesOn(date: date) {
                    dayHasScheduled = true
                    
                    let checkInsForDay = rule.checkIns.filter { checkIn in
                        calendar.isDate(checkIn.date, inSameDayAs: date)
                    }
                    
                    if let checkIn = checkInsForDay.first {
                        if checkIn.kept {
                            dayHasCompleted = true
                        } else {
                            dayHasMissed = true
                        }
                    } else if date < today {
                        dayHasMissed = true
                    }
                }
            }
            
            if dayHasCompleted {
                weekStatuses.append(.completed)
            } else if dayHasMissed {
                weekStatuses.append(.missed)
            } else if dayHasScheduled {
                weekStatuses.append(.notScheduled)
            } else {
                weekStatuses.append(.notScheduled)
            }
        }
        
        return weekStatuses
    }
    
    // MARK: - Insight Card
    
    private var insightCard: some View {
        WeeklyInsightCard(
            theme: theme,
            weekCompliance: calculateWeekCompliance(),
            bestDay: findBestDay(),
            totalRules: appState.activeRules.count,
            completedToday: calculateCompletedToday()
        )
    }
    
    private func calculateWeekCompliance() -> Double {
        let calendar = Calendar.current
        let today = Date()
        var totalScheduled = 0
        var totalKept = 0
        
        for dayOffset in -6...0 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: today) else { continue }
            let dayStart = calendar.startOfDay(for: date)
            
            for rule in appState.activeRules {
                if let schedule = rule.schedule, schedule.appliesOn(date: date) {
                    totalScheduled += 1
                    
                    if let checkIn = rule.checkIns.first(where: { calendar.isDate($0.date, inSameDayAs: dayStart) }) {
                        if checkIn.kept {
                            totalKept += 1
                        }
                    }
                }
            }
        }
        
        return totalScheduled > 0 ? Double(totalKept) / Double(totalScheduled) : 0
    }
    
    private func findBestDay() -> String {
        let calendar = Calendar.current
        let today = Date()
        var dayScores: [(day: String, score: Double)] = []
        
        for dayOffset in -6...0 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: today) else { continue }
            let compliance = calculateDayCompliance(for: calendar.startOfDay(for: date))
            let dayName = dayLetter(for: date)
            dayScores.append((dayName, compliance))
        }
        
        let best = dayScores.max(by: { $0.score < $1.score })
        return best?.day ?? "Today"
    }
    
    private func calculateCompletedToday() -> Int {
        let today = Date()
        let calendar = Calendar.current
        
        return appState.activeRules.filter { rule in
            rule.checkIns.contains { checkIn in
                calendar.isDate(checkIn.date, inSameDayAs: today) && checkIn.kept
            }
        }.count
    }
    
}

// MARK: - Previews

#Preview("Today View") {
    NavigationStack {
        TodayView()
            .environmentObject(AppState())
            .environmentObject(ThemeManager())
            .environmentObject(CategoryManager())
    }
}
