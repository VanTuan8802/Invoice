//
//  AppManager.swift
//  Invoice
//
//  Created by VanTuan on 18/6/26.
//

import Foundation
import Combine
import Factory

@MainActor
final class AppManager: ObservableObject {
    /// The app's navigation tree (one stack rooted at Home).
    @Published var navi: Navigation = Container.shared.homeNavi()

    /// Whether the app is currently backgrounded.
    @Published var isInBackground: Bool = false
}
