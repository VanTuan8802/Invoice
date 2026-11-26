//
//  TemplatePickerView.swift
//  Invoice
//
//  Onboarding/Template: 2×2 grid of invoice template thumbnails; the selected
//  one gets a 1pt ink border. The choice is kept in `OnboardingStore.templateID`.
//

import SwiftUI

struct TemplatePickerView: View {
    @EnvironmentObject private var coordinator: AppFlowCoordinator
    @State private var selection: Int?

    /// Thumbnails in template-ID order (same index as `Document.templateID`).
    static let thumbnails: [RswiftResources.ImageResource] = [
        R.image.img_onboarding_template_1,
        R.image.img_onboarding_template_2,
        R.image.img_onboarding_template_3,
        R.image.img_onboarding_template_4
    ]

    private let columns = [
        GridItem(.fixed(168), spacing: 14),
        GridItem(.fixed(168), spacing: 14)
    ]

    private var selected: Int { selection ?? coordinator.templateID }

    var body: some View {
        OnboardingStepScaffold(
            title: R.stringLocalizable.onboarding_template_title(),
            subtitle: R.stringLocalizable.onboarding_template_subtitle(),
            subtitleWidth: 292,
            onBack: { coordinator.goBack() },
            onContinue: { coordinator.templateDidFinish(templateID: selected) },
            onSkip: { coordinator.templateDidFinish(templateID: nil) }
        ) {
            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(Self.thumbnails.indices, id: \.self) { index in
                    thumbnail(index)
                }
            }
        }
        .trackScreen(.onboardingTemplate)
    }

    private func thumbnail(_ index: Int) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.15)) { selection = index }
        } label: {
            Image(Self.thumbnails[index])
                .resizable()
                .scaledToFill()
                .frame(width: 168, height: 234)
                .clipped()
                .overlay(
                    Rectangle()
                        .strokeBorder(Color(R.color.color111118), lineWidth: selected == index ? 1 : 0)
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
#Preview {
    TemplatePickerView()
        .environmentObject(AppFlowCoordinator())
}
#endif
