//
//  ClientFormViewModel.swift
//  Invoice
//
//  Draft state for Client/Info and Client/Edit: the editable fields, change
//  tracking for the discard alert, saving into `DataStore` and filling the
//  fields from a picked contact.
//

import Foundation
import Contacts
import Factory

@MainActor
final class ClientFormViewModel: ObservableObject {
    @Published var name: String
    @Published var email: String
    @Published var mobile: String
    @Published var phone: String
    @Published var fax: String
    /// Always three entries ("Address 1…3" rows).
    @Published var addressLines: [String]

    @Published var isShowingDiscardAlert = false
    @Published var isShowingContactPicker = false

    private let original: Client
    private let store: DataStore

    /// - Parameter clientID: the client to edit, or `nil` to create one.
    init(clientID: UUID?) {
        let store = Container.shared.dataStore()
        self.store = store

        let existing = clientID.flatMap { id in
            store.clients.first { $0.id == id }
                // A client that only lives on a document (e.g. from Reports).
                ?? (store.invoices + store.estimates).compactMap(\.client).first { $0.id == id }
        }
        var client = existing ?? Client(id: clientID ?? UUID(), name: "")
        client.addressLines = Self.threeLines(client.addressLines)
        original = client

        name = client.name
        email = client.email
        mobile = client.mobile
        phone = client.phone
        fax = client.fax
        addressLines = Self.threeLines(client.addressLines)
    }

    // MARK: State

    var canSave: Bool { !Self.trimmed(name).isEmpty }

    var hasChanges: Bool { draft != original }

    private var draft: Client {
        var client = original
        client.name = Self.trimmed(name)
        client.email = Self.trimmed(email)
        client.mobile = Self.trimmed(mobile)
        client.phone = Self.trimmed(phone)
        client.fax = Self.trimmed(fax)
        client.addressLines = Self.threeLines(addressLines.map(Self.trimmed))
        return client
    }

    // MARK: Actions

    /// Adds or updates the client in the store.
    func save() {
        guard canSave else { return }
        store.upsert(draft)
    }

    /// Replaces the fields with what the picked contact has.
    func apply(_ contact: CNContact) {
        let nameKeys = CNContactFormatter.descriptorForRequiredKeys(for: .fullName)
        if contact.areKeysAvailable([nameKeys]) {
            let fullName = CNContactFormatter.string(from: contact, style: .fullName) ?? ""
            let organization = contact.isKeyAvailable(CNContactOrganizationNameKey) ? contact.organizationName : ""
            name = fullName.isEmpty ? organization : fullName
        }

        if contact.isKeyAvailable(CNContactEmailAddressesKey) {
            email = contact.emailAddresses.first.map { $0.value as String } ?? ""
        }

        if contact.isKeyAvailable(CNContactPhoneNumbersKey) {
            var mobileNumber = "", phoneNumber = "", faxNumber = ""
            for entry in contact.phoneNumbers {
                let number = entry.value.stringValue
                switch entry.label {
                case CNLabelPhoneNumberMobile?, CNLabelPhoneNumberiPhone?:
                    if mobileNumber.isEmpty { mobileNumber = number }
                case CNLabelPhoneNumberHomeFax?, CNLabelPhoneNumberWorkFax?, CNLabelPhoneNumberOtherFax?:
                    if faxNumber.isEmpty { faxNumber = number }
                default:
                    if phoneNumber.isEmpty { phoneNumber = number }
                }
            }
            mobile = mobileNumber
            phone = phoneNumber
            fax = faxNumber
        }

        if contact.isKeyAvailable(CNContactPostalAddressesKey) {
            if let postal = contact.postalAddresses.first?.value {
                let formatted = CNPostalAddressFormatter.string(from: postal, style: .mailingAddress)
                let lines = formatted.split(whereSeparator: \.isNewline).map(String.init)
                // Keep the first two lines, fold the rest into the third.
                let folded = Array(lines.prefix(2)) + [lines.dropFirst(2).joined(separator: ", ")]
                addressLines = Self.threeLines(folded)
            } else {
                addressLines = Self.threeLines([])
            }
        }
    }

    // MARK: Helpers

    private static func trimmed(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func threeLines(_ lines: [String]) -> [String] {
        Array((lines + ["", "", ""]).prefix(3))
    }
}
