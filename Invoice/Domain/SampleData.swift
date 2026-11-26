//
//  SampleData.swift
//  Invoice
//
//  Seed content so every screen has something to show (matches the design copy).
//

import Foundation

enum SampleData {
    static let clients: [Client] = [
        Client(name: "Jane Cooper", email: "binhan628@gmail.com", mobile: "(684) 555-0102",
               phone: "080.48924", addressLines: ["6391 Elgin St. Celina, Delaware 10299", "", ""]),
        Client(name: "Walt Disney Company", email: "contact@disney.com", phone: "(209) 555-0104",
               addressLines: ["775 Rolling Green Rd.", "", ""]),
        Client(name: "ABC Lawn Care", email: "ckctml2@gmail.com", phone: "209.555.0104",
               addressLines: ["775 Rolling Green Rd.", "", ""])
    ]

    static let items: [CatalogItem] = [
        CatalogItem(name: "Chicken", price: 123, quantity: 1, discountPercent: 10, isTaxable: true),
        CatalogItem(name: "Travel suitcase", price: 2, quantity: 1, discountPercent: 10, isTaxable: true)
    ]

    static let business = BusinessProfile(
        name: "ABC Lawn Care",
        email: "ckctml2@gmail.com",
        phone: "0122 256 256",
        address: "775 Rolling Green Rd.",
        website: "https://www.taobao.com/"
    )

    static var invoices: [Document] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var first = Document(kind: .invoice, number: "IV123",
                             issueDate: today, dueDate: calendar.date(byAdding: .day, value: 4, to: today) ?? today)
        first.client = clients[0]
        first.items = items.map { LineItem(name: $0.name, price: $0.price, quantity: $0.quantity,
                                           discountPercent: $0.discountPercent, isTaxable: $0.isTaxable) }
        first.discount = DiscountSetting(mode: .perItem)
        first.tax = TaxSetting(mode: .onTotal, label: "Sales tax", ratePercent: 4)
        first.paymentInstructions = PaymentInstructions(paypalEmail: "binhan628@gmail.com", checkPayableTo: "Bessie Cooper")
        first.note = "Lorem Ipsum is simply dummy text of the printing and typesetting industry."

        var second = Document(kind: .invoice, number: "IAD#23", issueDate: today, dueDate: today)
        second.items = [LineItem(name: "Consulting", price: 10_000, quantity: 1)]
        second.status = .paid
        second.paidDate = today

        return [first, second]
    }

    static var estimates: [Document] {
        var estimate = Document(kind: .estimate, number: "EST0001")
        estimate.client = clients[1]
        estimate.items = [LineItem(name: "Chicken", price: 123, quantity: 2)]
        return [estimate]
    }
}
