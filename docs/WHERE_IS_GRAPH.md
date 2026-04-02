# Where to Find the Rule Relationship Graph

## 📍 Location

The Rule Relationship Graph is in the **Weekly Insights** screen.

### How to Access:

1. **Open the app**
2. **Tap "Review" tab** (bottom navigation, chart icon)
3. **Tap "Weekly Insights"** card at the top (with sparkles ✨ icon)
4. **Scroll down** to see all sections:
   - Weekly Stats
   - Pattern Insights
   - Evolution Suggestions
   - **Rule Connections** ← Graph is here!
   - Rules Performance

---

## 🎨 What You'll See

### **If you have correlated rules (70%+ overlap):**

```
┌─────────────────────────────────┐
│ 🔗 Rule Connections         [2] │
├─────────────────────────────────┤
│                                 │
│  ● Sleep before 11pm            │
│                                 │
│         ↕ 85% connected         │
│       (green indicator)         │
│                                 │
│  ● No phone after 10pm          │
│                                 │
│  "Keeping one helps you         │
│   keep the other"               │
│                                 │
└─────────────────────────────────┘
```

### **If you don't have enough data yet:**

```
┌─────────────────────────────────┐
│ 🔗 Rule Connections         [0] │
├─────────────────────────────────┤
│                                 │
│         🔗                      │
│                                 │
│    No connections yet           │
│                                 │
│  Keep tracking to discover      │
│  which rules support each other │
│                                 │
└─────────────────────────────────┘
```

---

## 🧪 How to Test It

### **Quick Test (Add Test Data):**

1. Add this to `AppState.swift`:

```swift
#if DEBUG
extension AppState {
    func addTestDataForCorrelations() {
        rules.removeAll()
        
        let calendar = Calendar.current
        
        var sleepRule = NewRule(
            statement: "Sleep before 11pm",
            successDefinition: "In bed by 11pm",
            reason: "Better sleep"
        )
        
        var phoneRule = NewRule(
            statement: "No phone after 10pm",
            successDefinition: "Phone away by 10pm",
            reason: "Better sleep"
        )
        
        // Add 14 days of correlated check-ins
        for dayOffset in 0..<14 {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) {
                let keepBoth = dayOffset % 3 != 0 // Keep both 66% of days
                
                sleepRule.checkIns.append(CheckIn(date: date, kept: keepBoth))
                phoneRule.checkIns.append(CheckIn(date: date, kept: keepBoth))
            }
        }
        
        addRule(sleepRule)
        addRule(phoneRule)
    }
}
#endif
```

2. Add a test button to `WeeklyReviewView`:

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

3. Run app → Review → Weekly Insights → Tap "Test Data"
4. Scroll to "Rule Connections" → Should see 85% correlation!

---

## 🎯 Requirements for Graph to Show

1. **At least 2 active rules**
2. **At least 7 check-ins per rule**
3. **Rules kept on same days at least 70% of the time**

---

## 🎨 Visual Features

**Connection Strength Colors:**
- **Green** (80-100%): Very strong correlation
- **Blue** (70-79%): Strong correlation

**What It Shows:**
- Which rules you keep together
- Connection strength percentage
- Insight: "Keeping one helps you keep the other"

---

## 🚀 Why It's Useful

The graph helps you understand:
- Which habits support each other
- Your natural habit clusters
- Which rules to keep together for success

**Example:** If "Sleep before 11pm" and "No phone after 10pm" are 85% correlated, it means your evening routine works as a system - keeping one rule helps you keep the other!

---

## 📱 Navigation Path

```
App Launch
  ↓
Bottom Tab Bar → "Review" (chart icon)
  ↓
Top Card → "Weekly Insights" (with ✨)
  ↓
Scroll Down → "Rule Connections" section
  ↓
See Graph! 🎉
```

---

**That's it!** The graph is in Weekly Insights, which is accessible from the Review tab.
