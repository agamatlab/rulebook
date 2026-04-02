import SwiftUI

struct WelcomeScreen: View {
    let onGetStarted: () -> Void
    
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var iconOpacity: Double = 0
    @State private var titleOpacity: Double = 0
    @State private var subtitleOpacity: Double = 0
    @State private var buttonOffset: CGFloat = 50
    @State private var buttonOpacity: Double = 0
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 80)
                
                bookIcon
                
                Spacer()
                    .frame(height: 48)
                
                titleText
                
                Spacer()
                    .frame(height: 20)
                
                subtitleText
                
                Spacer()
                
                getStartedButton
                    .padding(.bottom, 60)
            }
            .padding(.horizontal, 32)
        }
        .ignoresSafeArea()
        .onAppear {
            startAnimationSequence()
        }
    }
    
    // MARK: - Background
    
    private var backgroundGradient: some View {
        ZStack {
            themeManager.backgroundPrimary
                .ignoresSafeArea()
            
            LinearGradient(
                colors: [
                    themeManager.accent.opacity(0.08),
                    themeManager.backgroundPrimary.opacity(0)
                ],
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()
        }
    }
    
    // MARK: - Book Icon
    
    private var bookIcon: some View {
        Image(systemName: "book")
            .font(.system(size: 56, weight: .light))
            .foregroundStyle(themeManager.accent)
            .opacity(iconOpacity)
    }
    
    // MARK: - Title
    
    private var titleText: some View {
        Text("Keep promises to yourself")
            .font(.system(size: 34, weight: .bold, design: .rounded))
            .foregroundStyle(themeManager.textPrimary)
            .multilineTextAlignment(.center)
            .lineSpacing(4)
            .opacity(titleOpacity)
    }
    
    // MARK: - Subtitle
    
    private var subtitleText: some View {
        Text("Create personal rules, group them by category, and track whether you kept them day by day")
            .font(.system(size: 17, weight: .regular))
            .foregroundStyle(themeManager.textSecondary)
            .multilineTextAlignment(.center)
            .lineSpacing(6)
            .padding(.horizontal, 8)
            .opacity(subtitleOpacity)
    }
    
    // MARK: - Get Started Button
    
    private var getStartedButton: some View {
        Button(action: onGetStarted) {
            Text("Get Started")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(themeManager.accent)
                )
        }
        .offset(y: buttonOffset)
        .opacity(buttonOpacity)
    }
    
    // MARK: - Animation Sequence
    
    private func startAnimationSequence() {
        // Icon appears first
        withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
            iconOpacity = 1.0
        }
        
        // Title fades in
        withAnimation(.easeOut(duration: 0.8).delay(0.8)) {
            titleOpacity = 1.0
        }
        
        // Subtitle fades in
        withAnimation(.easeOut(duration: 0.8).delay(1.3)) {
            subtitleOpacity = 1.0
        }
        
        // Button rises from below
        withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(1.8)) {
            buttonOffset = 0
            buttonOpacity = 1.0
        }
    }
}

// MARK: - Preview

#Preview {
    WelcomeScreen(onGetStarted: {})
}
