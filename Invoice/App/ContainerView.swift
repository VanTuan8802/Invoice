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
