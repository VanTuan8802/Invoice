//
//  UnitScreen.swift
//  Invoice
//
//  Settings/Unit: currency (→ `DataStore.currencyCode`) and date format
//  (`@AppStorage`), with a live preview. Changes apply on Save.
//

import SwiftUI
import Factory

struct UnitScreen: View {
    @InjectedObject(\.dataStore) private var store: DataStore
    @Injected(\.app) private var app

    @AppStorage(SettingsStorage.Key.dateFormat) private var storedDateFormat = SettingsStorage.defaultDateFormat

    @State private var currencyCode = DataStore.defaultCurrencyCode
    @State private var dateFormat = SettingsStorage.defaultDateFormat
    @State private var showsCurrencyPicker: Bool
    @State private var didLoad = false

    /// - Parameter showsCurrencyPicker: open with the currency sheet presented.
    init(showsCurrencyPicker: Bool = false) {
        _showsCurrencyPicker = State(initialValue: showsCurrencyPicker)
    }

    private static let previewAmount = Decimal(string: "125.23") ?? 0

    var body: some View {
        VStack(spacing: 0) {
            BasicHeaderView(R.stringLocalizable.settings_unit(),
                            showBack: true,
                            backAction: { app.navi.pop() }) {
                HeaderTextButton(title: R.stringLocalizable.save(), action: save)
            }

            Form {
                Section {
                    Button {
                        showsCurrencyPicker = true
                    } label: {
                        valueRow(R.stringLocalizable.settings_currency(),
                                 value: SettingsCurrency.display(currencyCode),
                                 valueFont: .body)
                    }
                    .buttonStyle(.plain)

                    Menu {
                        Picker(selection: $dateFormat) {
                            ForEach(SettingsStorage.dateFormats, id: \.self) { format in
                                Text(format).tag(format)
                            }
                        } label: {
                            EmptyView()
                        }
                        .pickerStyle(.inline)
                    } label: {
                        valueRow(R.stringLocalizable.settings_date_format(), value: dateFormat, valueFont: .subheadline)
                    }
                }

                Section {
                    valueRow(R.stringLocalizable.settings_currency(),
                             value: Self.previewAmount.currencyText(code: currencyCode),
                             valueFont: .body)
                    valueRow(R.stringLocalizable.settings_date_format(),
                             value: previewDate,
                             valueFont: .subheadline)
                } header: {
                    SettingsCaption(text: R.stringLocalizable.settings_preview())
                }
            }
            .settingsFormStyle()
        }
        .groupedScreenBackground()
        .sheet(isPresented: $showsCurrencyPicker) {
            CurrencyPickerSheet(selection: $currencyCode)
        }
        .onAppear {
            guard !didLoad else { return }
            didLoad = true
            currencyCode = store.currencyCode
            dateFormat = storedDateFormat
        }
        .trackScreen(.settingsUnit)
    }

    private var previewDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = dateFormat
        return formatter.string(from: Date())
    }

    private func valueRow(_ title: String, value: String, valueFont: Font) -> some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.body)
                .foregroundStyle(Color(R.color.color111118))
            Spacer(minLength: 8)
            Text(value)
                .font(valueFont)
                .foregroundStyle(Color(R.color.color111118))
                .lineLimit(1)
        }
        .contentShape(Rectangle())
    }

    private func save() {
        store.currencyCode = currencyCode
        storedDateFormat = dateFormat
        app.navi.pop()
    }
}

#if DEBUG
#Preview {
    UnitScreen()
}
#endif
