import SwiftUI

// MARK: - Feedback View
// A calm, thoughtful space for users to share their experience
// Very quiet confirmation after submit, not celebration

struct FeedbackView: View {
    @Environment(\.themeManager) private var themeManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var usefulCategories = Set<String>()
    @State private var missingCategories = ""
    @State private var binaryTrackingFair: FeedbackOption?
    @State private var unclearPart = ""
    @State private var bestTheme: String?
    @State private var hardestRule = ""
    
    @State private var showConfirmation = false
    @State private var isSubmitting = false
    
    private let categoryOptions = ["Health", "Work", "Relationships", "Personal Growth", "Habits", "Other"]
    private let themeOptions = ["Sage Calm", "Sky Mist", "Lavender Haze", "Peach Sand", "Monochrome Light", "Monochrome Dark"]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                // Introduction
                Text("Your feedback helps make Rulebook better for everyone. Take your time.")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(themeManager.textSecondary)
                    .padding(.top, 8)
                
                // Question 1: Useful categories
                feedbackSection(
                    title: "Which categories feel most useful?",
                    subtitle: "Select all that apply"
                ) {
                    chipSelector(
                        options: categoryOptions,
                        selection: $usefulCategories,
                        multiSelect: true
                    )
                }
                
                // Question 2: Missing categories
                feedbackSection(
                    title: "Which categories are missing?",
                    subtitle: "What would you add?"
                ) {
                    textEditor(
                        text: $missingCategories,
                        placeholder: "e.g., Finance, Creativity, Learning..."
                    )
                }
                
                // Question 3: Binary tracking
                feedbackSection(
                    title: "Does the binary day tracking feel fair?",
                    subtitle: "Kept or missed, no partial credit"
                ) {
                    optionSelector(
                        options: [
                            FeedbackOption(id: "yes", label: "Yes, it's clear"),
                            FeedbackOption(id: "no", label: "No, too harsh"),
                            FeedbackOption(id: "unsure", label: "Not sure yet")
                        ],
                        selection: $binaryTrackingFair
                    )
                }
                
                // Question 4: Unclear parts
                feedbackSection(
                    title: "What part of the app feels unclear?",
                    subtitle: "Help us improve the experience"
                ) {
                    textEditor(
                        text: $unclearPart,
                        placeholder: "Describe what confused you..."
                    )
                }
                
                // Question 5: Best theme
                feedbackSection(
                    title: "Which theme feels best?",
                    subtitle: "Your favorite visual style"
                ) {
                    chipSelector(
                        options: themeOptions,
                        selection: Binding(
                            get: { bestTheme.map { Set([$0]) } ?? [] },
                            set: { bestTheme = $0.first }
                        ),
                        multiSelect: false
                    )
                }
                
                // Question 6: Hardest rule
                feedbackSection(
                    title: "What rule was hardest to track?",
                    subtitle: "And why, if you'd like to share"
                ) {
                    textEditor(
                        text: $hardestRule,
                        placeholder: "Tell us about the challenge..."
                    )
                }
                
                // Submit button
                submitButton
                    .padding(.top, 16)
                    .padding(.bottom, 120)
            }
            .padding(.horizontal, 20)
        }
        .background(themeManager.backgroundPrimary)
        .navigationTitle("Help improve Rulebook")
        .navigationBarTitleDisplayMode(.inline)
        .overlay(alignment: .bottom) {
            if showConfirmation {
                confirmationBanner
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
    
    // MARK: - Feedback Section
    
    private func feedbackSection<Content: View>(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(themeManager.textPrimary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(themeManager.textSecondary)
                }
            }
            
            content()
        }
    }
    
    // MARK: - Chip Selector
    
    private func chipSelector(
        options: [String],
        selection: Binding<Set<String>>,
        multiSelect: Bool
    ) -> some View {
        FlowLayout(spacing: 8) {
            ForEach(options, id: \.self) { option in
                chipButton(
                    label: option,
                    isSelected: selection.wrappedValue.contains(option),
                    action: {
                        if multiSelect {
                            if selection.wrappedValue.contains(option) {
                                selection.wrappedValue.remove(option)
                            } else {
                                selection.wrappedValue.insert(option)
                            }
                        } else {
                            selection.wrappedValue = [option]
                        }
                    }
                )
            }
        }
    }
    
    private func chipButton(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(isSelected ? themeManager.accent : themeManager.textSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(isSelected ? themeManager.accentSoft : themeManager.backgroundSecondary)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(
                            isSelected ? themeManager.accent.opacity(0.3) : themeManager.stroke,
                            lineWidth: 1
                        )
                )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Option Selector
    
    private func optionSelector(
        options: [FeedbackOption],
        selection: Binding<FeedbackOption?>
    ) -> some View {
        VStack(spacing: 8) {
            ForEach(options) { option in
                optionButton(
                    option: option,
                    isSelected: selection.wrappedValue?.id == option.id,
                    action: { selection.wrappedValue = option }
                )
            }
        }
    }
    
    private func optionButton(option: FeedbackOption, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(option.label)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(themeManager.textPrimary)
                
                Spacer()
                
                ZStack {
                    Circle()
                        .strokeBorder(themeManager.stroke, lineWidth: 2)
                        .frame(width: 20, height: 20)
                    
                    if isSelected {
                        Circle()
                            .fill(themeManager.accent)
                            .frame(width: 12, height: 12)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(themeManager.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(
                        isSelected ? themeManager.accent.opacity(0.3) : themeManager.stroke,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Text Editor
    
    private func textEditor(text: Binding<String>, placeholder: String) -> some View {
        ZStack(alignment: .topLeading) {
            if text.wrappedValue.isEmpty {
                Text(placeholder)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(themeManager.textSecondary.opacity(0.5))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
            }
            
            TextEditor(text: text)
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(themeManager.textPrimary)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 100)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
        }
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(themeManager.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(themeManager.stroke, lineWidth: 1)
        )
    }
    
    // MARK: - Submit Button
    
    private var submitButton: some View {
        Button(action: submitFeedback) {
            HStack {
                if isSubmitting {
                    ProgressView()
                        .tint(themeManager.surface)
                } else {
                    Text("Send feedback")
                        .font(.system(size: 16, weight: .medium))
                }
            }
            .foregroundStyle(themeManager.surface)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(themeManager.accent)
            )
        }
        .buttonStyle(.plain)
        .disabled(isSubmitting)
        .opacity(isSubmitting ? 0.6 : 1.0)
    }
    
    // MARK: - Confirmation Banner
    
    private var confirmationBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20))
                .foregroundStyle(themeManager.success)
            
            Text("Thank you for your feedback")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(themeManager.textPrimary)
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(themeManager.surface)
                .shadow(color: Color.black.opacity(0.1), radius: 20, y: 10)
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 100)
    }
    
    // MARK: - Actions
    
    private func submitFeedback() {
        isSubmitting = true
        
        // Prepare feedback email
        let feedbackText = """
        Feedback from RuleBook App
        
        Useful Categories: \(Array(usefulCategories).joined(separator: ", "))
        
        Missing Categories:
        \(missingCategories.isEmpty ? "None" : missingCategories)
        
        Binary Tracking Fair: \(binaryTrackingFair?.label ?? "Not answered")
        
        Unclear Parts:
        \(unclearPart.isEmpty ? "None" : unclearPart)
        
        Best Theme: \(bestTheme ?? "Not selected")
        
        Hardest Rule to Track:
        \(hardestRule.isEmpty ? "None" : hardestRule)
        """
        
        // Send email
        let email = "aghamatlabakberzade@gmail.com"
        let subject = "RuleBook Feedback"
        let body = feedbackText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        if let url = URL(string: "mailto:\(email)?subject=\(subject)&body=\(body)") {
            UIApplication.shared.open(url)
        }
        
        // Show confirmation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isSubmitting = false
            
            withAnimation(.easeInOut(duration: 0.3)) {
                showConfirmation = true
            }
            
            // Hide confirmation and dismiss after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showConfirmation = false
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    dismiss()
                }
            }
        }
    }
}

// MARK: - Supporting Types

struct FeedbackOption: Identifiable, Equatable {
    let id: String
    let label: String
}

// MARK: - Flow Layout
// Simple flow layout for chips

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX, y: bounds.minY + result.frames[index].minY), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var frames: [CGRect] = []
        var size: CGSize = .zero
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

// MARK: - Previews

#Preview {
    NavigationStack {
        FeedbackView()
    }
    .themeManager(ThemeManager())
}
