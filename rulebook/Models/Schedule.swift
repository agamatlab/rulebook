import Foundation

enum Schedule: Codable, Hashable {
    case everyDay
    case weekdays
    case weekends
    case specificDays([Int])
    case timeBased(hour: Int, minute: Int)
    case contextBased(String)
    
    func appliesOn(date: Date, calendar: Calendar = .current) -> Bool {
        let weekday = calendar.component(.weekday, from: date)
        
        switch self {
        case .everyDay:
            return true
        case .weekdays:
            return weekday >= 2 && weekday <= 6
        case .weekends:
            return weekday == 1 || weekday == 7
        case .specificDays(let days):
            return days.contains(weekday)
        case .timeBased, .contextBased:
            return true
        }
    }
    
    var displayName: String {
        switch self {
        case .everyDay:
            return "Every day"
        case .weekdays:
            return "Weekdays"
        case .weekends:
            return "Weekends"
        case .specificDays(let days):
            let dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
            return days.map { dayNames[$0 - 1] }.joined(separator: ", ")
        case .timeBased(let hour, let minute):
            return String(format: "%02d:%02d", hour, minute)
        case .contextBased(let context):
            return context
        }
    }
}
