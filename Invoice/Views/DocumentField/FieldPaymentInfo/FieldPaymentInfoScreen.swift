//
//  FieldPaymentInfoScreen.swift
//  Invoice
//
//  Invoice/Payment Info: how the client can pay (PayPal, checks, instructions,
//  other) — `Document.paymentInstructions`.
//

import SwiftUI
import Factory

struct FieldPaymentInfoScreen: View {
    @Injected(\.app) private var app
    @InjectedObject(\.documentEditor) private var editor: DocumentEditor

    var body: some View {
        VStack(spacing: 0) {
            FieldHeader(
                title: R.stringLocalizable.field_payment_info_title(),
                actionTitle: R.stringLocalizable.common_done(),
                onBack: { app.navi.pop() },
                onAction: { app.navi.pop() }
            )

            ScrollView {
                VStack(spacing: 16) {
                    LabeledInputField(
                        R.stringLocalizable.field_paypal_email(),
                        placeholder: R.stringLocalizable.field_paypal_email_placeholder(),
                        text: $editor.document.paymentInstructions.paypalEmail,
                        keyboard: .emailAddress
                    )
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                    LabeledInputField(
                        R.stringLocalizable.field_check_payable(),
                        placeholder: R.stringLocalizable.field_check_payable_placeholder(),
                        text: $editor.document.paymentInstructions.checkPayableTo
                    )

                    LabeledInputField(
                        R.stringLocalizable.field_payment_instructions(),
                        placeholder: R.stringLocalizable.field_payment_instructions_placeholder(),
                        text: $editor.document.paymentInstructions.bankDetails
                    )

                    VStack(alignment: .leading, spacing: 0) {
                        // Same label style as `LabeledInputField`.
                        Text(R.stringLocalizable.field_method_other())
                            .font(.subheadline)
                            .foregroundStyle(Color(R.color.color8E8E93))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                        FieldTextArea(
                            placeholder: R.stringLocalizable.field_payment_other_placeholder(),
                            text: $editor.document.paymentInstructions.other,
                            height: 116
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)
                .padding(.bottom, 24)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .groupedScreenBackground()
        .trackScreen(.fieldPaymentInfo)
    }
}
