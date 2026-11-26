//
//  FieldTemplateScreen.swift
//  Invoice
//
//  Invoice/Template: 2-column grid of template previews; the selected one has an
//  ink border. Edits the open document's `templateID`, or — when opened from
//  Settings (`isDefault`) — the default template kept in `@AppStorage`.
//

import SwiftUI
import Factory

struct FieldTemplateScreen: View {
    /// `true` when opened from Settings: edits the default template for new documents.
    let isDefault: Bool

    /// Default template for new documents (read it with the same key elsewhere).
    static let defaultTemplateKey = "field_default_template_id"

    @Injected(\.app) private var app
    @InjectedObject(\.documentEditor) private var editor: DocumentEditor
    @AppStorage(FieldTemplateScreen.defaultTemplateKey) private var defaultTemplateID = 0

    private let templates: [RswiftResources.ImageResource] = [
        R.image.img_field_template_1,
        R.image.img_field_template_2,
        R.image.img_field_template_3,
        R.image.img_field_template_4
    ]

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    private var selection: Int {
        isDefault ? defaultTemplateID : editor.document.templateID
    }

    var body: some View {
        VStack(spacing: 0) {
            FieldHeader(
                title: R.stringLocalizable.field_template_title(),
                actionTitle: R.stringLocalizable.common_done(),
                onBack: { app.navi.pop() },
                onAction: { app.navi.pop() }
            )

            ScrollView {
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(templates.indices, id: \.self) { index in
                        templateCell(index)
                    }
                }
                .padding(.horizontal, 21)
                .padding(.top, 4)
                .padding(.bottom, 24)
            }
        }
        .groupedScreenBackground()
        .trackScreen(isDefault ? .fieldTemplateDefault : .fieldTemplate)
    }

    private func templateCell(_ index: Int) -> some View {
        Button {
            select(index)
        } label: {
            Color.clear
                .aspectRatio(168.0 / 234.0, contentMode: .fit)
                .overlay(
                    Image(templates[index])
                        .resizable()
                        .scaledToFill()
                )
                .clipped()
                .overlay(
                    Rectangle()
                        .strokeBorder(Color(R.color.color111118), lineWidth: selection == index ? 1 : 0)
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(R.stringLocalizable.field_template_item(index + 1))
        .accessibilityAddTraits(selection == index ? .isSelected : [])
    }

    private func select(_ index: Int) {
        if isDefault {
            defaultTemplateID = index
        } else {
            editor.document.templateID = index
        }
    }
}
