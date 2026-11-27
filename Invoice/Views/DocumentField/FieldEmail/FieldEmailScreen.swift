//
//  FieldEmailScreen.swift
//  Invoice
//
//  Invoice/Email (+ Email/Contacts, Email/Sent): compose the email for the open
//  invoice/estimate. "+" picks a recipient from the clients; "Send" shows the
//  "has been sent" toast, then goes back.
//

import SwiftUI
import Factory

struct FieldEmailScreen: View {
    @Injected(\.app) private var app
    @InjectedObject(\.documentEditor) private var editor: DocumentEditor
    @InjectedObject(\.dataStore) private var store: DataStore

    @State private var recipients = ""
    @State private var message = ""
    @State private var showsContacts = false
    @State private var isSent = false
    @State private var didPrefill = false

    private var isInvoice: Bool { editor.document.kind == .invoice }

    var body: some View {
        VStack(spacing: 0) {
            FieldHeader(
                title: isInvoice ? R.stringLocalizable.field_email_title_invoice()
                                 : R.stringLocalizable.field_email_title_estimate(),
                actionTitle: R.stringLocalizable.field_email_send(),
                onBack: { app.navi.pop() },
                onAction: send
            )

            ScrollView {
                VStack(spacing: 16) {
                    summaryCard
                    FieldTextArea(
                        placeholder: R.stringLocalizable.field_email_message(),
                        text: $message,
                        height: 174
                    )
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .groupedScreenBackground()
        .overlay(alignment: .bottom) {
            if isSent {
                FieldSentToast(
                    text: isInvoice ? R.stringLocalizable.field_email_sent_invoice()
                                    : R.stringLocalizable.field_email_sent_estimate()
                )
                // Design: 100pt above the screen's bottom edge (34pt home-indicator inset).
                .padding(.bottom, 66)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .sheet(isPresented: $showsContacts) {
            FieldContactsSheet(clients: store.clients) { client in
                addRecipient(client.email)
            }
        }
        .onAppear(perform: prefillRecipient)
        .onChange(of: editor.document.id) { _ in
            didPrefill = false
            prefillRecipient()
        }
        .trackScreen(.fieldEmail)
    }

    // MARK: - Card

    /// Purple "AAA #123  $0.00" header over the white "To  +" row.
    private var summaryCard: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Text(editor.document.number)
                    .lineLimit(1)
                Spacer(minLength: 8)
                Text(editor.document.total.currencyText(code: store.currencyCode))
            }
            .font(.body)
            .foregroundStyle(Color(R.color.color111118))
            .padding(16)
            .background(Color(R.color.colorCFC3FF))

            HStack(spacing: 8) {
                TextField("", text: $recipients,
                          prompt: Text(R.stringLocalizable.field_email_to()).foregroundColor(Color(R.color.colorA5A5B0)))
                    .font(.body)
                    .foregroundStyle(Color(R.color.color111118))
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                Button {
                    showsContacts = true
                } label: {
                    Image(R.image.ic_field_plus)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(R.stringLocalizable.field_email_add_recipient())
            }
            .padding(16)
        }
        .background(Color(R.color.colorFFFFFF))
        .clipShape(FieldCornerShape(top: 10, bottom: 24))
    }

    // MARK: - Actions

    private func prefillRecipient() {
        guard !didPrefill else { return }
        didPrefill = true
        if recipients.isEmpty, let email = editor.document.client?.email, !email.isEmpty {
            recipients = email
        }
    }

    private func addRecipient(_ email: String) {
        guard !email.isEmpty else { return }
        let existing = recipients
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        guard !existing.contains(email) else { return }
        recipients = (existing + [email]).joined(separator: ", ")
    }

    private func send() {
        guard !isSent else { return }
        guard !recipients.trimmingCharacters(in: .whitespaces).isEmpty else {
            showsContacts = true
            return
        }
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) { isSent = true }
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_600_000_000)
            app.navi.pop()
        }
    }
}

// MARK: - Sent toast (Invoice/Email/Sent)

/// Dark translucent capsule: white circle with the purple paper plane + footnote.
struct FieldSentToast: View {
    /// Already-localized text.
    let text: String

    var body: some View {
        HStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(Color(R.color.colorFFFFFF))
                    .frame(width: 32, height: 32)
                Image(R.image.ic_field_send)
            }
            .frame(width: 32, height: 24)

            Text(text)
                .font(.footnote)
                .foregroundStyle(Color(R.color.colorFFFFFF))
        }
        .padding(.leading, 6)
        .padding(.trailing, 16)
        .padding(.vertical, 10)
        .background(Capsule().fill(Color(R.color.color151515).opacity(0.5)))
        .accessibilityElement(children: .combine)
    }
}
