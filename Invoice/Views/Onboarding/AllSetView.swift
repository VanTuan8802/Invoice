//
//  AllSetView.swift
//  Invoice
//
//  Onboarding/All Set: confetti + success illustration, "You're All Set!" and
//  "Create New Invoice", which finishes onboarding and opens a new invoice.
//

import SwiftUI
import Factory

struct AllSetView: View {
    @EnvironmentObject private var coordinator: AppFlowCoordinator
    @Injected(\.app) private var app

    var body: some View {
        ZStack(alignment: .top) {
            Color(R.color.colorF4F4F6)
                .ignoresSafeArea()

            // 390pt confetti burst, 8pt below the top of the screen.
            Image(R.image.illus_confetti)
                .resizable()
                .scaledToFit()
                .frame(width: 390, height: 390)
                .padding(.top, 8)
                .ignoresSafeArea(edges: .top)
                .allowsHitTesting(false)

            VStack(spacing: 0) {
                Image(R.image.illus_success)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 210, height: 210)
                    .padding(.top, 71)

                VStack(spacing: 12) {
                    Text(R.stringLocalizable.onboarding_all_set_title())
                        .font(.title2.bold())
                    Text(R.stringLocalizable.onboarding_all_set_message())
                        .font(.subheadline)
                }
                .foregroundStyle(Color(R.color.color111118))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                .padding(.top, 55)

                // Design: 84pt text block, button 144pt below it.
                PrimaryButton(R.stringLocalizable.onboarding_all_set_create_invoice()) {
                    createInvoice()
                }
                .padding(.horizontal, 16)
                .padding(.top, 168)

                Spacer(minLength: 16)
            }
        }
        .trackScreen(.allSet)
    }

    /// Land on Home, then push a fresh invoice editor on top of it.
    private func createInvoice() {
        coordinator.finishOnboarding()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            app.navi.push(.document(.editor(.invoice, id: nil)))
        }
    }
}

#if DEBUG
#Preview {
    AllSetView()
        .environmentObject(AppFlowCoordinator())
}
#endif
