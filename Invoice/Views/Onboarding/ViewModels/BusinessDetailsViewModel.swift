//
//  BusinessDetailsViewModel.swift
//  Invoice
//
//  Draft for Onboarding/Business Details; written to `DataStore.business` on Continue.
//

import Foundation
import Combine
import Factory

@MainActor
final class BusinessDetailsViewModel: ObservableObject {
    @Published var name = ""
    @Published var address = ""
    @Published var phone = ""
    @Published var region: PhoneRegion

    @Injected(\.dataStore) private var store: DataStore

    /// - Parameter prefill: load the saved profile (when coming back to this step).
    init(prefill: Bool) {
        region = PhoneRegion.region(for: nil)
        guard prefill else { return }
        let business = store.business
        name = business.name
        address = business.address
        phone = business.phone
        region = PhoneRegion.region(for: business.phoneRegion)
    }

    /// All three fields are required (red asterisks in the design).
    var canContinue: Bool {
        [name, address, phone].allSatisfy { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    func save() {
        var business = store.business
        business.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        business.address = address.trimmingCharacters(in: .whitespacesAndNewlines)
        business.phone = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        business.phoneRegion = region.code
        store.business = business
    }
}
