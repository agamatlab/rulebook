import Foundation
import UserNotifications

// MARK: - Daily Reminder Manager
// Manages daily notifications to remind users to review their rules

class DailyReminderManager: ObservableObject {
    
    static let shared = DailyReminderManager()
    
    @Published var isAuthorized = false
    @Published var reminderTime: Date {
        didSet {
            UserDefaults.standard.set(reminderTime, forKey: "dailyReminderTime")
            if isEnabled {
                scheduleReminder()
            }
        }
    }
    
    @Published var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: "dailyReminderEnabled")
            if isEnabled {
                scheduleReminder()
            } else {
                cancelReminder()
            }
        }
    }
    
    private let notificationIdentifier = "daily-rule-review-reminder"
    
    private init() {
        // Load saved settings
        if let savedTime = UserDefaults.standard.object(forKey: "dailyReminderTime") as? Date {
            self.reminderTime = savedTime
        } else {
            // Default to 23:50 (11:50 PM)
            let calendar = Calendar.current
            var components = calendar.dateComponents([.year, .month, .day], from: Date())
            components.hour = 23
            components.minute = 50
            self.reminderTime = calendar.date(from: components) ?? Date()
        }
        
        self.isEnabled = UserDefaults.standard.bool(forKey: "dailyReminderEnabled")
        
        // Check authorization status
        checkAuthorizationStatus()
    }
    
    // MARK: - Authorization
    
    func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            
            await MainActor.run {
                self.isAuthorized = granted
                if granted && self.isEnabled {
                    self.scheduleReminder()
                }
            }
            
            return granted
        } catch {
            print("Failed to request notification permission: \(error)")
            return false
        }
    }
    
    // Public method so SettingsView can call it
    func checkAuthorizationStatus() {
        let center = UNUserNotificationCenter.current()
        
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    // MARK: - Scheduling
    
    func scheduleReminder() {
        guard isAuthorized else {
            print("Not authorized to send notifications")
            return
        }
        
        // Cancel existing reminder
        cancelReminder()
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Time to Review Your Rules"
        content.body = "Take a moment to check in on the rules you've followed today"
        content.sound = .default
        content.categoryIdentifier = "DAILY_REVIEW"
        
        // Extract hour and minute from reminderTime
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: reminderTime)
        
        // Create trigger for daily notification at specified time
        var dateComponents = DateComponents()
        dateComponents.hour = components.hour
        dateComponents.minute = components.minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // Create request
        let request = UNNotificationRequest(
            identifier: notificationIdentifier,
            content: content,
            trigger: trigger
        )
        
        // Schedule notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            } else {
                print("Daily reminder scheduled for \(components.hour ?? 0):\(components.minute ?? 0)")
            }
        }
    }
    
    func cancelReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])
        print("Daily reminder cancelled")
    }
    
    // MARK: - Testing
    
    func sendTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Time to Review Your Rules"
        content.body = "Take a moment to check in on the rules you've followed today"
        content.sound = .default
        content.categoryIdentifier = "DAILY_REVIEW"
        
        // Trigger in 5 seconds
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "test-notification",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to send test notification: \(error)")
            } else {
                print("Test notification scheduled")
            }
        }
    }
}
