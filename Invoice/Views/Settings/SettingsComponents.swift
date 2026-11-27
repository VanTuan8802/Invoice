//
//  SettingsComponents.swift
//  Invoice
//
//  Building blocks shared by the Settings screens: the main list row with its
//  colored icon tile, the "Upgrade To Premium" banner, and form styling.
//

import SwiftUI

// MARK: - Icon row (Settings/Main)

/// List row: 32pt rounded icon tile, title, trailing drill-in chevron.
struct SettingsIconRow: View {
    let icon: RswiftResources.ImageResource
    /// Tile background.
    let tileColor: Color
    /// Already-localized title.
    let title: String
    var tileCornerRadius: CGFloat = 12

    var body: some View {
        HStack(spacing: 12) {
            Image(icon)
                .frame(width: 20, height: 20)
                .frame(width: 32, height: 32)
                .background(
                    RoundedRectangle(cornerRadius: tileCornerRadius, style: .continuous)
                        .fill(tileColor)
                )
            Text(title)
                .font(.body)
                .foregroundStyle(Color(R.color.color111118))
                .lineLimit(2)
            Spacer(minLength: 8)
            SettingsChevron()
        }
        .contentShape(Rectangle())
    }
}

/// Grey drill-in chevron used at the end of tappable rows.
struct SettingsChevron: View {
    var body: some View {
        Image(systemName: "chevron.right")
            .font(.footnote.weight(.semibold))
            .foregroundStyle(Color(.tertiaryLabel))
    }
}

/// Trailing value + chevron row used by menu pickers ("3 days >", "This Month >").
struct SettingsMenuRowLabel: View {
    /// Already-localized texts.
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 10) {
            Text(title)
                .font(.body)
                .foregroundStyle(Color(.label))
            Spacer(minLength: 8)
            Text(value)
                .font(.body)
                .foregroundStyle(Color(.secondaryLabel))
                .lineLimit(1)
            SettingsChevron()
        }
        .contentShape(Rectangle())
    }
}

// MARK: - Premium banner

/// Lavender "Upgrade To Premium" card at the top of Settings/Main.
struct SettingsPremiumBanner: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                Text(R.stringLocalizable.settings_upgrade_title())
                    .font(.title.bold())
                    .foregroundStyle(Color(R.color.color111118))
                    .lineLimit(3)
                    .minimumScaleFactor(0.6)
                    .frame(maxWidth: 190, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 8)

                HStack(spacing: 10) {
                    Text(R.stringLocalizable.settings_upgrade_button())
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color(R.color.colorFFFFFF))
                    Image(R.image.ic_settings_arrow_up_right)
                        .frame(width: 28, height: 28)
                        .background(Circle().fill(Color(R.color.colorFFFFFF)))
                }
                .padding(.leading, 16)
                .padding(.trailing, 6)
                .padding(.vertical, 6)
                .background(Capsule().fill(Color(R.color.color111118)))
            }
            .padding(.top, 20)
            .padding(.horizontal, 22)
            .padding(.bottom, 18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(minHeight: 150)
            .background(alignment: .topTrailing) { decoration }
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    /// Lavender fill, soft white disc and the premium illustration, anchored to
    /// the trailing edge like the design (disc 190pt, illustration 170pt).
    private var decoration: some View {
        ZStack(alignment: .topTrailing) {
            Color(R.color.colorB4A5FF)
            Circle()
                .fill(Color(R.color.colorFFFFFF).opacity(0.22))
                .frame(width: 190, height: 190)
                .offset(x: 29, y: -30)
            Image(R.image.illus_premium)
                .resizable()
                .scaledToFit()
                .frame(width: 170, height: 170)
                .offset(x: -1, y: -14)
        }
    }
}

// MARK: - Form styling

extension View {
    /// Inset-grouped form metrics from the design: 52pt rows, the gap under the
    /// toolbar (`topMargin`) and, optionally, the spacing between sections.
    @ViewBuilder
    func settingsFormStyle(topMargin: CGFloat = 2, sectionSpacing: CGFloat? = nil) -> some View {
        let base = self
            .environment(\.defaultMinListRowHeight, 52)
            .scrollDismissesKeyboard(.interactively)
        if #available(iOS 17.0, *) {
            if let sectionSpacing {
                base
                    .listSectionSpacing(sectionSpacing)
                    .contentMargins(.top, topMargin, for: .scrollContent)
            } else {
                base.contentMargins(.top, topMargin, for: .scrollContent)
            }
        } else {
            base
        }
    }

    /// Grey footnote under a card ("Automatically remind clients…"), 8pt lower
    /// than the system default like the design.
    func settingsSectionFooter() -> some View {
        padding(.top, 8)
    }

    /// Grouped-section header as drawn in the design: not uppercased and flush
    /// with the card's leading edge (the system insets it by 16pt).
    func settingsSectionHeader() -> some View {
        textCase(nil)
            .padding(.leading, -16)
            .padding(.bottom, 7)
    }
}

/// "Preview" / "Message to customer" caption above a card (10pt in from the card edge).
struct SettingsCaption: View {
    /// Already-localized text.
    let text: String
    var color: Color = Color(R.color.color6B6B78)

    var body: some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(color)
            .textCase(nil)
            .padding(.leading, -6)
    }
}

/// Placeholder text in the design's light grey (#A5A5B0).
func settingsPrompt(_ text: String) -> Text {
    Text(text).foregroundColor(Color(R.color.colorA5A5B0))
}
