//
//  Logger.swift
//  Invoice
//

import Foundation

/// Debug-only log. Prefixes the calling function's name; compiled out of Release.
func logger(message: String, function: StaticString = #function) {
    #if DEBUG
    print("\(function): \(message)")
    #endif
}

/// Debug-only error log. Same as `logger(message:)` with a ❌ prefix.
func logger(error: String, function: StaticString = #function) {
    #if DEBUG
    print("❌\(function): \(error)")
    #endif
}
