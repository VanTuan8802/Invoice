//
//  DocumentEditTab.swift
//  Invoice
//
//  "Edit" tab of the editor (Invoice/Edit + Scroll 1/2, Estimate/Edit). Rows open
//  the other features' screens; required info turns red once a send is attempted.
//

import SwiftUI
import Factory

struct DocumentEditTab: View {
    @ObservedObject var model: DocumentEditorViewModel
    /// Highlight missing business info / client / items in red.
    let showValidation: Bool
    let onSendReminder: () -> Void
    let onMarkPaid: () -> Void
    let onMakeInvoice: () -> Void

    @InjectedObject(\.documentEditor) private var editor: DocumentEditor
    @InjectedObject(\.dataStore) private var store: DataStore
    @Injected(\.app) private var app

    @State private var showPhotoOptions = false
    @State private var showDepositOptions = false

    private var document: Document { editor.document }
    private var isInvoice: Bool { document.kind == .invoice }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                content
            }
            .onAppear {
                #if DEBUG
                // `-uiPreviewScrollBottom`: check the lower cards against Invoice/Edit/Scroll 1.
                if ProcessInfo.processInfo.arguments.contains("-uiPreviewScrollBottom") {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        proxy.scrollTo(Self.bottomID, anchor: .bottom)
                    }
                }
                #endif
            }
        }
        .photoSourcePicker(isPresented: $showPhotoOptions) { data in
            let photo = DocumentPhoto(title: "", imageData: data)
            editor.document.photos.append(photo)
            app.navi.push(.document(.photoDetail(id: photo.id)))
        }
        .confirmationDialog(R.stringLocalizable.doc_deposit(), isPresented: $showDepositOptions, titleVisibility: .hidden) {
            ForEach(model.depositPresets, id: \.self) { percent in
                Button(percent == 0 ? R.stringLocalizable.doc_no_deposit() : percent.percentText) {
                    model.setDeposit(percent: percent)
                }
            }
            Button(R.stringLocalizable.common_cancel(), role: .cancel) {}
        }
        .trackScreen(.documentEdit)
    }

    private static let bottomID = "document.edit.bottom"

    private var content: some View {
        VStack(alignment: .leading, spacing: 16) {
            if isInvoice {
                dueCard
            }
            DocumentSection(title: document.kind.infoTitle) { infoCard }
            DocumentSection(title: R.stringLocalizable.doc_client_info()) { clientCard }
            DocumentSection(title: R.stringLocalizable.doc_item_info()) { itemsCard }
            DocumentSection(title: isInvoice ? R.stringLocalizable.doc_final_price_list() : nil) { priceCard }
            DocumentSection(title: R.stringLocalizable.doc_add_photo_header()) { photosCard }
            if isInvoice {
                linkRow(R.stringLocalizable.doc_payment_info(), isFilled: hasPaymentInfo) {
                    app.navi.push(.documentField(.paymentInfo))
                }
            }
            signatureRow
            noteRow
            if isInvoice {
                depositCard
                markPaidRow
            } else {
                makeInvoiceButton
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 1)
        .padding(.bottom, 96)
        .id(Self.bottomID)
    }

    // MARK: - Cards

    private var dueCard: some View {
        HStack(spacing: 8) {
            Text(document.dueStatusText)
                .font(.subheadline)
                .foregroundStyle(Color(R.color.color111118))
            Spacer(minLength: 8)
            if document.status != .paid {
                Button(action: onSendReminder) {
                    OutlinedChip(title: R.stringLocalizable.doc_send_reminder())
                }
                .buttonStyle(.plain)
            }
        }
        .documentCard()
    }

    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(document.number)
                    .font(.body)
                    .foregroundStyle(Color(R.color.color111118))
                Spacer(minLength: 8)
                if isInvoice {
                    OutlinedChip(title: document.terms.title)
                }
            }
            HStack {
                Button {
                    app.navi.push(.settings(.businessInfo))
                } label: {
                    Text(store.business.name.isEmpty ? R.stringLocalizable.doc_business_info() : store.business.name)
                        .foregroundStyle(placeholderColor(isFilled: !store.business.name.isEmpty,
                                                          isMissing: model.isBusinessMissing))
                        .lineLimit(1)
                }
                .buttonStyle(.plain)
                Spacer(minLength: 8)
                Text(document.issueDate.numericDateText)
                    .foregroundStyle(Color(R.color.color111118))
            }
            .font(.subheadline)
        }
        .documentCard()
        .onTapGesture { app.navi.push(.documentField(.info)) }
    }

    private var clientCard: some View {
        Button {
            app.navi.push(.client(.list(isPicker: true)))
        } label: {
            HStack {
                (Text(R.stringLocalizable.doc_to()).foregroundColor(Color(R.color.color151515))
                 + Text(document.client?.name ?? R.stringLocalizable.doc_client())
                    .foregroundColor(placeholderColor(isFilled: document.client != nil, isMissing: model.isClientMissing)))
                    .font(.body)
                    .lineLimit(1)
                Spacer(minLength: 8)
                DocumentChevron()
            }
            .documentCard()
        }
        .buttonStyle(.plain)
    }

    private var itemsCard: some View {
        VStack(spacing: 0) {
            VStack(spacing: 16) {
                ForEach(document.items) { item in
                    Button {
                        app.navi.push(.item(.lineItem(id: item.id)))
                    } label: {
                        itemRow(name: item.name,
                                quantityPrice: R.stringLocalizable.doc_quantity_price(item.quantity.plainText, money(item.price)),
                                amount: money(item.amount),
                                isPlaceholder: false)
                    }
                    .buttonStyle(.plain)
                    DocumentRowDivider()
                }
                Button {
                    app.navi.push(.item(.list(isPicker: true)))
                } label: {
                    if document.items.isEmpty {
                        itemRow(name: R.stringLocalizable.doc_add_item(),
                                quantityPrice: R.stringLocalizable.doc_quantity_price(Decimal(0).plainText, money(0)),
                                amount: money(0),
                                isPlaceholder: true)
                    } else {
                        HStack {
                            Text(R.stringLocalizable.doc_add_item())
                                .font(.body)
                                .foregroundStyle(Color(R.color.colorA5A5B0))
                            Spacer()
                            Image(systemName: "plus")
                                .font(.body)
                                .foregroundStyle(Color(R.color.color8E8E93))
                        }
                        .contentShape(Rectangle())
                    }
                }
                .buttonStyle(.plain)
            }
            .documentCard(corners: .top)

            DocumentTotalBar(title: R.stringLocalizable.doc_subtotal(), value: money(document.subtotal))
        }
    }

    private func itemRow(name: String, quantityPrice: String, amount: String, isPlaceholder: Bool) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(name)
                .font(.body)
                .foregroundStyle(isPlaceholder
                                 ? placeholderColor(isFilled: false, isMissing: model.isItemsMissing)
                                 : Color(R.color.color111118))
                .lineLimit(2)
            Spacer(minLength: 8)
            VStack(alignment: .trailing, spacing: 2) {
                Text(quantityPrice)
                    .foregroundStyle(Color(R.color.colorA5A5B0))
                Text(amount)
                    .foregroundStyle(isPlaceholder ? Color(R.color.colorA5A5B0) : Color(R.color.color111118))
            }
            .font(.subheadline)
        }
        .contentShape(Rectangle())
    }

    private var priceCard: some View {
        VStack(spacing: 0) {
            VStack(spacing: 16) {
                priceRow(R.stringLocalizable.doc_discount(), value: money(document.discountTotal)) {
                    app.navi.push(.documentField(.discount))
                }
                DocumentRowDivider()
                priceRow(taxTitle, value: money(document.taxTotal)) {
                    app.navi.push(.documentField(.tax))
                }
                DocumentRowDivider()
                priceRow(R.stringLocalizable.doc_total(), value: money(document.total), action: nil)
                if isInvoice {
                    DocumentRowDivider()
                    priceRow(R.stringLocalizable.doc_payments(), value: money(document.paidTotal)) {
                        app.navi.push(.documentField(.payments))
                    }
                }
            }
            .documentCard(corners: .top)

            DocumentTotalBar(title: R.stringLocalizable.doc_balance(), value: money(document.balance))
        }
    }

    private var taxTitle: String {
        guard document.tax.mode != .none, document.tax.ratePercent > 0 else { return R.stringLocalizable.doc_tax() }
        return R.stringLocalizable.doc_tax_rate(document.tax.ratePercent.percentText)
    }

    @ViewBuilder
    private func priceRow(_ title: String, value: String, action: (() -> Void)?) -> some View {
        let row = HStack {
            Text(title)
            Spacer(minLength: 8)
            Text(value)
        }
        .font(.body)
        .foregroundStyle(Color(R.color.color111118))
        .contentShape(Rectangle())

        if let action {
            Button(action: action) { row }.buttonStyle(.plain)
        } else {
            row
        }
    }

    private var photosCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(Array(document.photos.enumerated()), id: \.element.id) { index, photo in
                Button {
                    app.navi.push(.document(.photoDetail(id: photo.id)))
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(photo.title.isEmpty ? R.stringLocalizable.doc_photo_number(index + 1) : photo.title)
                        if !photo.detail.isEmpty {
                            Text(photo.detail)
                        }
                    }
                    .font(.body)
                    .foregroundStyle(Color(R.color.color111118))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                DocumentRowDivider()
            }
            Button {
                showPhotoOptions = true
            } label: {
                HStack {
                    Text(R.stringLocalizable.doc_add_photo())
                        .font(.subheadline)
                        .foregroundStyle(Color(R.color.colorA5A5B0))
                    Spacer()
                    Image(R.image.ic_document_image_add)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .documentCard()
    }

    private var signatureRow: some View {
        Button {
            app.navi.push(.document(.signature))
        } label: {
            HStack(spacing: 8) {
                Text(R.stringLocalizable.doc_signature())
                    .font(.subheadline)
                    .foregroundStyle(document.signatureImage == nil
                                     ? Color(R.color.colorA5A5B0)
                                     : Color(R.color.color111118))
                Spacer(minLength: 8)
                if let data = document.signatureImage, let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 24)
                }
                DocumentChevron()
            }
            .documentCard()
        }
        .buttonStyle(.plain)
    }

    private var noteRow: some View {
        Button {
            app.navi.push(.documentField(.note))
        } label: {
            HStack(spacing: 8) {
                Text(document.note.isEmpty ? R.stringLocalizable.doc_note() : document.note)
                    .font(.subheadline)
                    .foregroundStyle(document.note.isEmpty ? Color(R.color.colorA5A5B0) : Color(R.color.color111118))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 8)
                Image(R.image.ic_document_edit)
            }
            .documentCard()
        }
        .buttonStyle(.plain)
    }

    private var depositCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(R.stringLocalizable.doc_deposit())
                    .font(.body)
                    .foregroundStyle(Color(R.color.color111118))
                Text(R.stringLocalizable.doc_deposit_message())
                    .font(.subheadline)
                    .foregroundStyle(Color(R.color.color6B6B78))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Button {
                showDepositOptions = true
            } label: {
                HStack {
                    Text(R.stringLocalizable.doc_deposit_amount())
                    Spacer(minLength: 8)
                    Text(model.depositText(code: store.currencyCode))
                }
                .font(.body)
                .foregroundStyle(Color(R.color.color111118))
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .documentCard()
    }

    private var markPaidRow: some View {
        Button(action: onMarkPaid) {
            HStack(spacing: 8) {
                Text(document.status == .paid ? document.dueStatusText : R.stringLocalizable.doc_mark_paid())
                    .font(.subheadline)
                    .foregroundStyle(document.status == .paid ? Color(R.color.color111118) : Color(R.color.colorA5A5B0))
                Spacer(minLength: 8)
                DocumentChevron()
            }
            .documentCard()
        }
        .buttonStyle(.plain)
        .disabled(document.status == .paid)
    }

    private var makeInvoiceButton: some View {
        Button(action: onMakeInvoice) {
            Text(R.stringLocalizable.doc_make_invoice())
                .font(.subheadline)
                .foregroundStyle(Color(R.color.colorA5A5B0))
                .frame(maxWidth: .infinity)
                .documentCard()
        }
        .buttonStyle(.plain)
    }

    private func linkRow(_ title: String, isFilled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(isFilled ? Color(R.color.color111118) : Color(R.color.colorA5A5B0))
                Spacer(minLength: 8)
                DocumentChevron()
            }
            .documentCard()
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private var hasPaymentInfo: Bool {
        let info = document.paymentInstructions
        return !(info.paypalEmail.isEmpty && info.checkPayableTo.isEmpty && info.bankDetails.isEmpty && info.other.isEmpty)
    }

    private func money(_ value: Decimal) -> String {
        value.currencyText(code: store.currencyCode)
    }

    /// Placeholder grey, red when it is required and validation is showing, ink when filled.
    private func placeholderColor(isFilled: Bool, isMissing: Bool) -> Color {
        if isFilled { return Color(R.color.color111118) }
        return showValidation && isMissing ? Color(R.color.colorFA0000) : Color(R.color.colorA5A5B0)
    }
}
