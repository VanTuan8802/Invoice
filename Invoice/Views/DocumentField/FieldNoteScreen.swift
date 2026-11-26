//
//  FieldNoteScreen.swift
//  Invoice
//
//  Invoice/Note: free-text note printed on the document (`Document.note`).
//

import SwiftUI
import Factory

struct FieldNoteScreen: View {
    @Injected(\.app) private var app
    @InjectedObject(\.documentEditor) private var editor: DocumentEditor

    var body: some View {
        VStack(spacing: 0) {
            FieldHeader(
                title: R.stringLocalizable.field_note_title(),
                actionTitle: R.stringLocalizable.common_done(),
                onBack: { app.navi.pop() },
                onAction: { app.navi.pop() }
            )

            FieldTextArea(
                placeholder: R.stringLocalizable.field_note_placeholder(),
                text: $editor.document.note,
                height: 174
            )
            .padding(.horizontal, 16)
            .padding(.top, 4)

            Spacer(minLength: 0)
        }
        .groupedScreenBackground()
        .trackScreen(.fieldNote)
    }
}
