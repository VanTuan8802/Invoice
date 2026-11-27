//
//  DocumentPreviewView.swift
//  Invoice
//
//  The printed invoice / estimate (Invoice/Preview, Estimate/Preview) rendered from
//  the model. Also used to print. Fixed point sizes on purpose: it mirrors a paper
//  page. The design's Urbanist face is not bundled, so the system font is used.
//

import SwiftUI

struct DocumentPreviewView: View {
    let document: Document
    let business: BusinessProfile
    let currencyCode: String

    private let ink = Color(R.color.color111118)
    private let muted = Color(R.color.color6B6B78)

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            rule
            billTo
            rule
            itemsTable
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 9) {
                    paymentInfo
                    note
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                VStack(alignment: .leading, spacing: 24) {
                    totals
                    signature
                }
                .frame(width: 172.5)
            }
            photos
        }
        .foregroundStyle(ink)
        .padding(16)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .top, spacing: 8) {
            HStack(alignment: .top, spacing: 10) {
                logo
                VStack(alignment: .leading, spacing: 6) {
                    Text(business.name)
                        .font(.system(size: 13, weight: .semibold))
                    VStack(alignment: .leading, spacing: 2) {
                        iconLine(R.image.ic_document_location, business.address)
                        iconLine(R.image.ic_document_mobile, business.phone)
                        plainLine(business.website)
                        plainLine(business.email)
                    }
                    .font(.system(size: 9, weight: .medium))
                }
            }
            Spacer(minLength: 8)
            VStack(alignment: .trailing, spacing: 2) {
                headerPair(document.kind.previewHeading, document.number)
                headerPair(R.stringLocalizable.doc_preview_date(), document.issueDate.numericDateText)
                headerPair(R.stringLocalizable.doc_preview_due(), dueText)
                headerPair(R.stringLocalizable.doc_preview_balance_due(),
                           R.stringLocalizable.doc_preview_currency_amount(currencyCode, money(document.balance)))
            }
            .multilineTextAlignment(.trailing)
        }
    }

    @ViewBuilder
    private var logo: some View {
        if let data = business.logoData, let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 82, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        } else {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(R.color.colorD9D9D9))
                .frame(width: 82, height: 100)
        }
    }

    private var dueText: String {
        document.terms == .dueOnReceipt
            ? R.stringLocalizable.doc_preview_on_receipt()
            : document.dueDate.numericDateText
    }

    private func headerPair(_ title: String, _ value: String) -> some View {
        VStack(alignment: .trailing, spacing: 0) {
            Text(title).font(.system(size: 9, weight: .semibold))
            Text(value).font(.system(size: 9, weight: .medium)).foregroundStyle(muted)
        }
    }

    // MARK: - Bill to

    private var billTo: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(R.stringLocalizable.doc_preview_bill_to())
                .font(.system(size: 11, weight: .bold))
            VStack(alignment: .leading, spacing: 2) {
                Text(document.clientDisplayName)
                    .font(.system(size: 13, weight: .semibold))
                if let client = document.client {
                    Group {
                        iconLine(R.image.ic_document_location, client.address)
                        iconLine(R.image.ic_document_mobile, client.mobile)
                        iconLine(R.image.ic_document_work, client.phone)
                        plainLine(client.email)
                    }
                    .font(.system(size: 9, weight: .medium))
                }
            }
        }
    }

    // MARK: - Items

    private var itemsTable: some View {
        VStack(alignment: .leading, spacing: 17) {
            itemColumns(
                Text(R.stringLocalizable.doc_preview_description()),
                Text(R.stringLocalizable.doc_preview_price()),
                Text(R.stringLocalizable.doc_preview_qty()),
                Text(R.stringLocalizable.doc_preview_discount()),
                Text(R.stringLocalizable.doc_preview_amount())
            )
            .font(.system(size: 11, weight: .bold))
            dashedRule
            ForEach(document.items) { item in
                itemColumns(
                    Text(item.name),
                    Text(money(item.price)),
                    Text(item.quantity.plainText),
                    discountText(item),
                    Text(money(item.amount))
                )
                .font(.system(size: 10, weight: .semibold))
                dashedRule
            }
        }
    }

    private func itemColumns(_ name: Text, _ price: Text, _ quantity: Text, _ discount: Text, _ amount: Text) -> some View {
        HStack(alignment: .top, spacing: 0) {
            name.frame(maxWidth: .infinity, alignment: .leading)
            price.frame(width: 58, alignment: .leading)
            quantity.frame(width: 34, alignment: .center)
            discount.frame(width: 82, alignment: .center)
            amount.frame(width: 52, alignment: .trailing)
        }
        .lineLimit(2)
        .minimumScaleFactor(0.8)
    }

    private func discountText(_ item: LineItem) -> Text {
        guard item.discountPercent > 0, document.discount.mode == .perItem else { return Text(money(0)) }
        return Text(money(-item.discountAmount))
            + Text(R.stringLocalizable.doc_preview_percent_suffix(item.discountPercent.percentText))
                .foregroundColor(Color(R.color.color8E8E93))
    }

    // MARK: - Payment info & note

    @ViewBuilder
    private var paymentInfo: some View {
        let info = document.paymentInstructions
        if !(info.paypalEmail.isEmpty && info.other.isEmpty && info.checkPayableTo.isEmpty && info.bankDetails.isEmpty) {
            Text(R.stringLocalizable.doc_preview_payment_info())
                .font(.system(size: 11, weight: .bold))
        }
        if !info.paypalEmail.isEmpty {
            infoBlock(R.stringLocalizable.doc_preview_paypal(), info.paypalEmail)
        }
        if !info.other.isEmpty {
            infoBlock(R.stringLocalizable.doc_preview_payment_instructions(), info.other)
        }
        if !info.checkPayableTo.isEmpty {
            infoBlock(R.stringLocalizable.doc_preview_by_check(), info.checkPayableTo)
        }
        if !info.bankDetails.isEmpty {
            infoBlock(R.stringLocalizable.doc_preview_bank_transfer(), info.bankDetails)
        }
    }

    @ViewBuilder
    private var note: some View {
        if !document.note.isEmpty {
            VStack(alignment: .leading, spacing: 2) {
                Text(R.stringLocalizable.doc_note())
                    .font(.system(size: 11, weight: .bold))
                Text(document.note)
                    .font(.system(size: 11, weight: .medium))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func infoBlock(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.system(size: 11, weight: .bold))
            Text(value).font(.system(size: 9, weight: .medium))
        }
    }

    // MARK: - Totals & signature

    private var totals: some View {
        VStack(alignment: .leading, spacing: 9) {
            totalRow(R.stringLocalizable.doc_preview_subtotal(), money(document.subtotal))
            if document.discountTotal > 0 {
                totalRow(discountTitle, money(-document.discountTotal))
            }
            if document.tax.mode != .none {
                totalRow(taxTitle, money(document.taxTotal))
            }
            rule
            totalRow(R.stringLocalizable.doc_preview_total(), money(document.total))
            if document.paidTotal > 0 {
                HStack(alignment: .top) {
                    Text(R.stringLocalizable.doc_preview_paid()).font(.system(size: 11, weight: .bold))
                    Spacer(minLength: 8)
                    VStack(alignment: .trailing, spacing: 0) {
                        Text(money(-document.paidTotal))
                        if let date = document.payments.map(\.date).max() {
                            Text(date.formatted(Date.FormatStyle(date: .long, time: .omitted).locale(.app))).foregroundStyle(muted)
                        }
                    }
                    .font(.system(size: 9, weight: .medium))
                }
            }
            rule
            HStack {
                Text(R.stringLocalizable.doc_preview_balance_due()).font(.system(size: 11, weight: .bold))
                Spacer(minLength: 8)
                Text(money(document.balance)).font(.system(size: 11, weight: .semibold))
            }
        }
    }

    private var discountTitle: String {
        let title = R.stringLocalizable.doc_preview_discount()
        guard document.discount.mode == .onTotal, document.discount.isPercentage else { return title }
        return R.stringLocalizable.doc_preview_rate(title, document.discount.value.percentText)
    }

    private var taxTitle: String {
        let label = document.tax.label.isEmpty
            ? R.stringLocalizable.doc_preview_tax()
            : document.tax.label.uppercased()
        return R.stringLocalizable.doc_preview_rate(label, document.tax.ratePercent.percentText)
    }

    private func totalRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title).font(.system(size: 11, weight: .bold))
            Spacer(minLength: 8)
            Text(value).font(.system(size: 9, weight: .medium))
        }
    }

    @ViewBuilder
    private var signature: some View {
        if let data = document.signatureImage, let image = UIImage(data: data) {
            VStack(alignment: .leading, spacing: 8) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 123, height: 38, alignment: .leading)
                VStack(alignment: .leading, spacing: 0) {
                    Text(R.stringLocalizable.doc_preview_date_signed()).font(.system(size: 11, weight: .bold))
                    Text((document.signedDate ?? Date()).numericDateText).font(.system(size: 9, weight: .medium))
                }
            }
        }
    }

    // MARK: - Photos

    @ViewBuilder
    private var photos: some View {
        if !document.photos.isEmpty {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16, alignment: .top), count: 3),
                      alignment: .leading, spacing: 16) {
                ForEach(document.photos) { photo in
                    VStack(spacing: 8) {
                        photoImage(photo)
                        VStack(spacing: 4) {
                            Text(photo.title).font(.system(size: 11, weight: .bold))
                            Text(photo.detail).font(.system(size: 9, weight: .medium))
                        }
                        .multilineTextAlignment(.center)
                    }
                }
            }
            .padding(.top, 8)
        }
    }

    private func photoImage(_ photo: DocumentPhoto) -> some View {
        Color(R.color.colorD9D9D9)
            .frame(height: 143.75)
            .overlay {
                if let data = photo.imageData, let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                }
            }
            .clipped()
    }

    // MARK: - Pieces

    private var rule: some View {
        Rectangle()
            .fill(Color(R.color.colorE8E8EE))
            .frame(height: 0.5)
    }

    private var dashedRule: some View {
        DashedLine()
            .stroke(Color(R.color.color8E8E93), style: StrokeStyle(lineWidth: 0.5, dash: [1.5, 3]))
            .frame(height: 0.5)
    }

    @ViewBuilder
    private func iconLine(_ icon: RswiftResources.ImageResource, _ text: String) -> some View {
        if !text.isEmpty {
            HStack(spacing: 4) {
                Image(icon).resizable().frame(width: 9, height: 9)
                Text(text)
            }
        }
    }

    @ViewBuilder
    private func plainLine(_ text: String) -> some View {
        if !text.isEmpty {
            Text(text)
        }
    }

    private func money(_ value: Decimal) -> String {
        value.currencyText(code: currencyCode)
    }
}
