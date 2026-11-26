//
//  ContainerView.swift
//  Invoice
//
//  Created by VanTuan on 18/6/26.
//

import SwiftUI
import Factory

struct ContainerView: View {
    @InjectedObject(\.appFlow) private var coordinator: AppFlowCoordinator
    @InjectedObject(\.homeNavi) private var homeNavi: Navigation

    var body: some View {
        content
            .environmentObject(coordinator)
    }

    @ViewBuilder
    private var content: some View {
        #if DEBUG
        if let destination = UIPreview.destination {
            NavigationRoot(destination: destination, navigation: homeNavi)
                .onAppear { UIPreview.prepare() }
        } else {
            flow
        }
        #else
        flow
        #endif
    }

    #if DEBUG
    init() {
        // `-uiPreviewPhase <phase>`: open a launch-flow phase directly (skips
        // splash / ads / ATT), e.g. `-uiPreviewPhase businessDetails`. Applied
        // before the first render, once per launch.
        if !Self.didApplyPreviewPhase, let phase = Self.previewPhase {
            Self.didApplyPreviewPhase = true
            coordinator.debugShow(phase)
        }
    }

    private static var didApplyPreviewPhase = false

    private static var previewPhase: AppPhase? {
        let arguments = ProcessInfo.processInfo.arguments
        guard let index = arguments.firstIndex(of: "-uiPreviewPhase"), index + 1 < arguments.count else { return nil }
        return AppPhase(rawValue: arguments[index + 1])
    }
    #endif

    private var flow: some View {
        ZStack {
            switch coordinator.phase {
            case .splash:
                SplashView()
                    .transition(.opacity)
            case .language:
                LanguageView()
                    .transition(.opacity)
            case .intro:
                IntroView()
                    .transition(.opacity)
            case .welcome:
                WelcomeView()
                    .transition(.opacity)
            case .businessDetails:
                BusinessDetailsView()
                    .transition(.opacity)
            case .businessLogo:
                BusinessLogoView()
                    .transition(.opacity)
            case .template:
                TemplatePickerView()
                    .transition(.opacity)
            case .premium:
                PremiumPlansScreen(context: .onboarding)
                    .transition(.opacity)
            case .premiumSuccess:
                PremiumSuccessScreen(context: .onboarding)
                    .transition(.opacity)
            case .allSet:
                AllSetView()
                    .transition(.opacity)
            case .home:
                NavigationRoot(destination: .home, navigation: homeNavi)
                    .transition(.opacity)
            }
        }
        // Views that show localized text observe `coordinator`, so they re-render
        // (and re-read `R.stringLocalizable`) when the language changes at runtime — no
        // destructive `.id(...)` rebuild that would reset state or close sheets.
        .animation(.easeInOut(duration: 0.35), value: coordinator.phase)
    }
}

#if DEBUG
#Preview {
    ContainerView()
}
#endif
