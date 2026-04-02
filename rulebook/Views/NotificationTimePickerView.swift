import SwiftUI

// MARK: - Notification Time Picker View
// Allows users to select the time for daily rule review reminders

struct NotificationTimePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var reminderManager: DailyReminderManager
    
    @State private var selectedTime: Date
    
    init(reminderManager: DailyReminderManager) {
        self.reminderManager = reminderManager
        _selectedTime = State(initialValue: reminderManager.reminderTime)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header text
                VStack(spacing: 8) {
                    Text("Daily Reminder")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(themeManager.textPrimary)
                    
                    Text("Choose when you'd like to be reminded to review your rules")
                        .font(.system(size: 15))
                        .foregroundStyle(themeManager.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .padding(.top, 32)
                
                // Time picker
                DatePicker(
                    "Reminder Time",
                    selection: $selectedTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .padding(.horizontal, 20)
                
                // Preview text
                VStack(spacing: 8) {
                    Text("You'll receive a notification at")
                        .font(.system(size: 14))
                        .foregroundStyle(themeManager.textSecondary)
                    
                    Text(timeString(from: selectedTime))
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(themeManager.accent)
                }
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(themeManager.accentSoft)
                )
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Test notification button
                Button {
                    reminderManager.sendTestNotification()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "bell.badge.fill")
                            .font(.system(size: 16, weight: .medium))
                        Text("Send Test Notification")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundStyle(themeManager.textSecondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(themeManager.surface)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(themeManager.stroke, lineWidth: 1)
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
            .background(themeManager.backgroundPrimary)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(themeManager.textSecondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        reminderManager.reminderTime = selectedTime
                        dismiss()
                    }
                    .foregroundStyle(themeManager.accent)
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Preview

#Preview {
    NotificationTimePickerView(reminderManager: DailyReminderManager.shared)
        .environmentObject(ThemeManager())
}
