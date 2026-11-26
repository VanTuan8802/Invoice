//
//  LanguageView.swift
//  Invoice
//
//  Created by VanTuan on 18/6/26.
//

import SwiftUI
import ads_swift
import Factory

struct LanguageView: View {

    /// Where this picker was opened from. Controls the copy, the leading button,
    /// and what happens when the user confirms / cancels.
    enum Mode {
        case onboarding
        case settings
    }

    let mode: Mode

    @EnvironmentObject private var coordinator: AppFlowCoordinator
    @Injected(\.app) private var app

    @State private var hasChosen = false

    @State private var originalLanguage: AppLanguage = .deviceDefault

    @Namespace private var guideNS

    @State private var nativeLanguageVM: NativeAdViewModel?
    @State private var nativeLanguageSelectVM: NativeAdViewModel?
    /// Used when the screen is opened from Settings — shows the shared `nativeAll`.
    @State private var nativeAllVM: NativeAdViewModel?

    init(mode: Mode = .onboarding) {
        self.mode = mode
    }

    // The language the onboarding guide points at first.
    private let guideLanguage: AppLanguage = .english

    private var isGuiding: Bool { mode == .onboarding }
    private var showRowGuide: Bool { isGuiding && !hasChosen }
    private var showButtonGuide: Bool { isGuiding && hasChosen }
    private var canConfirm: Bool { hasChosen }

    /// Settings shows the shared `nativeAll`; onboarding swaps to the post-select
    /// native ad once the user has chosen a language.
    private var currentAdVM: NativeAdViewModel? {
        if mode == .settings { return nativeAllVM }
        return hasChosen ? nativeLanguageSelectVM : nativeLanguageVM
    }

    var body: some View {
        VStack(spacing: 0) {
            BasicHeaderView(
                R.stringLocalizable.language(),
                showBack: mode == .settings,
                backAction: { cancel() },
                trailingView: { saveButton }
            )
            .zIndex(1) // keep the tap guide under "Save" above the list

            ScrollView {
                VStack(spacing: 16) {
                    ForEach(AppLanguage.allCases) { language in
                        row(for: language)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 2)
                .padding(.bottom, 16)
            }

            if let vm = currentAdVM {
                NativeContentView(nativeViewModel: vm, style: .nativeNormalMediaCtaTop)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
            }
        }
        .groupedScreenBackground()
        .onAppear {
            originalLanguage = coordinator.language
            // Settings opens already on the current language; onboarding starts blank.
            if mode == .settings { hasChosen = true }
            loadAds()
        }
        .trackScreen(mode == .onboarding ? .language : .settingsLanguage)
    }

    /// Top-right blue "Save" pill. Disabled until a language is chosen
    /// (onboarding); the tap guide flies here once a selection is made.
    private var saveButton: some View {
        HeaderTextButton(title: R.stringLocalizable.save()) {
            confirm()
        }
        .disabled(!canConfirm)
        .opacity(canConfirm ? 1 : 0.5)
        .overlay(alignment: .center) {
            if showButtonGuide {
                tapGuide.offset(x: 4, y: 26)
            }
        }
    }

    /// Selected: lavender 25% fill + 1pt ink border, radius 10.
    /// Unselected: white card, radius 24. Both 52pt high.
    private func row(for language: AppLanguage) -> some View {
        let isSelected = hasChosen && coordinator.language == language
        let radius: CGFloat = isSelected ? 10 : 24
        return Button {
            select(language)
        } label: {
            HStack(spacing: 12) {
                Image(language.flagImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 32, height: 24)
                    .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .strokeBorder(Color(R.color.colorE8E8EE), lineWidth: 0.5)
                    )
                Text(language.displayName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color(R.color.color111118))
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(isSelected ? Color(R.color.colorCFC3FF).opacity(0.25) : Color(R.color.colorFFFFFF))
            )
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(isSelected ? Color(R.color.color111118) : .clear, lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .overlay(alignment: .trailing) {
            if showRowGuide && language == guideLanguage {
                tapGuide.offset(x: -10, y: 6)
            }
        }
    }

    // MARK: - Ads

    /// Load both native placements once. `isEnable` covers the master switch
    /// so we never show when disabled.
    private func loadAds() {
        // Opened from Settings → single shared `nativeAll` placement.
        if mode == .settings {
            let all = AdUtil.config.nativeAll
            if all.isEnable, nativeAllVM == nil {
                let vm = NativeAdViewModel(adUnitID: all.id)
                vm.refreshAd()
                nativeAllVM = vm
            }
            return
        }

        // Onboarding → dedicated language placements (initial + post-select).
        let initial = AdUtil.config.nativeLanguage
        if initial.isEnable, nativeLanguageVM == nil {
            let vm = NativeAdViewModel(adUnitID: initial.id)
            vm.refreshAd()
            nativeLanguageVM = vm
        }
        let postSelect = AdUtil.config.nativeLanguageSelect
        if postSelect.isEnable, nativeLanguageSelectVM == nil {
            let vm = NativeAdViewModel(adUnitID: postSelect.id)
            vm.refreshAd()
            nativeLanguageSelectVM = vm
        }
    }

    // MARK: - Actions

    /// Apply the picked language immediately (live preview).
    private func select(_ language: AppLanguage) {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
            hasChosen = true
            coordinator.updateLanguage(language)
        }
    }

    /// Top-right "Done": keep the applied language.
    private func confirm() {
        guard hasChosen else { return }
        switch mode {
        case .onboarding:
            // Already applied; persist + advance to the intro carousel.
            coordinator.didSelectLanguage(coordinator.language)
        case .settings:
            app.navi.pop()
        }
    }

    /// Settings back button: discard the live changes and restore the original.
    private func cancel() {
        if coordinator.language != originalLanguage {
            coordinator.updateLanguage(originalLanguage)
        }
        app.navi.pop()
    }

    /// The looping tap hand. The shared `matchedGeometryEffect` id lets it animate
    /// from the language row up to the done button when a selection is made.
    private var tapGuide: some View {
        LottieTapView(name: "tap", tint: .accentColor)
            .frame(width: 64, height: 64)
            .clipped()
            .allowsHitTesting(false)
            .matchedGeometryEffect(id: "tapGuide", in: guideNS)
    }
}

#if DEBUG
#Preview("Onboarding") {
    LanguageView(mode: .onboarding)
        .environmentObject(AppFlowCoordinator())
}

#Preview("Settings") {
    LanguageView(mode: .settings)
        .environmentObject(AppFlowCoordinator())
}
#endif
