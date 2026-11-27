//
//  BasicHeaderView.swift
//  Invoice
//
//  Created by VanTuan on 18/6/26.
//

import SwiftUI

/// The design's top toolbar ("Toolbar - Top - iPhone"): 44pt glass circle on the
/// leading side, centered headline title, trailing slot for a glass icon button
/// (`HeaderIconButton`) or a blue prominent pill (`HeaderTextButton`).
/// The router hides the system navigation bar, so every screen draws this.
struct BasicHeaderView<Leading: View, Trailing: View>: View {

    /// Shown centered. Pass an already-localized string (e.g. `R.stringLocalizable.home()`).
    let title: String

    /// When `true`, the leading slot shows the glass back chevron that calls
    /// `backAction`. When `false`, it shows `leadingView` instead.
    var showBack: Bool

    /// Called when the default back button is tapped.
    var backAction: (() -> Void)?

    /// Called when `trailingView` is tapped. If `nil`, the trailing view is shown
    /// as-is (use this when it is already a button, e.g. `HeaderIconButton`).
    var trailingAction: (() -> Void)?

    @ViewBuilder private let leadingView: () -> Leading
    @ViewBuilder private let trailingView: () -> Trailing

    init(
        _ title: String,
        showBack: Bool = false,
        backAction: (() -> Void)? = nil,
        trailingAction: (() -> Void)? = nil,
        @ViewBuilder leadingView: @escaping () -> Leading = { EmptyView() },
        @ViewBuilder trailingView: @escaping () -> Trailing = { EmptyView() }
    ) {
        self.title = title
        self.showBack = showBack
        self.backAction = backAction
        self.trailingAction = trailingAction
        self.leadingView = leadingView
        self.trailingView = trailingView
    }

    var body: some View {
        ZStack {
            Text(title)
                .font(.headline)
                .foregroundStyle(Color(R.color.color111118))
                .lineLimit(1)
                .padding(.horizontal, 88) // keep the title clear of the side slots

            HStack(spacing: 0) {
                leading
                Spacer(minLength: 0)
                trailing
            }
        }
        // Figma toolbar: 60pt tall with the 44pt controls at its top, so content
        // starts 16pt below the buttons instead of right under them.
        .frame(height: Self.controlsHeight)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .padding(.bottom, Self.bottomSpacing)
    }

    static var controlsHeight: CGFloat { 44 }
    static var bottomSpacing: CGFloat { 16 }

    // MARK: - Slots

    @ViewBuilder
    private var leading: some View {
        if showBack {
            HeaderIconButton(systemImage: "chevron.left") { backAction?() }
        } else {
            leadingView()
        }
    }

    @ViewBuilder
    private var trailing: some View {
        if let trailingAction {
            Button {
                trailingAction()
            } label: {
                trailingView()
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        } else {
            trailingView()
        }
    }
}

/// 44pt glass circle with an SF Symbol ("Button - Liquid Glass - Symbol").
struct HeaderIconButton: View {
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color(R.color.color111118))
                .frame(width: 44, height: 44)
                .contentShape(Circle())
                .glassCircle()
        }
        .buttonStyle(.plain)
    }
}

/// Blue prominent pill used for "Save" / "Done" in the toolbar — 34pt tall like
/// the design (the system `.glassProminent` + `.large` pill is ~44pt and crowds
/// the content below).
struct HeaderTextButton: View {
    /// Already-localized text, e.g. `R.stringLocalizable.save()`.
    let title: String
    let action: () -> Void

    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundStyle(isEnabled ? Color(R.color.colorFFFFFF) : Color(R.color.color8E8E9A))
                .padding(.horizontal, 14)
                .frame(minWidth: 64)
                .frame(height: 34)
                .background(pill)
                .contentShape(Capsule())
        }
        // Own disabled look (grey pill, like `PrimaryButton`) instead of the
        // system fade stacked on a faded pill.
        .buttonStyle(PressFadeButtonStyle())
    }

    @ViewBuilder
    private var pill: some View {
        if !isEnabled {
            Capsule().fill(Color(R.color.colorDFDFDF))
        } else if #available(iOS 26.0, *) {
            Capsule()
                .fill(Color.accentColor)
                .glassEffect(.regular.tint(Color.accentColor).interactive(), in: .capsule)
        } else {
            Capsule().fill(Color.accentColor)
        }
    }
}

/// Large left-aligned title under a glass back button (Settings, Reports).
struct LargeTitleHeader: View {
    /// Already-localized text.
    let title: String
    var showBack: Bool = true
    var backAction: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if showBack {
                HeaderIconButton(systemImage: "chevron.left") { backAction?() }
            }
            Text(title)
                .font(.largeTitle.bold())
                .foregroundStyle(Color(R.color.color111118))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.top, 4)
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 24) {
        BasicHeaderView(R.stringLocalizable.settings(), showBack: true, backAction: {}) {
            HeaderIconButton(systemImage: "ellipsis") {}
        }
        BasicHeaderView(R.stringLocalizable.language(), showBack: true, backAction: {}) {
            HeaderTextButton(title: R.stringLocalizable.save()) {}
        }
        LargeTitleHeader(title: R.stringLocalizable.settings(), backAction: {})
    }
    .padding(.vertical)
    .background(Color(.systemGroupedBackground))
}
#endif
