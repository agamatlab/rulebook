# Testing Guide: Rule Relationship Graph Visualization

## 🎯 What It Does

The Rule Relationship Graph shows which rules are **correlated** - meaning when you keep one rule, you're more likely to keep another. This helps you understand which habits support each other.

---

## 🧪 How to Test It

### **Method 1: Add Test Data Helper to AppState**

Add this extension to `AppState.swift`:

```swift
#if DEBUG
extension AppState {
    func addTestDataForCorrelations() {
        // Clear existing
        rules.removeAll()
        
        let calendar = Calendar.current
        
        // Rule 1: Sleep
        var sleepRule = NewRule(
            statement: "Sleep before 11pm",
            successDefinition: "In bed by 11pm",
            reason: "Better sleep"
        )
        
        // Rule 2: No phone (correlated with sleep)
        var phoneRule = NewRule(
            statement: "No phone after 10pm",
            successDefinition: "Phone away by 10pm",
            reason: "Better sleep"
        )
        
        // Rule 3: Exercise (independent)
        var exerciseRule = NewRule(
            statement: "Morning workout",
            successDefinition: "30 min exercise",
            reason: "Stay healthy"
        )
        
        // Add correlated check-ins for sleep + phone
        for dayOffset in 0..<14 {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) {
                let keepBoth = dayOffset % 3 != 0 // Keep both 66% of days
                
                sleepRule.checkIns.append(CheckIn(date: date, kept: keepBoth))
                phoneRule.checkIns.append(CheckIn(date: date, kept: keepBoth))
                
                // Exercise has different pattern
                let keepExercise = dayOffset % 2 == 0
                exerciseRule.checkIns.append(CheckIn(date: date, kept: keepExercise))
            }
        }
        
        addRule(sleepRule)
        addRule(phoneRule)
        addRule(exerciseRule)
    }
}
#endif
```

### **Method 2: Add Test Button to WeeklyReviewView**

In `WeeklyReviewView.swift`, add this button:

```swift
#if DEBUG
.toolbar {
    ToolbarItem(placement: .navigationBarTrailing) {
        Button("Test Data") {
            appState.addTestDataForCorrelations()
            analyzePatterns()
        }
    }
}
#endif
```

---

## 📊 What You Should See

### **High Correlation (85%+)**
```
┌────────────────────────────────┐
│ ● Sleep before 11pm            │
└────────────────────────────────┘
           ↕ 85% connected
┌────────────────────────────────┐
│ ● No phone after 10pm          │
└────────────────────────────────┘

"Keeping one helps you keep the other"
```

### **No Correlations**
```
🔗 No connections yet

Keep tracking to discover which rules
support each other
```

---

## 🧮 How Correlation is Calculated

Uses **Jaccard Similarity**:

```
Correlation = (Days both kept) / (Days either kept)

Example:
- Rule A kept: Days 1, 2, 3, 5, 6
- Rule B kept: Days 1, 2, 3, 4, 6

Overlap: Days 1, 2, 3, 6 = 4 days
Union: Days 1, 2, 3, 4, 5, 6 = 6 days

Correlation = 4 / 6 = 0.67 (67%)
```

Only correlations **≥ 70%** are shown.

---

## 🎨 Visual Indicators

**Connection Strength Colors:**
- **Green** (80-100%): Very strong
- **Blue** (70-79%): Strong  
- **Orange** (60-69%): Moderate

---

## 🔍 Real-World Test Scenarios

### **Scenario 1: Evening Routine**
- "No phone after 10pm"
- "Sleep before 11pm"
- "Read before bed"

Keep all 3 together for 7+ days → Should show 3 correlations

### **Scenario 2: Independent Rules**
- "Exercise 3x per week" (Mon, Wed, Fri)
- "Call family on Sunday"

Keep on different days → Should show NO correlations

---

## 🐛 Troubleshooting

**"No connections yet" always shows:**
1. Need at least **7 check-ins** per rule
2. Need at least **2 rules** with overlapping kept days
3. Correlation must be **≥ 70%**

---

## 📱 Where to See It

1. **WeeklyReviewView** - Full dashboard
2. **Standalone** - `RuleRelationshipGraphView` preview
3. **Pattern insights** - Tap correlation patterns

---

## ✅ Success Criteria

- ✅ Shows "No connections yet" with 0 correlations
- ✅ Shows correlation cards when rules overlap
- ✅ Connection strength matches actual overlap
- ✅ Colors change based on strength
- ✅ Updates when new check-ins added

---

**Now you can test the Rule Relationship Graph!** 🎉
