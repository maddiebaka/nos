//
//  OnboardingView.swift
//  Nos
//
//  Created by Shane Bielefeld on 2/14/23.
//

import SwiftUI
import Dependencies
import Logger

class OnboardingState: ObservableObject {
    @Published var flow: OnboardingFlow = .createAccount
    @Published var step: OnboardingStep = .onboardingStart {
        didSet {
            path.append(step)
        }
    }
    @Published var path = NavigationPath()
}

enum OnboardingFlow {
    case createAccount
    case loginToExistingAccount
}

enum OnboardingStep {
    case onboardingStart
    case ageVerification
    case notOldEnough
    case termsOfService
    case login
}

struct OnboardingView: View {
    @Environment(CurrentUser.self) private var currentUser

    @StateObject var state = OnboardingState()
    
    /// Completion to be called when all onboarding steps are complete
    let completion: @MainActor () -> Void
    
    @State private var selectedTab: OnboardingStep = .onboardingStart
    
    var body: some View {
        NavigationStack(path: $state.path) {
            OnboardingStartView()
                .environmentObject(state)
                .navigationDestination(for: OnboardingStep.self) { step in
                    switch step {
                    case .onboardingStart:
                        OnboardingStartView()
                            .environmentObject(state)
                    case .ageVerification:
                        OnboardingAgeVerificationView()
                            .environmentObject(state)
                    case .notOldEnough:
                        OnboardingNotOldEnoughView()
                            .environmentObject(state)
                    case .termsOfService:
                        OnboardingTermsOfServiceView(completion: completion)
                            .environmentObject(state)
                    case .login:
                        OnboardingLoginView(completion: completion)
                    }
                }
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView {}
    }
}
