//
//  ClientItemComponents.swift
//  Invoice
//
//  Building blocks shared by the Client and Item screens: the illustrated empty
//  state, the grouped-form rows (label + trailing input, plain input, toggle,
//  multi-line notes) and number parsing for price / quantity / percentage fields.
//

import SwiftUI

// MARK: - Empty state

/// "You don't have any Client/Item": a 180pt tinted tile holding the 200pt
/// illustration, a Title 2 headline and a grey body message.
struct ClientItemEmptyState: View {
    let image: RswiftResources.ImageResource
    let tileColor: Color
    /// Already-localized texts.
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 24) {
            RoundedRectangle(cornerRadius: 56, style: .continuous)
                .fill(tileColor)
                .frame(width: 180, height: 180)
                .overlay {
                    Image(image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                }

            VStack(spacing: 12) {
                Text(title)
                    .font(.title2)
                    .foregroundStyle(Color(R.color.color111118))
                Text(message)
                    .font(.body)
                    .foregroundStyle(Color(R.color.color9A9AA6))
                    .frame(maxWidth: 270)
            }
            .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 32)
        // The design centers the block on the whole screen, not the area under
        // the toolbar: lift it by about half the toolbar's height.
        .padding(.bottom, 72)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Form rows

/// "Client Name:  Nam" — body label on the left, right-aligned subheadline input.
struct ClientItemInputRow: View {
    /// Already-localized label and placeholder.
    let label: String
    let placeholder: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default
    var contentType: UITextContentType?

    var body: some View {
        HStack(spacing: 12) {
            Text(label)
                .font(.body)
                .foregroundStyle(Color(R.color.color111118))
                .lineLimit(1)
                .layoutPriority(1)
            TextField("", text: $text, prompt: Text(placeholder).foregroundColor(Color(R.color.colorA5A5B0)))
                .font(.subheadline)
                .foregroundStyle(Color(R.color.color111118))
                .multilineTextAlignment(.trailing)
                .keyboardType(keyboard)
                .textContentType(contentType)
        }
    }
}

/// Full-width input that only shows its placeholder ("Product's Name", "Address 1").
struct ClientItemPlainInputRow: View {
    /// Already-localized placeholder.
    let placeholder: String
    @Binding var text: String
    var font: Font = .subheadline
    var contentType: UITextContentType?

    var body: some View {
        TextField("", text: $text, prompt: Text(placeholder).foregroundColor(Color(R.color.colorA5A5B0)))
            .font(font)
            .foregroundStyle(Color(R.color.color111118))
            .textContentType(contentType)
    }
}

/// "Taxable:" switch — ink track when on.
struct ClientItemToggleRow: View {
    /// Already-localized label.
    let label: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            Text(label)
                .font(.body)
                .foregroundStyle(Color(R.color.color111118))
        }
        .tint(Color(R.color.color111118))
    }
}

/// "Others" — multi-line notes filling a 112pt card.
struct ClientItemNotesRow: View {
    /// Already-localized placeholder.
    let placeholder: String
    @Binding var text: String

    var body: some View {
        TextField("", text: $text, prompt: Text(placeholder).foregroundColor(Color(R.color.colorA5A5B0)), axis: .vertical)
            .font(.body)
            .foregroundStyle(Color(R.color.color111118))
            .lineLimit(3...8)
            .frame(maxWidth: .infinity, minHeight: 80, alignment: .topLeading)
    }
}

// MARK: - Layout helpers

extension View {
    /// Grouped list/form spacing from the design: 8pt under the toolbar and 16pt
    /// between cards (iOS 17+; older systems keep the default metrics).
    @ViewBuilder
    func clientItemSectionSpacing() -> some View {
        if #available(iOS 17.0, *) {
            self
                .listSectionSpacing(16)
                .contentMargins(.top, 8, for: .scrollContent)
        } else {
            self
        }
    }
}

// MARK: - Text helpers

enum ClientItemText {
    /// "1 Invoice" / "3 Invoices"
    static func invoiceCount(_ count: Int) -> String {
        count == 1
            ? R.stringLocalizable.client_invoice_count_one(count)
            : R.stringLocalizable.client_invoice_count_other(count)
    }
}

// MARK: - Number input

/// Parses what the user typed in a price / quantity / percentage field.
enum ClientItemNumberInput {
    /// `fallback` when the field is empty, `nil` when the text is not a number.
    static func decimal(from text: String, fallback: Decimal) -> Decimal? {
        let allowed = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: ".,-"))
        let cleaned = String(text.unicodeScalars.filter { allowed.contains($0) })
        guard !cleaned.isEmpty else {
            return text.trimmingCharacters(in: .whitespaces).isEmpty ? fallback : nil
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = .current
        formatter.generatesDecimalNumbers = true
        if let number = formatter.number(from: cleaned) as? NSDecimalNumber {
            return number as Decimal
        }
        return Decimal(string: cleaned.replacingOccurrences(of: ",", with: "."))
    }

    /// Text shown when editing an existing value (empty for the default).
    static func text(for value: Decimal, hiding defaultValue: Decimal) -> String {
        value == defaultValue ? "" : value.plainText
    }
}
