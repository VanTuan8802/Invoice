//
//  OnboardingComponents.swift
//  Invoice
//
//  Building blocks shared by the onboarding steps (Business Details, Business
//  Logo, Template): toolbar with back + centered title, centered intro copy,
//  scrollable content and the Continue / Skip pair pinned to the bottom.
//

import SwiftUI

struct OnboardingStepScaffold<Content: View>: View {
    /// Already-localized texts.
    let title: String
    let subtitle: String
    /// Wrap width of the intro copy (the design sets it per screen).
    var subtitleWidth: CGFloat = 300
    var isContinueEnabled: Bool = true
    let onBack: () -> Void
    let onContinue: () -> Void
    let onSkip: () -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            // No trailing button here, so the title may use more width than
            // `BasicHeaderView`'s symmetric 88pt insets allow
            // ("Upload your business logo").
            BasicHeaderView("", showBack: true, backAction: onBack)
                .overlay(alignment: .top) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(Color(R.color.color111118))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .padding(.horizontal, 68)
                        .frame(height: 44)
                }
                .padding(.top, 2)

            ScrollView {
                VStack(spacing: 32) {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(Color(R.color.color111118))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: subtitleWidth)

                    content()
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .padding(.top, 4)
                .padding(.bottom, 24)
            }
            .scrollDismissesKeyboard(.interactively)

            VStack(spacing: 16) {
                PrimaryButton(R.stringLocalizable.continue(), action: onContinue)
                    .disabled(!isContinueEnabled)
                PrimaryButton(R.stringLocalizable.skip(), style: .outline, action: onSkip)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .groupedScreenBackground()
    }
}

/// Rectangle with only the top corners rounded (intro bottom sheet).
/// `UnevenRoundedRectangle` needs iOS 16.4; the app still deploys to 16.0.
struct TopRoundedRectangle: Shape {
    var radius: CGFloat

    func path(in rect: CGRect) -> Path {
        let r = min(radius, rect.width / 2, rect.height / 2)
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + r))
        path.addArc(center: CGPoint(x: rect.minX + r, y: rect.minY + r), radius: r,
                    startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        path.addLine(to: CGPoint(x: rect.maxX - r, y: rect.minY))
        path.addArc(center: CGPoint(x: rect.maxX - r, y: rect.minY + r), radius: r,
                    startAngle: .degrees(270), endAngle: .degrees(0), clockwise: false)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
