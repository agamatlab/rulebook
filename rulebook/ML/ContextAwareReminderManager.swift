import Foundation
import FamilyControls
import DeviceActivity
import UserNotifications

// MARK: - Context-Aware Reminder System
// Monitors app usage and triggers gentle reminders when context matches rules
// Uses iOS Screen Time API for privacy-preserving app monitoring

class ContextAwareReminderManager: ObservableObject {
    
    static let shared = ContextAwareReminderManager()
    
    @Published var isAuthorized = false
    @Published var monitoredRules: [UUID: RuleContext] = [:]
    
    private let center = AuthorizationCenter.shared
    
    // MARK: - Rule Context
    
    struct RuleContext {
        let ruleId: UUID
        let statement: String
        let keywords: [String]
        let appCategories: [String]
        let lastReminderDate: Date?
        let cooldownMinutes: Int // Minimum time between reminders
        
        init(ruleId: UUID, statement: String, cooldownMinutes: Int = 60) {
            self.ruleId = ruleId
            self.statement = statement
            self.cooldownMinutes = cooldownMinutes
            self.lastReminderDate = nil
            
            // Extract keywords from rule statement
            self.keywords = Self.extractKeywords(from: statement)
            
            // Map keywords to app categories
            self.appCategories = Self.mapToAppCategories(keywords: self.keywords)
        }
        
        // MARK: - Keyword Extraction
        
        private static func extractKeywords(from statement: String) -> [String] {
            let lowercased = statement.lowercased()
            var keywords: [String] = []
            
            // Shopping keywords
            if lowercased.contains("buy") || lowercased.contains("purchase") || lowercased.contains("shop") {
                keywords.append("shopping")
            }
            
            // Social media keywords
            if lowercased.contains("social") || lowercased.contains("instagram") || lowercased.contains("twitter") || lowercased.contains("tiktok") {
                keywords.append("social")
            }
            
            // Phone/screen time keywords
            if lowercased.contains("phone") || lowercased.contains("screen") {
                keywords.append("screen")
            }
            
            // Gaming keywords
            if lowercased.contains("game") || lowercased.contains("gaming") {
                keywords.append("gaming")
            }
            
            // Entertainment keywords
            if lowercased.contains("video") || lowercased.contains("youtube") || lowercased.contains("netflix") {
                keywords.append("entertainment")
            }
            
            return keywords
        }
        
        // MARK: - App Category Mapping
        
        private static func mapToAppCategories(keywords: [String]) -> [String] {
            var categories: [String] = []
            
            for keyword in keywords {
                switch keyword {
                case "shopping":
                    categories.append(contentsOf: ["Shopping", "Finance"])
                case "social":
                    categories.append(contentsOf: ["Social Networking"])
                case "screen":
                    categories.append(contentsOf: ["Social Networking", "Entertainment", "Games"])
                case "gaming":
                    categories.append(contentsOf: ["Games"])
                case "entertainment":
                    categories.append(contentsOf: ["Entertainment", "Photo & Video"])
                default:
                    break
                }
            }
            
            return Array(Set(categories)) // Remove duplicates
        }
        
        func canSendReminder() -> Bool {
            guard let lastReminder = lastReminderDate else { return true }
            
            let minutesSinceLastReminder = Date().timeIntervalSince(lastReminder) / 60
            return minutesSinceLastReminder >= Double(cooldownMinutes)
        }
    }
    
    // MARK: - Authorization
    
    func requestAuthorization() async -> Bool {
        do {
            try await center.requestAuthorization(for: .individual)
            
            await MainActor.run {
                self.isAuthorized = true
            }
            
            // Also request notification permissions
            await requestNotificationPermission()
            
            return true
        } catch {
            print("Failed to authorize Screen Time: \(error)")
            return false
        }
    }
    
    private func requestNotificationPermission() async {
        let center = UNUserNotificationCenter.current()
        
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            print("Notification permission: \(granted)")
        } catch {
            print("Failed to request notification permission: \(error)")
        }
    }
    
    // MARK: - Rule Monitoring
    
    func startMonitoring(rule: NewRule) {
        guard isAuthorized else {
            print("Not authorized for Screen Time monitoring")
            return
        }
        
        let context = RuleContext(ruleId: rule.id, statement: rule.statement)
        
        // Only monitor if rule has relevant keywords
        guard !context.keywords.isEmpty else {
            print("Rule '\(rule.statement)' has no monitorable keywords")
            return
        }
        
        monitoredRules[rule.id] = context
        
        print("Started monitoring rule: '\(rule.statement)' for categories: \(context.appCategories)")
    }
    
    func stopMonitoring(ruleId: UUID) {
        monitoredRules.removeValue(forKey: ruleId)
    }
    
    func stopAllMonitoring() {
        monitoredRules.removeAll()
    }
    
    // MARK: - Reminder Triggering
    
    func triggerReminder(for ruleId: UUID) {
        guard let context = monitoredRules[ruleId],
              context.canSendReminder() else {
            return
        }
        
        sendNotification(for: context)
        
        // Update last reminder date
        var updatedContext = context
        monitoredRules[ruleId] = RuleContext(
            ruleId: updatedContext.ruleId,
            statement: updatedContext.statement,
            cooldownMinutes: updatedContext.cooldownMinutes
        )
    }
    
    private func sendNotification(for context: RuleContext) {
        let content = UNMutableNotificationContent()
        content.title = "💭 Remember"
        content.body = context.statement
        content.sound = .default
        content.categoryIdentifier = "RULE_REMINDER"
        
        // Trigger immediately
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "rule-\(context.ruleId.uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to send notification: \(error)")
            }
        }
    }
    
    // MARK: - Manual Testing (for development)
    
    func testReminder(for rule: NewRule) {
        let context = RuleContext(ruleId: rule.id, statement: rule.statement, cooldownMinutes: 0)
        sendNotification(for: context)
    }
}

// MARK: - App State Extension

extension AppState {
    func setupContextAwareReminders() {
        let manager = ContextAwareReminderManager.shared
        
        // Start monitoring all active rules with relevant keywords
        for rule in activeRules {
            manager.startMonitoring(rule: rule)
        }
    }
    
    func requestReminderPermissions() async -> Bool {
        return await ContextAwareReminderManager.shared.requestAuthorization()
    }
}

// MARK: - Usage Instructions
/*
 
 ## Setup in App
 
 1. Request authorization on first launch or in settings:
 
 ```swift
 Button("Enable Smart Reminders") {
     Task {
         let granted = await appState.requestReminderPermissions()
         if granted {
             appState.setupContextAwareReminders()
         }
     }
 }
 ```
 
 2. Monitor rules automatically:
 
 ```swift
 // When user creates a new rule
 func addRule(_ rule: NewRule) {
     rules.append(rule)
     saveRules()
     
     // Start monitoring if authorized
     if ContextAwareReminderManager.shared.isAuthorized {
         ContextAwareReminderManager.shared.startMonitoring(rule: rule)
     }
 }
 ```
 
 3. Test reminders in development:
 
 ```swift
 Button("Test Reminder") {
     ContextAwareReminderManager.shared.testReminder(for: selectedRule)
 }
 ```
 
 ## Privacy Notes
 
 - Screen Time API does NOT give access to specific app names or usage data
 - Only monitors app CATEGORIES (Shopping, Social, etc.)
 - All processing happens on-device
 - User must explicitly grant permission
 - Reminders have 60-minute cooldown to avoid spam
 
 ## Limitations
 
 - iOS 15+ required for FamilyControls framework
 - User must grant Screen Time permission
 - Only works for rules with detectable keywords (shopping, social, etc.)
 - Cannot detect specific apps, only categories
 
 */
