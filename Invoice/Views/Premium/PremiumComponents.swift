//
//  PremiumComponents.swift
//  Invoice
//
//  Shared pieces of Onboarding/Premium/Plans and /Success: where the paywall is
//  shown from, the plans on offer, the dark glow background, the gold gradient
//  and the paywall layout itself.
//

import SwiftUI

/// Where the paywall is shown — decides what Close / done do.
enum PremiumContext {
    /// Inside the launch flow (`AppPhase.premium`): close → All Set.
    case onboarding
    /// Presented through the router, e.g. from Settings with
    /// `app.navi.push(.premium(.plans), type: .fullScreenCover)`: close → dismiss.
    case modal
}

/// Plans on offer. Prices are placeholders until StoreKit products are wired in.
enum PremiumPlan: CaseIterable, Identifiable {
    case weekly
    case lifetime

    var id: Self { self }

    private var price: Decimal {
        switch self {
        case .weekly:   return Decimal(string: "4.99") ?? 0
        case .lifetime: return Decimal(string: "9.99") ?? 0
        }
    }

    /// Free-trial days shown above the price (weekly only).
    var trialDays: Int? { self == .weekly ? 3 : nil }

    var isMostPopular: Bool { self == .weekly }

    /// "$4.99 / Weekly", "$9.99 / Lifetime".
    @MainActor
    var title: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = DataStore.defaultCurrencyCode
        formatter.locale = Locale(identifier: "en_US")
        let amount = formatter.string(from: price as NSDecimalNumber) ?? ""
        switch self {
        case .weekly:   return R.stringLocalizable.premium_plan_weekly(amount)
        case .lifetime: return R.stringLocalizable.premium_plan_lifetime(amount)
        }
    }
}

extension LinearGradient {
    /// Gold #FFD966 → #F2A307, left to right (chips, radio, Continue).
    static var premiumGold: LinearGradient {
        LinearGradient(
            colors: [Color(R.color.colorFFD966), Color(R.color.colorF2A307)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

/// #0E0E14 with a blurred gold glow top-left and a purple one mid-right.
struct PremiumBackground: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color(R.color.color0E0E14)
            Circle()
                .fill(Color(R.color.colorF5B013).opacity(0.35))
                .frame(width: 420, height: 420)
                .blur(radius: 60)
                .offset(x: -14, y: -120)
            Circle()
                .fill(Color(R.color.color6A4DF5).opacity(0.35))
                .frame(width: 260, height: 260)
                .blur(radius: 50)
                .offset(x: 220, y: 180)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .clipped()
        .ignoresSafeArea()
    }
}

/// The paywall layout (illustration, brand, features, plans, Continue, links).
/// Stateless: the screen owns the selection and the actions.
struct PremiumPlansContent: View {
    @Binding var selection: PremiumPlan
    var onClose: () -> Void = {}
    var onContinue: () -> Void = {}
    var onRestore: () -> Void = {}
    var onTerms: () -> Void = {}
    var onPrivacy: () -> Void = {}

    var body: some View {
        ViewThatFits(in: .vertical) {
            layout
            ScrollView(showsIndicators: false) { layout }
        }
        .overlay(alignment: .topLeading) { closeButton }
        .background(PremiumBackground())
    }

    private var layout: some View {
        VStack(spacing: 0) {
            Image(R.image.illus_premium)
                .resizable()
                .scaledToFit()
                .frame(width: 250, height: 250)
                .padding(.top, 8)

            brand
                .padding(.top, -2)

            features
                .padding(.top, 22)

            VStack(spacing: 12) {
                ForEach(PremiumPlan.allCases) { plan in
                    planCard(plan)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)

            Spacer(minLength: 24)

            continueButton
                .padding(.horizontal, 16)

            secured
                .padding(.top, 16)

            links
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 4)
        }
    }

    // MARK: Header

    private var closeButton: some View {
        Button(action: onClose) {
            Image(R.image.ic_premium_close)
                .frame(width: 40, height: 40)
                .background(Circle().fill(Color(R.color.colorFFFFFF).opacity(0.12)))
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .padding(.leading, 16)
        .padding(.top, -6)
    }

    private var brand: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(R.image.ic_premium_crown)
                    .frame(width: 26, height: 26)
                Text(R.stringLocalizable.onboarding_app_name())
                    .font(.largeTitle.bold())
                    .foregroundStyle(Color(R.color.colorFFFFFF))
            }
            Text(R.stringLocalizable.premium_badge())
                .font(.system(size: 11, weight: .heavy))
                .tracking(0.88)
                .foregroundStyle(Color(R.color.color111118))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Capsule().fill(LinearGradient.premiumGold))
        }
    }

    private var features: some View {
        VStack(alignment: .leading, spacing: 12) {
            feature(R.stringLocalizable.premium_feature_remove_ads())
            feature(R.stringLocalizable.premium_feature_unlock_all())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 56)
    }

    private func feature(_ text: String) -> some View {
        HStack(spacing: 12) {
            Image(R.image.ic_premium_check)
                .frame(width: 24, height: 24)
                .background(Circle().fill(LinearGradient.premiumGold))
            Text(text)
                .font(.body.weight(.semibold))
                .foregroundStyle(Color(R.color.colorFFFFFF))
        }
    }

    // MARK: Plans

    private func planCard(_ plan: PremiumPlan) -> some View {
        let isSelected = plan == selection
        return Button {
            withAnimation(.easeInOut(duration: 0.15)) { selection = plan }
        } label: {
            HStack(spacing: 12) {
                radio(isSelected)
                VStack(alignment: .leading, spacing: 2) {
                    if let days = plan.trialDays {
                        Text(R.stringLocalizable.premium_plan_trial(days))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color(R.color.colorFFFFFF).opacity(0.6))
                    }
                    Text(plan.title)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color(R.color.colorFFFFFF))
                }
                Spacer(minLength: 0)
                if plan.isMostPopular {
                    Text(R.stringLocalizable.premium_most_popular())
                        .font(.system(size: 10, weight: .heavy))
                        .tracking(0.4)
                        .foregroundStyle(Color(R.color.color111118))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(LinearGradient.premiumGold))
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color(R.color.colorFFFFFF).opacity(isSelected ? 0.1 : 0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(
                        isSelected ? Color(R.color.colorFFD966) : Color(R.color.colorFFFFFF).opacity(0.15),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func radio(_ isSelected: Bool) -> some View {
        if isSelected {
            Image(R.image.ic_premium_check_small)
                .frame(width: 22, height: 22)
                .background(Circle().fill(LinearGradient.premiumGold))
        } else {
            Circle()
                .strokeBorder(Color(R.color.colorFFFFFF).opacity(0.4), lineWidth: 1.5)
                .frame(width: 22, height: 22)
        }
    }

    // MARK: Footer

    private var continueButton: some View {
        Button(action: onContinue) {
            Text(R.stringLocalizable.continue())
                .font(.body.weight(.semibold))
                .foregroundStyle(Color(R.color.color111118))
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    Capsule()
                        .fill(LinearGradient.premiumGold)
                        .shadow(color: Color(R.color.colorF2A307).opacity(0.35), radius: 6, x: 0, y: 10)
                )
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private var secured: some View {
        HStack(spacing: 6) {
            Image(R.image.ic_premium_shield)
                .frame(width: 14, height: 14)
            Text(R.stringLocalizable.premium_secured())
                .font(.caption)
                .foregroundStyle(Color(R.color.color8E8E9A))
        }
    }

    private var links: some View {
        HStack {
            Button(action: onTerms) {
                Text(R.stringLocalizable.premium_terms())
                    .foregroundStyle(Color(R.color.color8E8E9A))
            }
            Spacer(minLength: 8)
            Button(action: onRestore) {
                HStack(spacing: 4) {
                    Image(R.image.ic_premium_restore)
                        .frame(width: 14, height: 14)
                    Text(R.stringLocalizable.premium_restore())
                        .foregroundStyle(Color(R.color.colorFFC233))
                }
            }
            Spacer(minLength: 8)
            Button(action: onPrivacy) {
                Text(R.stringLocalizable.privacy_policy())
                    .foregroundStyle(Color(R.color.color8E8E9A))
            }
        }
        .font(.caption.weight(.semibold))
        .buttonStyle(.plain)
        .frame(height: 20)
    }
}
