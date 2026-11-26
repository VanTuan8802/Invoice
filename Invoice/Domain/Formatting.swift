//
//  Formatting.swift
//  Invoice
//
//  Money / date formatting shared by every screen.
//

import Foundation

extension Decimal {
    /// `$1,234.50` in the given currency (defaults to the store's currency).
    func currencyText(code: String = DataStore.defaultCurrencyCode) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = code
        return formatter.string(from: self as NSDecimalNumber) ?? "\(self)"
    }

    /// `10%` style percentage (value already in 0…100).
    var percentText: String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        return (formatter.string(from: self as NSDecimalNumber) ?? "\(self)") + "%"
    }

    /// Plain number without grouping noise ("1", "2.5").
    var plainText: String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        return formatter.string(from: self as NSDecimalNumber) ?? "\(self)"
    }
}

extension Date {
    /// `05/14/2024`
    var numericDateText: String {
        formatted(.dateTime.month(.twoDigits).day(.twoDigits).year())
    }

    /// `Thursday, 06 Nov`
    var weekdayDayMonthText: String {
        formatted(.dateTime.weekday(.wide).day(.twoDigits).month(.abbreviated))
    }
}
