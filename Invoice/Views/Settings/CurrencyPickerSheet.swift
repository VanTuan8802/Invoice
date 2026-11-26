//
//  CurrencyPickerSheet.swift
//  Invoice
//
//  Settings/Unit/Currency Picker: searchable list of currency cards. Tapping a
//  card selects it and closes the sheet.
//

import SwiftUI

struct CurrencyPickerSheet: View {
    @Binding var selection: String
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""

    private var results: [SettingsCurrency] {
        let text = query.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return SettingsCurrency.all }
        return SettingsCurrency.all.filter {
            $0.code.localizedCaseInsensitiveContains(text) || $0.name.localizedCaseInsensitiveContains(text)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                Text(R.stringLocalizable.settings_currency())
                    .font(.title2.bold())
                    .foregroundStyle(Color(R.color.color111118))
                Rectangle()
                    .fill(Color(R.color.colorC7C7CC))
                    .frame(height: 0.5)
            }
            .padding(.top, 21)

            SearchEntryField(placeholder: R.stringLocalizable.settings_search(), text: $query)
                .overlay(Capsule().strokeBorder(Color(R.color.colorDADAE0), lineWidth: 1))
                .padding(.top, 22)

            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(results) { currency in
                        Button {
                            selection = currency.code
                            dismiss()
                        } label: {
                            row(currency)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, 24)
                .padding(.bottom, 16)
            }
            .scrollDismissesKeyboard(.immediately)
        }
        .padding(.horizontal, 16)
        .groupedScreenBackground()
        .presentationDetents([.large])
        .trackScreen(.settingsCurrencyPicker)
    }

    private func row(_ currency: SettingsCurrency) -> some View {
        HStack(spacing: 12) {
            Image(currency.flag)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 30)
            VStack(alignment: .leading, spacing: 4) {
                Text(currency.code)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color(R.color.color151515))
                Text(currency.name)
                    .font(.footnote)
                    .foregroundStyle(Color(R.color.color6B6B78))
                    .lineLimit(1)
            }
            Spacer(minLength: 8)
            Text(currency.symbol)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color(R.color.color151515))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(R.color.colorFFFFFF))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Color.accentColor, lineWidth: currency.code == selection ? 1.5 : 0)
        )
        .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

#if DEBUG
#Preview {
    CurrencyPickerSheet(selection: .constant("USD"))
}
#endif
