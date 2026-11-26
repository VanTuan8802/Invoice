//
//  UIPreview.swift
//  Invoice
//
//  DEBUG-only launch hooks for checking screens in the simulator without going
//  through splash / ads / onboarding:
//    -uiPreview <key>     open that route as the root screen (keys come from each
//                         route's `debugPreviews`, plus "home" and "language")
//    -uiPreviewEmpty      start with an empty `DataStore` (empty states)
//  e.g. `xcrun simctl launch <udid> com.vtn.Invoice -uiPreview document.list.invoice`
//

#if DEBUG
import Foundation
import Factory

enum UIPreview {
    private static var arguments: [String] { ProcessInfo.processInfo.arguments }

    /// The route requested with `-uiPreview <key>`, if any.
    static var destination: Destination? {
        guard let index = arguments.firstIndex(of: "-uiPreview"), index + 1 < arguments.count else { return nil }
        return Destination.debugPreview(arguments[index + 1])
    }

    static var isEmptyData: Bool { arguments.contains("-uiPreviewEmpty") }

    /// Puts the first sample invoice in the editor so field screens have data.
    @MainActor
    static func prepare() {
        let store = Container.shared.dataStore()
        Container.shared.documentEditor().begin(kind: .invoice, id: store.invoices.first?.id)
    }
}

extension Destination {
    static func debugPreview(_ key: String) -> Destination? {
        switch key {
        case "home":     return .home
        case "language": return .language
        default: break
        }
        if let route = PremiumRoute.debugPreviews[key]       { return .premium(route) }
        if let route = DocumentRoute.debugPreviews[key]      { return .document(route) }
        if let route = DocumentFieldRoute.debugPreviews[key] { return .documentField(route) }
        if let route = ClientRoute.debugPreviews[key]        { return .client(route) }
        if let route = ItemRoute.debugPreviews[key]          { return .item(route) }
        if let route = ReportsRoute.debugPreviews[key]       { return .reports(route) }
        if let route = SettingsRoute.debugPreviews[key]      { return .settings(route) }
        return nil
    }
}
#endif
