//
//  ClientFormView.swift
//  Invoice
//
//  The client form shared by Client/Info ("Done") and Client/Edit ("Save"):
//  contact card (name, email, mobile, phone, fax), address card, and the
//  "Import from contact" button. Leaving with unsaved changes asks first
//  (Client/Edit/Discard Dialog).
//

import SwiftUI
import Factory

struct ClientFormScreen: View {
    /// Already-localized toolbar action ("Done" / "Save").
    let confirmTitle: String
    let screen: AnalyticsScreen

    @StateObject private var viewModel: ClientFormViewModel
    @Injected(\.app) private var app

    init(clientID: UUID?, confirmTitle: String, screen: AnalyticsScreen) {
        self.confirmTitle = confirmTitle
        self.screen = screen
        _viewModel = StateObject(wrappedValue: ClientFormViewModel(clientID: clientID))
    }

    var body: some View {
        VStack(spacing: 0) {
            BasicHeaderView(R.stringLocalizable.client_title(), showBack: true, backAction: leave, trailingView: {
                HeaderTextButton(title: confirmTitle, action: confirm)
                    .disabled(!viewModel.canSave)
            })
            ClientFormView(viewModel: viewModel)
        }
        .groupedScreenBackground()
        .discardAlert(
            R.stringLocalizable.client_discard_title(),
            isPresented: $viewModel.isShowingDiscardAlert,
            keepTitle: R.stringLocalizable.common_keep_editing()
        ) {
            app.navi.pop()
        }
        .trackScreen(screen)
    }

    private func leave() {
        if viewModel.hasChanges {
            afterDismissingKeyboard { viewModel.isShowingDiscardAlert = true }
        } else {
            app.navi.pop()
        }
    }

    private func confirm() {
        if viewModel.hasChanges {
            viewModel.save()
        }
        app.navi.pop()
    }
}

/// The two cards + import button.
struct ClientFormView: View {
    @ObservedObject var viewModel: ClientFormViewModel

    var body: some View {
        Form {
            Section {
                ClientItemInputRow(
                    label: R.stringLocalizable.client_name(),
                    placeholder: R.stringLocalizable.client_name_placeholder(),
                    text: $viewModel.name,
                    contentType: .name
                )
                ClientItemInputRow(
                    label: R.stringLocalizable.client_email(),
                    placeholder: R.stringLocalizable.client_email_placeholder(),
                    text: $viewModel.email,
                    keyboard: .emailAddress,
                    contentType: .emailAddress
                )
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                ClientItemInputRow(
                    label: R.stringLocalizable.client_mobile(),
                    placeholder: R.stringLocalizable.client_mobile_placeholder(),
                    text: $viewModel.mobile,
                    keyboard: .phonePad,
                    contentType: .telephoneNumber
                )
                ClientItemInputRow(
                    label: R.stringLocalizable.client_phone(),
                    placeholder: R.stringLocalizable.client_phone_placeholder(),
                    text: $viewModel.phone,
                    keyboard: .phonePad,
                    contentType: .telephoneNumber
                )
                ClientItemInputRow(
                    label: R.stringLocalizable.client_fax(),
                    placeholder: R.stringLocalizable.client_fax_placeholder(),
                    text: $viewModel.fax,
                    keyboard: .phonePad
                )
            }

            Section {
                ForEach(viewModel.addressLines.indices, id: \.self) { index in
                    ClientItemPlainInputRow(
                        placeholder: R.stringLocalizable.client_address_line(index + 1),
                        text: $viewModel.addressLines[index],
                        contentType: index == 0 ? .fullStreetAddress : nil
                    )
                }
            }

            Section {
                PrimaryButton(R.stringLocalizable.client_import_contact()) {
                    viewModel.isShowingContactPicker = true
                }
                .padding(.top, 36)
                .padding(.bottom, 24) // room for the elevation shadow
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
        }
        .scrollContentBackground(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .clientItemSectionSpacing()
        .clientContactPicker(isPresented: $viewModel.isShowingContactPicker) { contact in
            viewModel.apply(contact)
        }
    }
}
