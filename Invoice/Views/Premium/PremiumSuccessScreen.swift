//
//  PremiumSuccessScreen.swift
//  Invoice
//
//  Onboarding/Premium/Success: the paywall dimmed and blurred behind a white
//  "Successful" dialog. Dismisses itself after a moment (or on tap):
//  onboarding → All Set, modal → closes the whole paywall cover.
//

import SwiftUI
import Factory

struct PremiumSuccessScreen: View {
    let context: PremiumContext

    @InjectedObject(\.appFlow) private var coordinator: AppFlowCoordinator
    @Injected(\.app) private var app

    @State private var appeared = false
    @State private var didFinish = false

    var body: some View {
        ZStack {
            PremiumPlansContent(selection: .constant(.weekly))
                .blur(radius: 2)
                .allowsHitTesting(false)

            Color.black.opacity(0.3)
                .ignoresSafeArea()

            dialog
                .scaleEffect(appeared ? 1 : 0.9)
                .opacity(appeared ? 1 : 0)
        }
        .contentShape(Rectangle())
        .onTapGesture { finish() }
        .preferredColorScheme(.dark)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) { appeared = true }
        }
        .task {
            try? await Task.sleep(nanoseconds: 2_500_000_000)
            finish()
        }
        .trackScreen(.premiumSuccess)
    }

    /// 288pt white card, radius 28: success illustration + title + message.
    private var dialog: some View {
        VStack(spacing: 24) {
            Image(R.image.illus_success)
                .resizable()
                .scaledToFit()
                .frame(width: 130, height: 130)
                .frame(width: 112, height: 112)

            VStack(spacing: 2) {
                Text(R.stringLocalizable.premium_success_title())
                    .font(.title2.bold())
                    .foregroundStyle(Color(R.color.color111118))
                Text(R.stringLocalizable.premium_success_message())
                    .font(.subheadline)
                    .foregroundStyle(Color(R.color.color6B6B78))
            }
            .multilineTextAlignment(.center)
            .frame(width: 270)
            .padding(.bottom, 15)
        }
        .padding(.top, 32)
        .padding(.bottom, 16)
        .frame(width: 288)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color(R.color.colorFFFFFF))
        )
    }

    private func finish() {
        guard !didFinish else { return }
        didFinish = true
        switch context {
        case .onboarding:
            coordinator.premiumDidFinish()
        case .modal:
            // Close the paywall cover together with this screen.
            app.navi.popToRoot(.modal(.count(1)))
        }
    }
}

#if DEBUG
#Preview {
    PremiumSuccessScreen(context: .onboarding)
}
#endif
