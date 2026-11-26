//
//  DocumentPreviewTab.swift
//  Invoice
//
//  "Preview" tab of the editor (Invoice/Preview, Estimate/Preview): the rendered
//  document on a white page and the "Template" button.
//

import SwiftUI
import Factory

struct DocumentPreviewTab: View {
    @InjectedObject(\.documentEditor) private var editor: DocumentEditor
    @InjectedObject(\.dataStore) private var store: DataStore
    @Injected(\.app) private var app

    var body: some View {
        ScrollView {
            DocumentPreviewView(document: editor.document, business: store.business, currencyCode: store.currencyCode)
                .background(Color(R.color.colorFFFFFF))
        }
        .safeAreaInset(edge: .bottom) {
            PrimaryButton(R.stringLocalizable.doc_template()) {
                app.navi.push(.documentField(.template(isDefault: false)))
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)
        }
        .trackScreen(.documentPreview)
    }
}
