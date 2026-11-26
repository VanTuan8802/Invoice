//
//  BusinessDetailsView.swift
//  Invoice
//
//  Onboarding/Business Details: business name, address and phone (all required).
//  Continue saves into `DataStore.business`; Skip moves on without saving.
//

import SwiftUI
import Factory

struct BusinessDetailsView: View {
    @EnvironmentObject private var coordinator: AppFlowCoordinator
    @StateObject private var viewModel: BusinessDetailsViewModel

    init() {
        let prefill = Container.shared.appFlow().didSaveBusinessDetails
        _viewModel = StateObject(wrappedValue: BusinessDetailsViewModel(prefill: prefill))
    }

    var body: some View {
        OnboardingStepScaffold(
            title: R.stringLocalizable.onboarding_business_title(),
            subtitle: R.stringLocalizable.onboarding_business_subtitle(),
            subtitleWidth: 270,
            isContinueEnabled: viewModel.canContinue,
            onBack: { coordinator.goBack() },
            onContinue: {
                viewModel.save()
                coordinator.businessDetailsDidFinish(saved: true)
            },
            onSkip: { coordinator.businessDetailsDidFinish(saved: false) }
        ) {
            VStack(alignment: .leading, spacing: 16) {
                LabeledInputField(
                    R.stringLocalizable.onboarding_business_name(),
                    isRequired: true,
                    text: $viewModel.name
                )
                LabeledInputField(
                    R.stringLocalizable.onboarding_business_address(),
                    isRequired: true,
                    text: $viewModel.address
                ) {
                    Image(R.image.ic_onboarding_search)
                }
                phoneField
            }
            .textInputAutocapitalization(.words)
        }
        .trackScreen(.businessDetails)
    }

    // MARK: - Phone

    /// Same look as `LabeledInputField`, with a region menu ("VN ⌄") and the
    /// dialing code ahead of the number.
    private var phoneField: some View {
        VStack(alignment: .leading, spacing: 0) {
            (Text(R.stringLocalizable.onboarding_business_phone()).foregroundColor(Color(R.color.color8E8E93))
             + Text(verbatim: "*").foregroundColor(Color(R.color.colorFA0000)))
                .font(.subheadline)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)

            HStack(spacing: 0) {
                regionMenu
                Text(viewModel.region.dialCode)
                    .font(.subheadline)
                    .foregroundStyle(Color(R.color.color151515))
                    .padding(.leading, 14)
                    .padding(.trailing, 8)
                TextField(
                    "",
                    text: $viewModel.phone,
                    prompt: Text(R.stringLocalizable.onboarding_business_phone_placeholder())
                        .foregroundColor(Color(R.color.colorC7C7CC))
                )
                .font(.subheadline)
                .foregroundStyle(Color(R.color.color151515))
                .keyboardType(.phonePad)
                .textContentType(.telephoneNumber)
            }
            .padding(.leading, 20)
            .padding(.trailing, 16)
            .frame(height: 48)
            .background(RoundedRectangle(cornerRadius: 24).fill(Color(R.color.colorFFFFFF)))
        }
    }

    private var regionMenu: some View {
        Menu {
            Picker(selection: $viewModel.region) {
                ForEach(PhoneRegion.all) { region in
                    Text(verbatim: "\(region.countryName) (\(region.dialCode))").tag(region)
                }
            } label: {
                EmptyView()
            }
        } label: {
            HStack(spacing: 0) {
                Text(viewModel.region.code)
                    .font(.subheadline)
                    .foregroundStyle(Color(R.color.colorA5A5B0))
                Image(R.image.ic_onboarding_chevron_down)
            }
            .contentShape(Rectangle())
        }
    }
}

#if DEBUG
#Preview {
    BusinessDetailsView()
        .environmentObject(AppFlowCoordinator())
}
#endif
