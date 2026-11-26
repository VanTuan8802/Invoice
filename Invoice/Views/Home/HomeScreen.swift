//
//  HomeScreen.swift
//  Invoice
//
//  Created by VanTuan on 18/6/26.
//

import SwiftUI
import Factory

/// Figma "Home": brand header + settings, promo banner, 2×2 quick-action tiles
/// (Invoice / Estimate / Client / Item) and the Reports entry row.
struct HomeScreen: View {
    @StateObject private var viewModel = HomeViewModel()
    // Observe the language so localized text re-reads `R.stringLocalizable` at runtime.
    @InjectedObject(\.appFlow) private var appFlow: AppFlowCoordinator

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                header
                    .padding(.bottom, 0)
                promoBanner
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(HomeViewModel.Tile.allCases) { tile in
                        tileView(tile)
                    }
                }
                reportsEntry
                    .padding(.top, 2)
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .background(Color(R.color.colorF4F4F6).ignoresSafeArea())
        .trackScreen(.home)
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 12) {
            Image(R.image.illus_logo)
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.todayText)
                    .font(.caption)
                    .foregroundStyle(Color(R.color.color6B6B78))
                Text(R.stringLocalizable.home_title())
                    .font(.title.bold())
                    .foregroundStyle(Color(R.color.color111118))
            }
            .lineLimit(1)

            Spacer(minLength: 0)

            Button(action: viewModel.openSettings) {
                Image(R.image.ic_home_settings)
                    .frame(width: 48, height: 48)
                    .background(
                        Circle()
                            .fill(Color(R.color.colorFFFFFF))
                            .overlay(Circle().strokeBorder(Color(R.color.colorDADAE0), lineWidth: 1))
                    )
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .frame(height: 52)
    }

    // MARK: - Promo banner

    private var promoBanner: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text(R.stringLocalizable.home_promo_title())
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color(R.color.color111118))
                Text(R.stringLocalizable.home_promo_message())
                    .font(.footnote)
                    .foregroundStyle(Color(R.color.color6B6B78))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // 92pt illustration overflowing its 76pt slot by 8pt on each side (as in the design).
            Color.clear
                .frame(width: 76, height: 76)
                .overlay {
                    Image(R.image.illus_welcome)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 92, height: 92)
                }
        }
        .padding(.leading, 18)
        .padding(.trailing, 10)
        .padding(.vertical, 12)
        .frame(height: 96)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(R.color.colorFFFFFF))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .strokeBorder(Color(R.color.colorDADAE0), lineWidth: 1)
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    // MARK: - Quick-action tiles

    private func tileView(_ tile: HomeViewModel.Tile) -> some View {
        Button {
            viewModel.open(tile)
        } label: {
            VStack(spacing: 0) {
                // 150pt illustration centered in a 128pt-tall slot, nudged 12pt up.
                Color.clear
                    .frame(height: 128)
                    .overlay(alignment: .top) {
                        Image(tile.illustration)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .offset(y: -12)
                    }
                Spacer(minLength: 0)
                HStack {
                    Text(tile.title)
                        .font(.title2.bold())
                        .foregroundStyle(Color(R.color.color111118))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Spacer(minLength: 4)
                    Image(R.image.ic_home_arrow_up_right)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(Color(R.color.color111118)))
                }
            }
            .padding(.top, 14)
            .padding(.bottom, 18)
            .padding(.horizontal, 18)
            .frame(height: 200)
            .background(tile.background)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Reports entry

    private var reportsEntry: some View {
        Button(action: viewModel.openReports) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(R.stringLocalizable.home_reports_title())
                        .font(.body)
                        .foregroundStyle(Color.primary)
                    Text(R.stringLocalizable.home_reports_subtitle())
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color(.tertiaryLabel))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 11)
            .frame(minHeight: 64)
            .background(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
            .contentShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
#Preview {
    HomeScreen()
}
#endif
