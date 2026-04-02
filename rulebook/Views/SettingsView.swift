import SwiftUI

// MARK: - Settings View
// App configuration with warm, iOS-style grouped sections

struct SettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var appState: AppState
    @StateObject private var reminderManager = DailyReminderManager.shared
    @State private var showThemePicker = false
    @State private var showManageCategories = false
    @State private var reducedMotion = false
    @State private var showNotificationTimePicker = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Appearance section
                settingsSection(title: "Appearance") {
                    settingsRow(
                        icon: "paintbrush.fill",
                        title: "Theme",
                        value: themeManager.currentTheme.name,
                        action: { showThemePicker = true }
                    )
                }
                
                // Notifications section
                settingsSection(title: "Notifications") {
                    settingsToggleRow(
                        icon: "bell.fill",
                        title: "Daily reminder",
                        isOn: $reminderManager.isEnabled
                    )
                    
                    if reminderManager.isEnabled {
                        settingsRow(
                            icon: "clock.fill",
                            title: "Reminder time",
                            value: timeString(from: reminderManager.reminderTime),
                            action: { showNotificationTimePicker = true }
                        )
                    }
                }
                
                // Categories section
                settingsSection(title: "Categories") {
                    settingsRow(
                        icon: "square.grid.2x2.fill",
                        title: "Manage categories",
                        action: { showManageCategories = true }
                    )
                }
                
                // Motion section
                settingsSection(title: "Motion") {
                    settingsToggleRow(
                        icon: "motion.sensor.fill",
                        title: "Reduced motion",
                        isOn: $reducedMotion
                    )
                }
                
                // Feedback section
                settingsSection(title: "Feedback") {
                    settingsRow(
                        icon: "envelope.fill",
                        title: "Send feedback",
                        action: { openFeedback() }
                    )
                    
                    settingsRow(
                        icon: "star.fill",
                        title: "Rate Rulebook",
                        action: { openAppStore() }
                    )
                }
                
                // App info
                appInfoSection
                    .padding(.top, 16)
                    .padding(.bottom, 120) // Space for floating button
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
        .background(themeManager.backgroundPrimary)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Check authorization status when view appears
            Task {
                await MainActor.run {
                    reminderManager.checkAuthorizationStatus()
                }
            }
        }
        .sheet(isPresented: $showThemePicker) {
            ThemePickerView()
                .environmentObject(themeManager)
        }
        .sheet(isPresented: $showManageCategories) {
            ManageCategoriesView()
                .environmentObject(themeManager)
                .environmentObject(appState.categoryManager)
        }
        .sheet(isPresented: $showNotificationTimePicker) {
            NotificationTimePickerView(reminderManager: reminderManager)
                .environmentObject(themeManager)
        }
        .onChange(of: reminderManager.isEnabled) { newValue in
            if newValue && !reminderManager.isAuthorized {
                Task {
                    let granted = await reminderManager.requestAuthorization()
                    if !granted {
                        await MainActor.run {
                            reminderManager.isEnabled = false
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Settings Section
    
    private func settingsSection<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(themeManager.textSecondary)
                .textCase(.uppercase)
                .padding(.horizontal, 4)
            
            VStack(spacing: 0) {
                content()
            }
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(themeManager.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(themeManager.stroke, lineWidth: 1)
            )
        }
    }
    
    // MARK: - Settings Row
    
    private func settingsRow(
        icon: String,
        title: String,
        value: String? = nil,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(themeManager.accentSoft)
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(themeManager.accent)
                }
                
                // Title
                Text(title)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(themeManager.textPrimary)
                
                Spacer()
                
                // Value (if provided)
                if let value = value {
                    Text(value)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(themeManager.textSecondary)
                }
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(themeManager.textSecondary.opacity(0.5))
            }
            .padding(16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Settings Toggle Row
    
    private func settingsToggleRow(
        icon: String,
        title: String,
        isOn: Binding<Bool>
    ) -> some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(themeManager.accentSoft)
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(themeManager.accent)
            }
            
            // Title
            Text(title)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(themeManager.textPrimary)
            
            Spacer()
            
            // Toggle
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(themeManager.accent)
        }
        .padding(16)
    }
    
    // MARK: - App Info Section
    
    private var appInfoSection: some View {
        VStack(spacing: 8) {
            Text("Rulebook")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(themeManager.textPrimary)
            
            Text("Version 1.0.0")
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(themeManager.textSecondary)
            
            Text("Made with care for keeping promises")
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(themeManager.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Actions
    
    private func openFeedback() {
        // Open feedback form or email
        if let url = URL(string: "mailto:feedback@rulebook.app") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openAppStore() {
        // Open App Store rating page
        // Replace with actual App Store URL
        print("Open App Store for rating")
    }
    
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Theme Picker View

private struct ThemePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(themeManager.availableThemes) { theme in
                        themePreviewCard(theme)
                    }
                }
                .padding(20)
            }
            .background(themeManager.backgroundPrimary)
            .navigationTitle("Choose Theme")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(themeManager.accent)
                }
            }
        }
    }
    
    private func themePreviewCard(_ theme: AppTheme) -> some View {
        Button(action: {
            themeManager.setTheme(theme)
        }) {
            HStack(spacing: 16) {
                // Color preview circles
                HStack(spacing: 6) {
                    Circle()
                        .fill(theme.accentColor)
                        .frame(width: 24, height: 24)
                    
                    Circle()
                        .fill(theme.backgroundPrimaryColor)
                        .frame(width: 24, height: 24)
                        .overlay(
                            Circle()
                                .strokeBorder(theme.strokeColor, lineWidth: 1)
                        )
                    
                    Circle()
                        .fill(theme.textPrimaryColor)
                        .frame(width: 24, height: 24)
                }
                
                // Theme name
                Text(theme.name)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(themeManager.textPrimary)
                
                Spacer()
                
                // Selected indicator
                if themeManager.currentTheme.id == theme.id {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(themeManager.accent)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(themeManager.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(
                        themeManager.currentTheme.id == theme.id ? themeManager.accent : themeManager.stroke,
                        lineWidth: themeManager.currentTheme.id == theme.id ? 2 : 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Manage Categories View
// Note: Full ManageCategoriesView is in separate file

// MARK: - Previews

#Preview {
    NavigationStack {
        SettingsView()
    }
    .themeManager(ThemeManager())
}

#Preview("Theme Picker") {
    ThemePickerView()
        .themeManager(ThemeManager())
}
