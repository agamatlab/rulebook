import SwiftUI

// MARK: - Rulebook App
// Main app entry point with onboarding flow

@main
struct RulebookApp: App {
    @StateObject private var appState: AppState
    
    init() {
        let state = AppState()
        _appState = StateObject(wrappedValue: state)
    }
    
    var body: some Scene {
        WindowGroup {
            RootView(appState: appState)
                .preferredColorScheme(.light)
        }
    }
}

// MARK: - Root View
// Handles navigation between onboarding and main app

private struct RootView: View {
    @ObservedObject var appState: AppState
    
    @State private var onboardingStep: OnboardingStep = .welcome
    
    var body: some View {
        Group {
            if appState.isOnboarded {
                MainTabView()
                    .environmentObject(appState)
                    .environmentObject(appState.themeManager)
                    .environmentObject(appState.categoryManager)
            } else {
                onboardingFlow
            }
        }
    }
    
    @ViewBuilder
    private var onboardingFlow: some View {
        switch onboardingStep {
        case .welcome:
            WelcomeScreen {
                withAnimation(.easeInOut(duration: 0.3)) {
                    onboardingStep = .categories
                }
            }
            .environmentObject(appState.themeManager)
            .transition(.asymmetric(
                insertion: .move(edge: .trailing),
                removal: .move(edge: .leading)
            ))
            
        case .categories:
            OnboardingCategoriesView {
                withAnimation(.easeInOut(duration: 0.3)) {
                    onboardingStep = .theme
                }
            }
            .environmentObject(appState)
            .environmentObject(appState.themeManager)
            .environmentObject(appState.categoryManager)
            .transition(.asymmetric(
                insertion: .move(edge: .trailing),
                removal: .move(edge: .leading)
            ))
            
        case .theme:
            OnboardingThemeView {
                withAnimation(.easeInOut(duration: 0.3)) {
                    // Onboarding complete - app state will update
                }
            }
            .environmentObject(appState)
            .environmentObject(appState.themeManager)
            .transition(.asymmetric(
                insertion: .move(edge: .trailing),
                removal: .move(edge: .leading)
            ))
        }
    }
}

// MARK: - Onboarding Step

private enum OnboardingStep {
    case welcome
    case categories
    case theme
}

// MARK: - Preview

#Preview {
    MainTabView()
        .environmentObject(AppState())
        .environmentObject(ThemeManager())
        .environmentObject(CategoryManager())
}
