//
//  DocumentComponents.swift
//  Invoice
//
//  Small building blocks shared by the invoice & estimate screens: editor cards,
//  section headers, chips, the purple total bar, empty state and toolbar buttons.
//

import SwiftUI

// MARK: - Editor cards

/// Grey subheadline above an editor card ("Invoice Info", "Client Info"…).
struct DocumentSectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.subheadline)
            .foregroundStyle(Color(R.color.color6B6B78))
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
    }
}

/// Header + content stacked with no gap (the design's section groups).
struct DocumentSection<Content: View>: View {
    let title: String?
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let title {
                DocumentSectionHeader(title: title)
            }
            content()
        }
    }
}

extension View {
    /// White editor card: 16pt padding, radius 24 (only the given corners when `corners` is set).
    func documentCard(corners: RectCorners = .all, radius: CGFloat = 24, padding: CGFloat = 16) -> some View {
        self
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                CornerRoundedRectangle(radius: radius, corners: corners)
                    .fill(Color(R.color.colorFFFFFF))
            )
            .contentShape(Rectangle())
    }
}

/// Hairline between rows inside an editor card.
struct DocumentRowDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color(R.color.colorE8E8EE))
            .frame(height: 0.5)
    }
}

/// The design's right chevron in a 24pt slot.
struct DocumentChevron: View {
    var body: some View {
        Image(R.image.ic_document_chevron_right)
            .frame(width: 24, height: 24)
    }
}

/// Purple footer under the items / price cards ("Subtotal", "Balance").
struct DocumentTotalBar: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
            Spacer(minLength: 8)
            Text(value)
        }
        .font(.body)
        .foregroundStyle(Color(R.color.color111118))
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            CornerRoundedRectangle(radius: 10, corners: .bottom)
                .fill(Color(R.color.colorCFC3FF))
        )
    }
}

/// Outlined capsule ("Send Reminder", "Due Today").
struct OutlinedChip: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.footnote)
            .foregroundStyle(Color(R.color.color111118))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .overlay(Capsule().strokeBorder(Color(R.color.colorE8E8EE), lineWidth: 1))
    }
}

/// Paid / Unpaid / Overdue tinted capsule (search results).
struct DocumentStatusChip: View {
    let status: DocumentDisplayStatus

    var body: some View {
        Text(status.title)
            .font(.caption.weight(.semibold))
            .foregroundStyle(status.tint)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Capsule().fill(status.background))
    }
}

/// Selectable filter chip (All / Paid / Unpaid / Overdue).
struct DocumentFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(isSelected ? .semibold : .medium))
                .foregroundStyle(isSelected ? Color(R.color.colorFFFFFF) : Color.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(
                    Capsule().fill(isSelected ? Color(R.color.color6A4DF5) : Color(.secondarySystemGroupedBackground))
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Empty state

/// Illustration on a soft rounded tile + title + message (lists and history).
struct DocumentEmptyStateView: View {
    let image: RswiftResources.ImageResource
    let tile: Color
    /// Already-localized texts.
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 24) {
            RoundedRectangle(cornerRadius: 56, style: .continuous)
                .fill(tile)
                .frame(width: 180, height: 180)
                .overlay(
                    Image(image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                )
            VStack(spacing: 12) {
                Text(title)
                    .font(.title2)
                    .foregroundStyle(Color(R.color.color111118))
                Text(message)
                    .font(.body)
                    .foregroundStyle(Color(R.color.color9A9AA6))
                    .frame(maxWidth: 290)
            }
            .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Toolbar buttons

/// The glass "…" circle used as a `Menu` label (same look as `HeaderIconButton`).
struct HeaderMenuLabel: View {
    var systemImage: String = "ellipsis"

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(Color(R.color.color111118))
            .frame(width: 44, height: 44)
            .contentShape(Circle())
            .glassCircle()
    }
}

/// Non-prominent glass text pill ("Filter", "Reset").
struct HeaderGlassTextButton: View {
    /// Already-localized text.
    let title: String
    let action: () -> Void

    var body: some View {
        if #available(iOS 26.0, *) {
            Button(action: action) {
                Text(title).font(.body.weight(.medium)).padding(.horizontal, 2)
            }
            .buttonStyle(.glass)
            .controlSize(.large)
            .tint(Color(R.color.color111118))
        } else {
            Button(action: action) {
                Text(title)
                    .font(.body.weight(.medium))
                    .foregroundStyle(Color(R.color.color111118))
                    .padding(.horizontal, 14)
                    .frame(height: 36)
                    .glassCapsule()
            }
            .buttonStyle(.plain)
        }
    }
}

/// Full-width blue prominent capsule ("Show 12 Invoices").
struct ProminentWideButton: View {
    /// Already-localized text.
    let title: String
    let action: () -> Void

    var body: some View {
        if #available(iOS 26.0, *) {
            Button(action: action) {
                Text(title)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 36)
            }
            .buttonStyle(.glassProminent)
            .controlSize(.large)
        } else {
            Button(action: action) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color(R.color.colorFFFFFF))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Capsule().fill(Color.accentColor))
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Shapes

struct RectCorners: OptionSet {
    let rawValue: Int
    static let topLeft = RectCorners(rawValue: 1 << 0)
    static let topRight = RectCorners(rawValue: 1 << 1)
    static let bottomLeft = RectCorners(rawValue: 1 << 2)
    static let bottomRight = RectCorners(rawValue: 1 << 3)
    static let top: RectCorners = [.topLeft, .topRight]
    static let bottom: RectCorners = [.bottomLeft, .bottomRight]
    static let all: RectCorners = [.top, .bottom]
}

/// Rounded rectangle with a chosen set of rounded corners (iOS 16 friendly).
struct CornerRoundedRectangle: Shape {
    var radius: CGFloat
    var corners: RectCorners = .all

    func path(in rect: CGRect) -> Path {
        let maxRadius = min(rect.width, rect.height) / 2
        let r = min(radius, maxRadius)
        let tl = corners.contains(.topLeft) ? r : 0
        let tr = corners.contains(.topRight) ? r : 0
        let bl = corners.contains(.bottomLeft) ? r : 0
        let br = corners.contains(.bottomRight) ? r : 0

        var path = Path()
        path.move(to: CGPoint(x: rect.minX + tl, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - tr, y: rect.minY))
        path.addArc(center: CGPoint(x: rect.maxX - tr, y: rect.minY + tr), radius: tr,
                    startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - br))
        path.addArc(center: CGPoint(x: rect.maxX - br, y: rect.maxY - br), radius: br,
                    startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
        path.addLine(to: CGPoint(x: rect.minX + bl, y: rect.maxY))
        path.addArc(center: CGPoint(x: rect.minX + bl, y: rect.maxY - bl), radius: bl,
                    startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + tl))
        path.addArc(center: CGPoint(x: rect.minX + tl, y: rect.minY + tl), radius: tl,
                    startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        path.closeSubpath()
        return path
    }
}

/// Label tag pointing right (share menu "Text" / "Email").
struct TagShape: Shape {
    func path(in rect: CGRect) -> Path {
        let r: CGFloat = 3
        let tip: CGFloat = 11
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + r, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - tip, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX - tip, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + r, y: rect.maxY))
        path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.maxY - r), control: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + r))
        path.addQuadCurve(to: CGPoint(x: rect.minX + r, y: rect.minY), control: CGPoint(x: rect.minX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

/// Horizontal dashed rule (preview item table).
struct DashedLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}
