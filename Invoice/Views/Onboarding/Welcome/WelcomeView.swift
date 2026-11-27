//
//  WelcomeView.swift
//  Invoice
//
//  Onboarding/Welcome: "Welcome back", lavender hero block with the welcome
//  illustration, and Get Started.
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject private var coordinator: AppFlowCoordinator

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)

            VStack(spacing: 0) {
                Text(R.stringLocalizable.onboarding_welcome_title())
                    .font(.title.bold())
                    .foregroundStyle(Color(R.color.color111118))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)

                hero
                    .padding(.top, 7)

                PrimaryButton(R.stringLocalizable.get_started()) {
                    coordinator.welcomeDidFinish()
                }
                .padding(.horizontal, 16)
                .padding(.top, 107)
            }

            Spacer(minLength: 0)
        }
        // Centered on the whole screen like the design, not the safe area.
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .background(Color(R.color.colorF4F4F6).ignoresSafeArea())
        .trackScreen(.welcome)
    }

    /// 361×300 lavender block: soft white disc behind the shared welcome
    /// illustration (drawn ~270pt, centered slightly below the middle).
    private var hero: some View {
        ZStack {
            Circle()
                .fill(Color(R.color.colorFFFFFF).opacity(0.22))
                .frame(width: 325, height: 325)
            Image(R.image.illus_welcome)
                .resizable()
                .scaledToFit()
                .frame(width: 270, height: 270)
                .offset(y: 8)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 300)
        .background(Color(R.color.colorB4A5FF))
        .clipShape(RoundedRectangle(cornerRadius: 36, style: .continuous))
        .padding(.horizontal, 16)
    }
}

#if DEBUG
#Preview {
    WelcomeView()
        .environmentObject(AppFlowCoordinator())
}
#endif
