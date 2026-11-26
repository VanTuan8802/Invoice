//
//  FieldComponents.swift
//  Invoice
//
//  Building blocks shared by the document field screens (Info, Discount, Tax,
//  Payment, Note…): the toolbar, the label/value rows of the design's white
//  cards, the rounded text area and the list styling.
//

import SwiftUI

// MARK: - Toolbar

/// The design's "Toolbar": glass back chevron, centered title, blue prominent
/// pill ("Done" / "Save" / "Send") on the trailing side.
struct FieldHeader: View {
    /// Already-localized texts.
    let title: String
    let actionTitle: String
    let onBack: () -> Void
    let onAction: () -> Void

    var body: some View {
        BasicHeaderView(title, showBack: true, backAction: onBack) {
            HeaderTextButton(title: actionTitle, action: onAction)
        }
    }
}

// MARK: - Rows (used inside an inset-grouped `List` section)

/// "Label:  value" row: Body ink label on the leading side, any value view trailing.
struct FieldRow<Value: View>: View {
    let title: String
    @ViewBuilder var value: () -> Value

    var body: some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.body)
                .foregroundStyle(Color(R.color.color111118))
                .lineLimit(1)
                .layoutPriority(1)
            Spacer(minLength: 8)
            value()
        }
        .frame(minHeight: 22)
    }
}

/// Row whose trailing value is a right-aligned text field. The grey placeholder
/// uses Subheadline like the design; typed text is Body ink.
struct FieldTextRow: View {
    let title: String
    var placeholder: String = ""
    @Binding var text: String
    var keyboard: UIKeyboardType = .default

    var body: some View {
        FieldRow(title: title) {
            TextField("", text: $text, prompt: Text(placeholder).foregroundColor(Color(R.color.colorA5A5B0)))
                .font(text.isEmpty ? .subheadline : .body)
                .foregroundStyle(Color(R.color.color111118))
                .multilineTextAlignment(.trailing)
                .keyboardType(keyboard)
        }
    }
}

/// Row with a decimal input: a currency amount ("$0.00" placeholder) or a percentage ("0%").
struct FieldAmountRow: View {
    enum Kind: Equatable {
        case currency(code: String)
        case percent
    }

    let title: String
    @Binding var value: Decimal
    let kind: Kind

    @State private var text = ""

    var body: some View {
        FieldRow(title: title) {
            HStack(spacing: kind == .percent ? 0 : 2) {
                if !text.isEmpty, case .currency(let code) = kind {
                    Text(Self.currencySymbol(code: code))
                        .font(.body)
                        .foregroundStyle(Color(R.color.color111118))
                }
                TextField("", text: $text, prompt: Text(placeholder).foregroundColor(Color(R.color.colorA5A5B0)))
                    .font(text.isEmpty ? .subheadline : .body)
                    .foregroundStyle(Color(R.color.color111118))
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.decimalPad)
                    .fixedSize(horizontal: !text.isEmpty, vertical: false)
                if !text.isEmpty, kind == .percent {
                    Text(NumberFormatter().percentSymbol)
                        .font(.body)
                        .foregroundStyle(Color(R.color.color111118))
                }
            }
        }
        .onAppear { syncText() }
        .onChange(of: text) { newValue in
            let parsed = Self.parse(newValue) ?? 0
            if parsed != value { value = parsed }
        }
        .onChange(of: value) { _ in
            if Self.parse(text) ?? 0 != value { syncText() }
        }
    }

    private var placeholder: String {
        switch kind {
        case .currency(let code): return Decimal(0).currencyText(code: code)
        case .percent:            return Decimal(0).percentText
        }
    }

    private func syncText() {
        text = value == 0 ? "" : value.plainText
    }

    static func parse(_ text: String) -> Decimal? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.generatesDecimalNumbers = true
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }
        if let number = formatter.number(from: trimmed) as? NSDecimalNumber {
            return number as Decimal
        }
        return Decimal(string: trimmed)
    }

    static func currencySymbol(code: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = code
        return formatter.currencySymbol ?? code
    }
}

/// Tappable "Label  value" row (opens an options sheet, a picker…).
struct FieldOptionRow: View {
    enum ValueStyle {
        /// Body ink — a chosen value ("Due on receipt").
        case value
        /// Subheadline grey — nothing chosen yet ("Select method").
        case placeholder
        /// Body Labels/Secondary — system list row with a chevron ("Never >").
        case secondary
    }

    let title: String
    let value: String
    var style: ValueStyle = .value
    var showsChevron = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            FieldRow(title: title) {
                HStack(spacing: 10) {
                    Text(value)
                        .font(style == .placeholder ? .subheadline : .body)
                        .foregroundStyle(valueColor)
                        .lineLimit(1)
                    if showsChevron {
                        Image(R.image.ic_field_chevron)
                    }
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var valueColor: Color {
        switch style {
        case .value:       return Color(R.color.color111118)
        case .placeholder: return Color(R.color.colorA5A5B0)
        case .secondary:   return Color.secondary
        }
    }
}

/// A date row ("Date:  05/14/2024"). Tapping it expands an inline graphical
/// calendar right below (an extra list row), like the system Calendar app.
struct FieldDateRows: View {
    let title: String
    @Binding var date: Date
    @Binding var isExpanded: Bool
    /// Text shown for the date; defaults to `05/14/2024`.
    var valueText: ((Date) -> String)?
    var style: FieldOptionRow.ValueStyle = .value
    var showsChevron = false

    var body: some View {
        FieldOptionRow(
            title: title,
            value: valueText?(date) ?? date.numericDateText,
            style: isExpanded ? .value : style,
            showsChevron: showsChevron
        ) {
            withAnimation { isExpanded.toggle() }
        }
        if isExpanded {
            DatePicker("", selection: $date, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .labelsHidden()
        }
    }
}

// MARK: - Text area

/// White rounded (24) multi-line field with a grey Subheadline placeholder at
/// (20, 14), used for the note, the email message and "Other" payment info.
struct FieldTextArea: View {
    let placeholder: String
    @Binding var text: String
    var height: CGFloat

    var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $text)
                .font(.subheadline)
                .foregroundStyle(Color(R.color.color111118))
                .scrollContentBackground(.hidden)
                // TextEditor insets its text by 5pt horizontally / 8pt on top.
                .padding(.horizontal, 15)
                .padding(.top, 6)
                .padding(.bottom, 8)
            if text.isEmpty {
                Text(placeholder)
                    .font(.subheadline)
                    .foregroundStyle(Color(R.color.colorA5A5B0))
                    .padding(.leading, 20)
                    .padding(.top, 14)
                    .allowsHitTesting(false)
            }
        }
        .frame(height: height)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(R.color.colorFFFFFF))
        )
    }
}

// MARK: - Shapes

/// Rounded rectangle with separate top / bottom corner radii
/// (`UnevenRoundedRectangle` needs iOS 17).
struct FieldCornerShape: Shape {
    var top: CGFloat
    var bottom: CGFloat

    func path(in rect: CGRect) -> Path {
        let limit = min(rect.width, rect.height) / 2
        let top = min(top, limit)
        let bottom = min(bottom, limit)
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + top, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - top, y: rect.minY))
        path.addArc(center: CGPoint(x: rect.maxX - top, y: rect.minY + top), radius: top,
                    startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - bottom))
        path.addArc(center: CGPoint(x: rect.maxX - bottom, y: rect.maxY - bottom), radius: bottom,
                    startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
        path.addLine(to: CGPoint(x: rect.minX + bottom, y: rect.maxY))
        path.addArc(center: CGPoint(x: rect.minX + bottom, y: rect.maxY - bottom), radius: bottom,
                    startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + top))
        path.addArc(center: CGPoint(x: rect.minX + top, y: rect.minY + top), radius: top,
                    startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        path.closeSubpath()
        return path
    }
}

// MARK: - Options sheet

extension View {
    /// The design's "Options" action sheets: a system confirmation dialog anchored
    /// to the bottom edge of the screen (iOS 26 presents dialogs from their anchor).
    func fieldOptionsDialog<Actions: View>(
        _ title: String,
        isPresented: Binding<Bool>,
        @ViewBuilder actions: @escaping () -> Actions
    ) -> some View {
        overlay(alignment: .bottom) {
            Color.clear
                .frame(width: 1, height: 1)
                .allowsHitTesting(false)
                .confirmationDialog(title, isPresented: isPresented, titleVisibility: .hidden) {
                    actions()
                    Button(R.stringLocalizable.common_cancel(), role: .cancel) {}
                }
        }
    }
}

// MARK: - List styling

extension View {
    /// Inset-grouped list on the grouped background, 4pt under the toolbar like
    /// the design's cards, 16pt between sections.
    func fieldListStyle() -> some View {
        self
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .modifier(FieldListMargins())
    }
}

private struct FieldListMargins: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content
                .contentMargins(.top, 4, for: .scrollContent)
                .listSectionSpacing(16)
        } else {
            content
        }
    }
}
