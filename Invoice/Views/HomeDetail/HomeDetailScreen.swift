//
//  HomeDetailScreen.swift
//  Invoice
//
//  Created by VanTuan on 18/6/26.
//

import SwiftUI


struct HomeDetailScreen: View {
    @StateObject private var viewModel: HomeDetailViewModel

    init(id: Int) {
        _viewModel = StateObject(wrappedValue: HomeDetailViewModel(id: id))
    }

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button {
                    viewModel.goBack()
                } label: {
                    Label(R.stringLocalizable.back(), systemImage: "chevron.left")
                }
                Spacer()
            }
            .padding(.horizontal)

            Spacer()
            Image(systemName: "doc.text.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color.accentColor)
            Text(R.stringLocalizable.item_number(viewModel.id)).font(.title.bold())
            Button(R.stringLocalizable.open_next()) { viewModel.openNext() }
                .buttonStyle(.borderedProminent)
            Button(R.stringLocalizable.back_to_top()) { viewModel.goToTop() }
                .buttonStyle(.bordered)
            Spacer()
        }
        .padding(.top, 8)
        .trackScreen(.homeDetail)
    }
}
