import Foundation
import NaturalLanguage

// MARK: - Rule Health Analyzer
// On-device NLP analysis using iOS Natural Language framework
// Uses: Sentiment Analysis, Part-of-Speech Tagging, Named Entity Recognition
// Analyzes: Specificity, Achievability, Measurability

struct RuleHealthScore {
    let specificity: Double      // 0.0 - 1.0 (vague → specific)
    let achievability: Double    // 0.0 - 1.0 (impossible → achievable)
    let measurability: Double    // 0.0 - 1.0 (vague → measurable)
    let overallScore: Double     // Average of all three
    let suggestions: [String]    // Actionable improvements
    
    // AI-powered recommendations
    let recommendedCategory: String?
    let recommendedSchedule: String?
    let categoryConfidence: Double  // 0.0 - 1.0
    let scheduleConfidence: Double  // 0.0 - 1.0
    
    var rating: HealthRating {
        switch overallScore {
        case 0.8...1.0: return .excellent
        case 0.6..<0.8: return .good
        case 0.4..<0.6: return .needsWork
        default: return .poor
        }
    }
    
    enum HealthRating {
        case excellent, good, needsWork, poor
        
        var iconName: String {
            switch self {
            case .excellent: return "checkmark.circle"
            case .good: return "hand.thumbsup"
            case .needsWork: return "exclamationmark.triangle"
            case .poor: return "xmark.circle"
            }
        }
        
        var description: String {
            switch self {
            case .excellent: return "Excellent rule"
            case .good: return "Good rule"
            case .needsWork: return "Needs improvement"
            case .poor: return "Too vague or strict"
            }
        }
    }
}

class RuleHealthAnalyzer {
    
    // MARK: - Vague Words (Lower Specificity)
    
    private let vagueWords: Set<String> = [
        "more", "less", "better", "worse", "sometimes", "often", "rarely",
        "usually", "generally", "mostly", "kind of", "sort of", "try to",
        "attempt to", "work on", "improve", "reduce", "increase"
    ]
    
    // MARK: - Absolute Words (Lower Achievability)
    
    private let absoluteWords: Set<String> = [
        "never", "always", "every single", "all", "none", "zero",
        "completely", "totally", "absolutely", "forever", "constantly"
    ]
    
    // MARK: - Time Words (Increase Measurability)
    
    private let timeWords: Set<String> = [
        "before", "after", "by", "at", "until", "during", "within",
        "am", "pm", "morning", "evening", "night", "midnight",
        "weekday", "weekend", "monday", "tuesday", "wednesday",
        "thursday", "friday", "saturday", "sunday"
    ]
    
    // MARK: - Quantity Words (Increase Measurability)
    
    private let quantityWords: Set<String> = [
        "minutes", "hours", "days", "weeks", "times", "once", "twice",
        "three times", "x times", "per", "each", "every"
    ]
    
    // MARK: - Main Analysis Function
    
    func analyze(_ ruleText: String) -> RuleHealthScore {
        let normalizedText = ruleText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !normalizedText.isEmpty else {
            return RuleHealthScore(
                specificity: 0.0,
                achievability: 0.0,
                measurability: 0.0,
                overallScore: 0.0,
                suggestions: ["Enter a rule to see health analysis"],
                recommendedCategory: nil,
                recommendedSchedule: nil,
                categoryConfidence: 0.0,
                scheduleConfidence: 0.0
            )
        }
        
        // Use iOS NLP for linguistic analysis
        let linguisticAnalysis = performLinguisticAnalysis(normalizedText)
        
        // Calculate scores using both rule-based and NLP
        let specificity = calculateSpecificity(normalizedText, linguistics: linguisticAnalysis)
        let achievability = calculateAchievability(normalizedText, linguistics: linguisticAnalysis)
        let measurability = calculateMeasurability(normalizedText, linguistics: linguisticAnalysis)
        
        // AI-powered recommendations
        let availableCategories = ["Sleep & Recovery", "Physical Health & Movement", "Nutrition & Hydration", 
                                   "Mental Health", "Emotional Regulation", "Focus & Deep Work", 
                                   "Work Boundaries", "Money & Spending", "Digital Hygiene", 
                                   "Relationships & Communication"]
        let categoryRecommendation = recommendCategory(for: normalizedText, linguistics: linguisticAnalysis, availableCategories: availableCategories)
        let scheduleRecommendation = recommendSchedule(for: normalizedText, linguistics: linguisticAnalysis)
        
        // Generate suggestions
        let suggestions = generateSuggestions(
            text: normalizedText,
            specificity: specificity,
            achievability: achievability,
            measurability: measurability,
            linguistics: linguisticAnalysis
        )
        
        let overallScore = (specificity + achievability + measurability) / 3.0
        
        return RuleHealthScore(
            specificity: specificity,
            achievability: achievability,
            measurability: measurability,
            overallScore: overallScore,
            suggestions: suggestions,
            recommendedCategory: categoryRecommendation.category,
            recommendedSchedule: scheduleRecommendation.schedule,
            categoryConfidence: categoryRecommendation.confidence,
            scheduleConfidence: scheduleRecommendation.confidence
        )
    }
    
    // MARK: - iOS NLP Linguistic Analysis
    
    struct LinguisticAnalysis {
        let sentiment: Double // -1.0 (negative) to 1.0 (positive)
        let hasVerbs: Bool
        let hasNouns: Bool
        let hasNumbers: Bool
        let hasProperNouns: Bool
        let verbCount: Int
        let nounCount: Int
        let adjectiveCount: Int
        let wordCount: Int
    }
    
    private func performLinguisticAnalysis(_ text: String) -> LinguisticAnalysis {
        let tagger = NLTagger(tagSchemes: [.lexicalClass, .sentimentScore])
        tagger.string = text
        
        var hasVerbs = false
        var hasNouns = false
        var hasProperNouns = false
        var verbCount = 0
        var nounCount = 0
        var adjectiveCount = 0
        var wordCount = 0
        
        // Analyze parts of speech
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lexicalClass) { tag, _ in
            wordCount += 1
            
            if let tag = tag {
                switch tag {
                case .verb:
                    hasVerbs = true
                    verbCount += 1
                case .noun:
                    hasNouns = true
                    nounCount += 1
                case .adjective:
                    adjectiveCount += 1
                default:
                    break
                }
            }
            
            return true
        }
        
        // Check for proper nouns (capitalized words that aren't at sentence start)
        let words = text.components(separatedBy: .whitespaces)
        for (index, word) in words.enumerated() {
            if index > 0 && word.first?.isUppercase == true {
                hasProperNouns = true
                break
            }
        }
        
        // Analyze sentiment
        var sentimentScore = 0.0
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .paragraph, scheme: .sentimentScore) { tag, _ in
            if let tag = tag, let score = Double(tag.rawValue) {
                sentimentScore = score
            }
            return true
        }
        
        // Use NLP to detect numbers (not just regex)
        let hasNumbers = detectNumbers(text)
        
        return LinguisticAnalysis(
            sentiment: sentimentScore,
            hasVerbs: hasVerbs,
            hasNouns: hasNouns,
            hasNumbers: hasNumbers,
            hasProperNouns: hasProperNouns,
            verbCount: verbCount,
            nounCount: nounCount,
            adjectiveCount: adjectiveCount,
            wordCount: wordCount
        )
    }
    
    // MARK: - Enhanced Number Detection using NLP
    
    private func detectNumbers(_ text: String) -> Bool {
        // Use NLTagger to detect numbers
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = text
        
        var foundNumber = false
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lexicalClass) { tag, tokenRange in
            if let tag = tag, tag == .number {
                foundNumber = true
                return false // Stop enumeration
            }
            
            // Also check the actual word content
            let word = String(text[tokenRange]).lowercased()
            
            // Check for written numbers
            let writtenNumbers = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten",
                                "twenty", "thirty", "forty", "fifty", "hundred", "thousand"]
            if writtenNumbers.contains(word) {
                foundNumber = true
                return false
            }
            
            // Check for numeric digits
            if word.rangeOfCharacter(from: .decimalDigits) != nil {
                foundNumber = true
                return false
            }
            
            return true
        }
        
        return foundNumber
    }
    
    // MARK: - Specificity Analysis (Enhanced with NLP)
    
    private func calculateSpecificity(_ text: String, linguistics: LinguisticAnalysis) -> Double {
        let words = tokenize(text.lowercased())
        var score = 0.5 // Start neutral
        
        // iOS NLP: Check for concrete nouns (more specific)
        if linguistics.hasNouns {
            score += 0.2
        }
        
        // iOS NLP: Check for action verbs (more specific)
        if linguistics.hasVerbs {
            score += 0.15
        }
        
        // iOS NLP: Multiple nouns = more detailed
        if linguistics.nounCount >= 2 {
            score += 0.1
        }
        
        // Penalize vague words
        let vagueCount = words.filter { vagueWords.contains($0) }.count
        score -= Double(vagueCount) * 0.15
        
        // Reward specific details
        if linguistics.hasNumbers {
            score += 0.15
        }
        
        if containsTimeReference(text) {
            score += 0.15
        }
        
        // iOS NLP: Proper nouns (specific places/names)
        if linguistics.hasProperNouns {
            score += 0.1
        }
        
        // Penalize very short rules (likely vague)
        if linguistics.wordCount < 3 {
            score -= 0.2
        }
        
        // Reward longer, detailed rules
        if linguistics.wordCount > 6 {
            score += 0.1
        }
        
        return max(0.0, min(1.0, score))
    }
    
    // MARK: - Achievability Analysis (Enhanced with NLP)
    
    private func calculateAchievability(_ text: String, linguistics: LinguisticAnalysis) -> Double {
        let words = tokenize(text.lowercased())
        var score = 1.0
        
        // iOS NLP: Sentiment analysis (negative sentiment = harder to achieve)
        // Negative rules ("never", "don't") tend to be harder
        if linguistics.sentiment < -0.3 {
            score -= 0.2
        }
        
        // Penalize absolute words heavily (never, always, etc.)
        let absoluteCount = words.filter { absoluteWords.contains($0) }.count
        score -= Double(absoluteCount) * 0.35
        
        // Extra penalty for "never" specifically (most unrealistic)
        if words.contains("never") {
            score -= 0.2
        }
        
        // Reward conditional/flexible language
        let flexibleWords = ["weekday", "workday", "when", "if", "unless", "except", "most", "usually"]
        let flexibleCount = words.filter { flexibleWords.contains($0) }.count
        if flexibleCount > 0 {
            score += 0.15
        }
        
        // iOS NLP: Too many adjectives = overly ambitious
        if linguistics.adjectiveCount > 3 {
            score -= 0.1
        }
        
        // Penalize multiple restrictions in one rule
        let restrictionWords = ["and", "also", "plus", "additionally"]
        let restrictionCount = words.filter { restrictionWords.contains($0) }.count
        if restrictionCount > 2 {
            score -= 0.2
        }
        
        return max(0.0, min(1.0, score))
    }
    
    // MARK: - Measurability Analysis (Enhanced with NLP)
    
    private func calculateMeasurability(_ text: String, linguistics: LinguisticAnalysis) -> Double {
        var score = 0.2 // Base score
        
        // iOS NLP: Has action verb = measurable action
        if linguistics.hasVerbs {
            score += 0.25
        }
        
        // iOS NLP: Multiple verbs = complex but measurable
        if linguistics.verbCount >= 2 {
            score += 0.1
        }
        
        // Reward numbers
        if linguistics.hasNumbers {
            score += 0.25
        }
        
        // Reward time references
        if containsTimeReference(text) {
            score += 0.25
        }
        
        // Reward quantity words
        let words = tokenize(text.lowercased())
        let quantityCount = words.filter { quantityWords.contains($0) }.count
        if quantityCount > 0 {
            score += 0.15
        }
        
        return min(1.0, score)
    }
    
    // MARK: - Suggestion Generation (Enhanced with NLP)
    
    private func generateSuggestions(
        text: String,
        specificity: Double,
        achievability: Double,
        measurability: Double,
        linguistics: LinguisticAnalysis
    ) -> [String] {
        var suggestions: [String] = []
        
        // iOS NLP: Missing action verb
        if !linguistics.hasVerbs && measurability < 0.6 {
            suggestions.append("Add an action verb (e.g., 'do', 'avoid', 'complete')")
        }
        
        // Specificity suggestions
        if specificity < 0.5 {
            let words = tokenize(text.lowercased())
            let vagueFound = words.filter { vagueWords.contains($0) }
            
            if !vagueFound.isEmpty {
                suggestions.append("Replace vague words like '\(vagueFound.first!)' with specific details")
            } else if !linguistics.hasNouns {
                suggestions.append("Add specific details about what, where, or when")
            } else {
                suggestions.append("Add more specific details (time, place, or amount)")
            }
        } else if specificity < 0.8 {
            // Good but could be better
            suggestions.append("Consider adding more context (e.g., 'when tempted' or 'at home')")
        }
        
        // Achievability suggestions
        if achievability < 0.6 {
            let words = tokenize(text.lowercased())
            let absoluteFound = words.filter { absoluteWords.contains($0) }
            
            if !absoluteFound.isEmpty {
                let word = absoluteFound.first!
                if word == "never" {
                    suggestions.append("'Never' is unrealistic. Try 'rarely' or 'avoid on weekdays'")
                } else if word == "always" {
                    suggestions.append("'Always' is too strict. Try 'usually' or 'most days'")
                } else {
                    suggestions.append("'\(word)' is very strict. Consider adding flexibility")
                }
            } else if linguistics.sentiment < -0.3 {
                suggestions.append("Negative rules are harder to keep. Try framing positively")
            }
        } else if achievability < 0.9 {
            // Check for multiple restrictions
            let words = tokenize(text.lowercased())
            let restrictionWords = ["and", "also", "plus", "additionally"]
            let restrictionCount = words.filter { restrictionWords.contains($0) }.count
            
            if restrictionCount >= 2 {
                suggestions.append("This rule has multiple parts. Consider splitting into separate rules")
            }
        }
        
        // Measurability suggestions
        if measurability < 0.5 {
            if !linguistics.hasNumbers && !containsTimeReference(text) {
                suggestions.append("Add a specific time or number to make this measurable")
            }
        } else if measurability < 0.9 {
            // Good but could be more precise
            if !linguistics.hasNumbers {
                suggestions.append("Add a specific quantity for clearer tracking (e.g., '1 teaspoon')")
            } else if !containsTimeReference(text) {
                suggestions.append("Add a time reference for better clarity (e.g., 'per day' or 'by 10pm')")
            }
        }
        
        // Optimization suggestions for good rules (70-89%)
        let overallScore = (specificity + achievability + measurability) / 3.0
        if overallScore >= 0.7 && overallScore < 0.9 {
            // Find what's holding it back
            if specificity < 0.85 {
                suggestions.append("💡 To reach 90%+: Be more specific about when or where this applies")
            } else if achievability < 0.85 {
                suggestions.append("💡 To reach 90%+: Simplify or add flexibility to make it more achievable")
            } else if measurability < 0.85 {
                suggestions.append("💡 To reach 90%+: Add precise measurements or time frames")
            }
        }
        
        // Positive reinforcement for excellent rules
        if overallScore >= 0.9 {
            suggestions.append("✓ Excellent rule! This is specific, achievable, and measurable.")
        } else if overallScore >= 0.8 {
            suggestions.append("✓ Great rule! Just a few tweaks could make it perfect.")
        }
        
        return suggestions
    }
    
    // MARK: - AI Category Recommendation (Matches Existing Categories)
    
    func recommendCategory(for text: String, linguistics: LinguisticAnalysis, availableCategories: [String]) -> (category: String, confidence: Double) {
        let lowercased = text.lowercased()
        var categoryScores: [String: Double] = [:]
        
        // Score each available category
        for category in availableCategories {
            let score = calculateCategoryScore(text: lowercased, category: category)
            if score > 0 {
                categoryScores[category] = score
            }
        }
        
        // Find highest score
        if let maxCategory = categoryScores.max(by: { $0.value < $1.value }) {
            let confidence = min(1.0, maxCategory.value / 3.0) // Normalize
            return (maxCategory.key, confidence)
        }
        
        return ("", 0.0) // No recommendation
    }
    
    private func calculateCategoryScore(text: String, category: String) -> Double {
        var score = 0.0
        
        switch category {
        case "Sleep & Recovery":
            let keywords = ["sleep", "bed", "rest", "nap", "wake", "bedtime", "midnight", "morning"]
            score = Double(countKeywords(text, keywords: keywords)) * 1.5
            
        case "Physical Health & Movement":
            let keywords = ["exercise", "workout", "gym", "run", "walk", "yoga", "fitness", "sport", "train", "move"]
            score = Double(countKeywords(text, keywords: keywords)) * 1.5
            
        case "Nutrition & Hydration":
            let keywords = ["eat", "food", "sugar", "calories", "diet", "meal", "drink", "water", "nutrition", "snack"]
            score = Double(countKeywords(text, keywords: keywords)) * 1.5
            
        case "Mental Health":
            let keywords = ["meditate", "meditation", "mindful", "breathe", "journal", "gratitude", "therapy", "mental"]
            score = Double(countKeywords(text, keywords: keywords)) * 1.5
            
        case "Emotional Regulation":
            let keywords = ["emotion", "feeling", "calm", "stress", "anxiety", "anger", "mood", "react"]
            score = Double(countKeywords(text, keywords: keywords)) * 1.5
            
        case "Focus & Deep Work":
            let keywords = ["focus", "concentrate", "work", "task", "project", "productive", "deep work", "study"]
            score = Double(countKeywords(text, keywords: keywords)) * 1.5
            
        case "Work Boundaries":
            let keywords = ["work", "office", "meeting", "email", "deadline", "overtime", "weekend", "boundary"]
            score = Double(countKeywords(text, keywords: keywords)) * 1.5
            
        case "Money & Spending":
            let keywords = ["money", "save", "spend", "budget", "buy", "purchase", "invest", "dollar", "cost", "price", "shopping"]
            score = Double(countKeywords(text, keywords: keywords)) * 1.5
            
        case "Digital Hygiene":
            let keywords = ["phone", "screen", "device", "computer", "laptop", "tablet", "tv", "app", "social media", "instagram", "tiktok", "youtube", "scroll"]
            score = Double(countKeywords(text, keywords: keywords)) * 1.5
            
        case "Relationships & Communication":
            let keywords = ["friend", "family", "call", "text", "message", "social", "people", "relationship", "talk", "visit", "connect"]
            score = Double(countKeywords(text, keywords: keywords)) * 1.5
            
        default:
            score = 0.0
        }
        
        return score
    }
    
    private func countKeywords(_ text: String, keywords: [String]) -> Int {
        var count = 0
        for keyword in keywords {
            if text.contains(keyword) {
                count += 1
            }
        }
        return count
    }
    
    // MARK: - AI Schedule Recommendation
    
    private func recommendSchedule(for text: String, linguistics: LinguisticAnalysis) -> (schedule: String, confidence: Double) {
        let lowercased = text.lowercased()
        
        // Check for explicit time mentions (highest confidence)
        if lowercased.contains("every day") || lowercased.contains("daily") || lowercased.contains("each day") {
            return ("Every day", 0.95)
        }
        
        if lowercased.contains("weekday") || (lowercased.contains("monday") && lowercased.contains("friday")) {
            return ("Weekdays", 0.95)
        }
        
        if lowercased.contains("weekend") || (lowercased.contains("saturday") && lowercased.contains("sunday")) {
            return ("Weekends", 0.95)
        }
        
        // Check for specific days
        let days = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"]
        let mentionedDays = days.filter { lowercased.contains($0) }
        if mentionedDays.count >= 2 && mentionedDays.count < 5 {
            return ("Specific days", 0.9)
        }
        
        // Check for time-based patterns
        if lowercased.contains("morning") || lowercased.contains("am") || lowercased.contains("wake") {
            return ("Every day", 0.85) // Morning routines are usually daily
        }
        
        if lowercased.contains("evening") || lowercased.contains("night") || lowercased.contains("pm") || lowercased.contains("bedtime") || lowercased.contains("before bed") {
            return ("Every day", 0.85) // Evening routines are usually daily
        }
        
        // Infer from category keywords (medium confidence)
        if lowercased.contains("sleep") || lowercased.contains("bed") {
            return ("Every day", 0.8)
        }
        
        if lowercased.contains("work") || lowercased.contains("office") || lowercased.contains("meeting") {
            return ("Weekdays", 0.8)
        }
        
        if lowercased.contains("exercise") || lowercased.contains("gym") || lowercased.contains("workout") {
            return ("Weekdays", 0.75) // Most people exercise on weekdays
        }
        
        if lowercased.contains("meditate") || lowercased.contains("journal") || lowercased.contains("gratitude") {
            return ("Every day", 0.75)
        }
        
        if lowercased.contains("phone") || lowercased.contains("screen") || lowercased.contains("device") {
            return ("Every day", 0.75)
        }
        
        if lowercased.contains("eat") || lowercased.contains("food") || lowercased.contains("sugar") || lowercased.contains("meal") {
            return ("Every day", 0.75)
        }
        
        // Check for frequency indicators
        if lowercased.contains("once") || lowercased.contains("twice") || lowercased.contains("times") {
            return ("Specific days", 0.7)
        }
        
        // Default recommendation based on rule complexity
        if linguistics.wordCount < 5 {
            return ("Weekdays", 0.6) // Simple rules = start easier
        }
        
        return ("Every day", 0.65) // Default
    }
    
    private func tokenize(_ text: String) -> [String] {
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = text.lowercased()
        
        var tokens: [String] = []
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { range, _ in
            tokens.append(String(text[range]).lowercased())
            return true
        }
        
        return tokens
    }
    
    private func containsNumbers(_ text: String) -> Bool {
        let numberPattern = "\\d+"
        let regex = try? NSRegularExpression(pattern: numberPattern)
        let range = NSRange(text.startIndex..., in: text)
        return regex?.firstMatch(in: text, range: range) != nil
    }
    
    private func containsTimeReference(_ text: String) -> Bool {
        let words = tokenize(text)
        return words.contains { timeWords.contains($0) }
    }
    
    private func containsActionVerbs(_ text: String) -> Bool {
        let actionVerbs: Set<String> = [
            "sleep", "wake", "eat", "drink", "exercise", "run", "walk",
            "read", "write", "work", "study", "call", "text", "check",
            "buy", "spend", "save", "wait", "avoid", "stop", "start"
        ]
        
        let words = tokenize(text)
        return words.contains { actionVerbs.contains($0) }
    }
}

// MARK: - Preview Helpers

extension RuleHealthAnalyzer {
    static func previewScore(for text: String) -> RuleHealthScore {
        let analyzer = RuleHealthAnalyzer()
        return analyzer.analyze(text)
    }
}
