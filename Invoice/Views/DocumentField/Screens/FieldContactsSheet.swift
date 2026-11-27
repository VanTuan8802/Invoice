//
//  FieldContactsSheet.swift
//  Invoice
//
//  Invoice/Email/Contacts: sheet listing the clients with a search field;
//  tapping one adds them as a recipient.
//

import SwiftUI

struct FieldContactsSheet: View {
    let clients: [Client]
    let onSelect: (Client) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var query = ""

    private var filtered: [Client] {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return clients }
        return clients.filter {
            $0.name.localizedCaseInsensitiveContains(trimmed) || $0.email.localizedCaseInsensitiveContains(trimmed)
        }
    }

    var body: some View {
        VStack(spacing: 24) {
            searchField
                .padding(.top, 24)

            if filtered.isEmpty {
                Text(R.stringLocalizable.field_email_no_contacts())
                    .font(.subheadline)
                    .foregroundStyle(Color(R.color.color8E8E93))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(.top, 24)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(filtered) { client in
                            contactRow(client)
                        }
                    }
                    .padding(.bottom, 24)
                }
                .scrollDismissesKeyboard(.interactively)
            }
        }
        .padding(.horizontal, 16)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color(R.color.colorF4F4F6).ignoresSafeArea())
        .presentationDetents([.large])
        .modifier(SheetCornerRadius())
        .trackScreen(.fieldEmailContacts)
    }

    /// White-50% capsule with a hairline border and a 24pt search glyph.
    private var searchField: some View {
        HStack(spacing: 8) {
            Image(R.image.ic_field_search)
            TextField("", text: $query,
                      prompt: Text(R.stringLocalizable.field_email_search()).foregroundColor(Color(R.color.color6B6B78)))
                .font(.body)
                .foregroundStyle(Color(R.color.color111118))
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Capsule().fill(Color(R.color.colorFFFFFF).opacity(0.5)))
        .overlay(Capsule().strokeBorder(Color(R.color.colorDADAE0), lineWidth: 1))
    }

    private func contactRow(_ client: Client) -> some View {
        Button {
            onSelect(client)
            dismiss()
        } label: {
            Text(client.name)
                .font(.body)
                .foregroundStyle(Color(R.color.color111118))
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color(R.color.colorFFFFFF))
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

/// The design's sheet has 16pt top corners (`presentationCornerRadius` is iOS 16.4+).
private struct SheetCornerRadius: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.4, *) {
            content.presentationCornerRadius(16)
        } else {
            content
        }
    }
}
