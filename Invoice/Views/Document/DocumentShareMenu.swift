//
//  DocumentShareMenu.swift
//  Invoice
//
//  Invoice/Share: the send FAB expanded into "Text" / "Email" options over a dimmed
//  editor. Shown by `DocumentEditorScreen` (send button or the `.share` route).
//

import SwiftUI

struct DocumentShareMenu: View {
    let onText: () -> Void
    let onEmail: () -> Void
    let onClose: () -> Void

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture(perform: onClose)

            VStack(alignment: .trailing, spacing: 30) {
                option(R.stringLocalizable.doc_share_text(), icon: R.image.ic_document_chat, action: onText)
                option(R.stringLocalizable.doc_share_email(), icon: R.image.ic_document_mail_fast, action: onEmail)

                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color(R.color.colorFFFFFF))
                        .frame(width: 56, height: 56)
                        .background(Circle().fill(Color(R.color.color111118)))
                        .buttonElevation()
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
            }
            // Centre the close button on the send FAB it replaces (52pt, 16pt insets).
            .padding(.trailing, 14)
            .padding(.bottom, 14)
        }
        .trackScreen(.documentShare)
    }

    private func option(_ title: String, icon: RswiftResources.ImageResource, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 7) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(Color(R.color.color6A4DF5))
                    .padding(.leading, 10)
                    .padding(.trailing, 18)
                    .frame(height: 23)
                    .background(TagShape().fill(Color(R.color.colorFFFFFF)))
                Image(icon)
                    .frame(width: 48, height: 48)
                    .background(Circle().fill(Color(R.color.colorFFFFFF)))
                    .shadow(color: Color.black.opacity(0.12), radius: 2, x: 0, y: 4)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.trailing, 4)
    }
}
