import SwiftUI
import UserNotifications

struct OnboardingThemeView: View {
    let onComplete: () -> Void
    
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var appState: AppState
    
    @State private var selectedTheme: AppTheme = .sageCalm
    @State private var showNotificationPermission = false
    @State private var enableNotifications = false
    @State private var notificationTime = Date()
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                headerSection
                
                ScrollView {
                    VStack(spacing: 32) {
                        livePreview
                        
                        themeSwatchGrid
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 100)
                }
                
                Spacer()
                
                continueButton
            }
            .background(themeManager.backgroundPrimary.ignoresSafeArea())
            
            // Notification permission overlay
            if showNotificationPermission {
                notificationPermissionView
            }
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        Text("Choose a look that feels like you")
            .font(.system(size: 28, weight: .bold, design: .rounded))
            .foregroundStyle(themeManager.textPrimary)
            .multilineTextAlignment(.center)
            .lineSpacing(2)
            .padding(.horizontal, 24)
            .padding(.top, 60)
    }
    
    // MARK: - Live Preview
    
    private var livePreview: some View {
        VStack(spacing: 16) {
            Text("Preview")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(themeManager.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                previewCategoryTile
                previewRuleCard
                previewCalendarSample
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(selectedTheme.backgroundSecondaryColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(selectedTheme.strokeColor.opacity(0.5), lineWidth: 1)
            )
        }
    }
    
    private var previewCategoryTile: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(selectedTheme.accentSoftColor)
                    .frame(width: 36, height: 36)
                
                Image(systemName: "figure.walk")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(selectedTheme.accentColor)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Physical Health")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(selectedTheme.textPrimaryColor)
                
                Text("3 active rules")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(selectedTheme.textSecondaryColor)
            }
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(selectedTheme.surfaceColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(selectedTheme.strokeColor, lineWidth: 1)
        )
    }
    
    private var previewRuleCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Walk 10,000 steps")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(selectedTheme.textPrimaryColor)
            
            HStack(spacing: 4) {
                ForEach(0..<7, id: \.self) { index in
                    Circle()
                        .fill(index < 5 ? selectedTheme.calendarCompleteColor : selectedTheme.strokeColor.opacity(0.3))
                        .frame(width: 6, height: 6)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(selectedTheme.surfaceColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(selectedTheme.strokeColor, lineWidth: 1)
        )
    }
    
    private var previewCalendarSample: some View {
        HStack(spacing: 8) {
            ForEach(0..<5, id: \.self) { index in
                VStack(spacing: 4) {
                    Text("M")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(selectedTheme.textSecondaryColor)
                    
                    Circle()
                        .fill(calendarDayColor(for: index))
                        .frame(width: 8, height: 8)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private func calendarDayColor(for index: Int) -> Color {
        switch index {
        case 0, 1, 3:
            return selectedTheme.calendarCompleteColor
        case 2:
            return selectedTheme.calendarMissedColor.opacity(0.3)
        default:
            return selectedTheme.strokeColor.opacity(0.3)
        }
    }
    
    // MARK: - Theme Swatch Grid
    
    private var themeSwatchGrid: some View {
        VStack(spacing: 16) {
            Text("Themes")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(themeManager.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(AppTheme.allThemes, id: \.id) { theme in
                    ThemeSwatch(
                        theme: theme,
                        isSelected: selectedTheme.id == theme.id,
                        onTap: {
                            selectTheme(theme)
                        }
                    )
                }
            }
        }
    }
    
    // MARK: - Notification Permission View
    
    private var notificationPermissionView: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        showNotificationPermission = false
                    }
                }
            
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Image(systemName: "bell.badge")
                        .font(.system(size: 48, weight: .medium))
                        .foregroundStyle(themeManager.accent)
                    
                    Text("Stay on track with reminders")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(themeManager.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text("Get a daily reminder to check in on your rules")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(themeManager.textSecondary)
                        .multilineTextAlignment(.center)
                }
                
                // Time picker
                VStack(spacing: 12) {
                    Text("Reminder time")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(themeManager.textSecondary)
                    
                    DatePicker("", selection: $notificationTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .frame(maxWidth: .infinity)
                }
                .padding(16)
                .background(themeManager.surface)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                
                VStack(spacing: 12) {
                    Button(action: {
                        enableNotifications = true
                        requestNotificationPermission()
                    }) {
                        Text("Enable reminders")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(themeManager.accent)
                            )
                    }
                    
                    Button(action: {
                        enableNotifications = false
                        completeOnboarding()
                    }) {
                        Text("Skip for now")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(themeManager.textSecondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                    }
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(themeManager.backgroundPrimary)
            )
            .padding(.horizontal, 32)
        }
    }
    
    // MARK: - Continue Button
    
    private var continueButton: some View {
        VStack(spacing: 0) {
            Divider()
                .background(themeManager.stroke)
            
            Button(action: handleComplete) {
                Text("Continue")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(themeManager.accent)
                    )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(themeManager.backgroundPrimary)
        }
    }
    
    // MARK: - Actions
    
    private func selectTheme(_ theme: AppTheme) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            selectedTheme = theme
        }
    }
    
    private func handleComplete() {
        // Set the theme
        themeManager.setTheme(selectedTheme, animated: true)
        // Show notification permission
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            showNotificationPermission = true
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    // Schedule daily notification
                    scheduleDailyNotification()
                }
                completeOnboarding()
            }
        }
    }
    
    private func scheduleDailyNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Time to check in"
        content.body = "How did you do with your rules today?"
        content.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: notificationTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(identifier: "dailyCheckIn", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    private func completeOnboarding() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            showNotificationPermission = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            appState.completeOnboarding()
            onComplete()
        }
    }
}

// MARK: - Theme Swatch

struct ThemeSwatch: View {
    let theme: AppTheme
    let isSelected: Bool
    let onTap: () -> Void
    
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(theme.backgroundPrimaryColor)
                    
                    VStack(spacing: 4) {
                        Circle()
                            .fill(theme.accentColor)
                            .frame(width: 20, height: 20)
                        
                        HStack(spacing: 3) {
                            Circle()
                                .fill(theme.calendarCompleteColor)
                                .frame(width: 4, height: 4)
                            Circle()
                                .fill(theme.calendarMissedColor)
                                .frame(width: 4, height: 4)
                            Circle()
                                .fill(theme.strokeColor)
                                .frame(width: 4, height: 4)
                        }
                    }
                }
                .frame(height: 80)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(
                            isSelected ? theme.accentColor : theme.strokeColor,
                            lineWidth: isSelected ? 3 : 1
                        )
                )
                
                Text(theme.name)
                    .font(.system(size: 12, weight: isSelected ? .semibold : .medium))
                    .foregroundStyle(isSelected ? themeManager.accent : themeManager.textSecondary)
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Preview

#Preview {
    OnboardingThemeView(onComplete: {})
        .environmentObject(AppState())
        .environmentObject(ThemeManager())
}
