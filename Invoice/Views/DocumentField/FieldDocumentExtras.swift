//
//  FieldDocumentExtras.swift
//  Invoice
//
//  Per-document values the field screens show but `Document` (Domain/Models.swift)
//  has no field for yet. Kept locally in UserDefaults, keyed by document id, until
//  the model grows them.
//

import Foundation

struct FieldDocumentExtras: Codable, Equatable {
    /// Terms "None" (no due date). `PaymentTerms` has no such case.
    var termsNone = false
    /// Tax "Inclusive": prices already include tax.
    var taxInclusive = false
    /// Recurring schedule: first and (optional) last invoice date.
    var recurringStart: Date?
    var recurringEnd: Date?
    /// Recurring delivery.
    var recurringSendsAutomatically = true
    var recurringEmail: String?

    private static func key(for documentID: UUID) -> String {
        "field_extras_\(documentID.uuidString)"
    }

    static func load(for documentID: UUID) -> FieldDocumentExtras {
        guard let data = UserDefaults.standard.data(forKey: key(for: documentID)),
              let extras = try? JSONDecoder().decode(FieldDocumentExtras.self, from: data) else {
            return FieldDocumentExtras()
        }
        return extras
    }

    func save(for documentID: UUID) {
        guard let data = try? JSONEncoder().encode(self) else { return }
        UserDefaults.standard.set(data, forKey: Self.key(for: documentID))
    }
}
