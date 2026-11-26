//
//  Container+Navigation.swift
//  Invoice
//
//  Created by VanTuan on 18/6/26.
//

import Foundation
import Factory

// MARK: - App state

extension Container {
    var app: Factory<AppManager> {
        Factory(self) { @MainActor in AppManager() }.singleton
    }

    /// Owns the launch-flow phase (splash → language → intro → home). One shared
    /// instance: `ContainerView` observes it, view models drive it.
    var appFlow: Factory<AppFlowCoordinator> {
        Factory(self) { @MainActor in AppFlowCoordinator() }.singleton
    }
}

// MARK: - Navigation (single stack rooted at Home)

extension Container {
    var homeNavi: Factory<Navigation> {
        Factory(self) { @MainActor in Navigation() }.singleton
    }
}

// MARK: - Data

extension Container {
    /// In-memory invoices, estimates, clients, items and business profile.
    var dataStore: Factory<DataStore> {
        Factory(self) { @MainActor in
            #if DEBUG
            DataStore(seeded: !UIPreview.isEmptyData)
            #else
            DataStore()
            #endif
        }.singleton
    }

    /// The invoice/estimate currently being edited (shared by the editor and its field screens).
    var documentEditor: Factory<DocumentEditor> {
        Factory(self) { @MainActor in DocumentEditor(store: self.dataStore()) }.singleton
    }
}
