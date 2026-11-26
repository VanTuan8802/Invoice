//
//  PremiumPlansScreen.swift
//  Invoice
//
//  Onboarding/Premium/Plans — the paywall. No StoreKit yet: Continue simulates
//  a successful purchase and shows Premium/Success.
//
//  • Onboarding (`AppPhase.premium`): Close → All Set; purchase → `.premiumSuccess`.
//  • Modal (Settings: `app.navi.push(.premium(.plans), type: .fullScreenCover)`):
//    Close dismisses the cover; purchase shows `.premium(.success)` on top.
//

import SwiftUI
import Factory

struct PremiumPlansScreen: View {
    let context: PremiumContext

    // Injected (not @EnvironmentObject) so it also works inside router-presented covers.
    @InjectedObject(\.appFlow) private var coordinator: AppFlowCoordinator
    @Injected(\.app) private var app
    @Environment(\.openURL) private var openURL

    @State private var selection: PremiumPlan = .weekly
    @State private var showRestoreAlert = false

    var body: some View {
        PremiumPlansContent(
            selection: $selection,
            onClose: close,
            onContinue: purchase,
            onRestore: { showRestoreAlert = true },
            onTerms: { open(Self.termsURL) },
            onPrivacy: { open(AppConstants.policyLink) }
        )
        .preferredColorScheme(.dark)
        .alert(R.stringLocalizable.premium_restore(), isPresented: $showRestoreAlert) {
            Button(R.stringLocalizable.common_ok(), role: .cancel) {}
        } message: {
            Text(R.stringLocalizable.premium_restore_empty())
        }
        .trackScreen(.premiumPlans)
    }

    /// Apple's standard EULA until the app has its own terms page.
    private static let termsURL = "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"

    private func close() {
        switch context {
        case .onboarding: coordinator.premiumDidFinish()
        case .modal:      app.navi.pop()
        }
    }

    /// Simulated purchase (no StoreKit yet).
    private func purchase() {
        coordinator.didPurchasePremium()
        guard context == .modal else { return }
        // The success screen redraws this paywall behind its dialog, so show it
        // without the push slide to make the dialog appear in place.
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            app.navi.push(.premium(.success))
        }
    }

    private func open(_ link: String) {
        guard let url = URL(string: link), !link.isEmpty else { return }
        openURL(url)
    }
}

#if DEBUG
#Preview {
    PremiumPlansScreen(context: .onboarding)
}
#endif
