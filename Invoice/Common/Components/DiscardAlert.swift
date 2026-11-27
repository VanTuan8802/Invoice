//
//  DiscardAlert.swift
//  Invoice
//
//  The design's "leave without saving?" dialogs (Client/Edit, Item/Edit, line
//  item): red Discard on the left, the prominent blue keep action on the right.
//  Built on UIAlertController: a SwiftUI alert always puts a cancel-role button
//  on the left, and without one iOS 26 adds a third, system Cancel button.
//

import SwiftUI
import UIKit

extension View {
    /// Shows `title` with Discard (calls `onDiscard`) and `keepTitle` (closes
    /// the dialog, the preferred action).
    func discardAlert(
        _ title: String,
        isPresented: Binding<Bool>,
        keepTitle: String,
        onDiscard: @escaping () -> Void
    ) -> some View {
        background(
            DiscardAlertPresenter(title: title, keepTitle: keepTitle, isPresented: isPresented, onDiscard: onDiscard)
                .frame(width: 0, height: 0)
        )
    }
}

private struct DiscardAlertPresenter: UIViewControllerRepresentable {
    let title: String
    let keepTitle: String
    @Binding var isPresented: Bool
    let onDiscard: () -> Void

    func makeUIViewController(context: Context) -> UIViewController { UIViewController() }

    func updateUIViewController(_ host: UIViewController, context: Context) {
        guard isPresented, !context.coordinator.isShowing else { return }
        context.coordinator.isShowing = true

        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let discard = UIAlertAction(title: R.stringLocalizable.common_discard(), style: .destructive) { _ in
            context.coordinator.isShowing = false
            isPresented = false
            onDiscard()
        }
        let keep = UIAlertAction(title: keepTitle, style: .default) { _ in
            context.coordinator.isShowing = false
            isPresented = false
        }
        alert.addAction(discard)
        alert.addAction(keep)
        alert.preferredAction = keep

        // Present on the next run loop so it never collides with a SwiftUI update.
        DispatchQueue.main.async {
            guard host.view.window != nil else {
                context.coordinator.isShowing = false
                isPresented = false
                return
            }
            host.present(alert, animated: true)
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator {
        var isShowing = false
    }
}
