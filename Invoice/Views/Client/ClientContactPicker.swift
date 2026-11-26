//
//  ClientContactPicker.swift
//  Invoice
//
//  "Import from contact": presents the system `CNContactPickerViewController`.
//  The picker runs out of process, so no Contacts permission (and no
//  `NSContactsUsageDescription`) is needed. It must be presented modally by a
//  UIKit controller, so this representable is an invisible host that presents
//  it while `isPresented` is true.
//

import SwiftUI
import Contacts
import ContactsUI

struct ClientContactPicker: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let onSelect: (CNContact) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ host: UIViewController, context: Context) {
        let coordinator = context.coordinator
        coordinator.parent = self
        guard isPresented, !coordinator.isShowing else { return }
        coordinator.isShowing = true
        let picker = CNContactPickerViewController()
        picker.delegate = coordinator
        DispatchQueue.main.async {
            host.present(picker, animated: true)
        }
    }

    final class Coordinator: NSObject, CNContactPickerDelegate {
        var parent: ClientContactPicker
        /// Guards against presenting twice while SwiftUI re-runs `update`.
        var isShowing = false

        init(parent: ClientContactPicker) {
            self.parent = parent
        }

        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            isShowing = false
            parent.onSelect(contact)
            parent.isPresented = false
        }

        func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
            isShowing = false
            parent.isPresented = false
        }
    }
}

extension View {
    /// Shows the system contact picker while `isPresented` is true.
    func clientContactPicker(isPresented: Binding<Bool>, onSelect: @escaping (CNContact) -> Void) -> some View {
        background(
            ClientContactPicker(isPresented: isPresented, onSelect: onSelect)
                .frame(width: 0, height: 0)
                .accessibilityHidden(true)
        )
    }
}
