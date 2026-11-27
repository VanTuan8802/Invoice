//
//  BusinessLogoView.swift
//  Invoice
//
//  Onboarding/Business Logo: dashed lavender drop zone that opens the photo
//  picker. Continue writes the picked image into `DataStore.business.logoData`.
//

import SwiftUI
import PhotosUI
import Factory

struct BusinessLogoView: View {
    @EnvironmentObject private var coordinator: AppFlowCoordinator
    @InjectedObject(\.dataStore) private var store: DataStore

    @State private var pickerItem: PhotosPickerItem?
    @State private var logoData: Data?
    @State private var didLoad = false

    var body: some View {
        OnboardingStepScaffold(
            title: R.stringLocalizable.onboarding_logo_title(),
            subtitle: R.stringLocalizable.onboarding_logo_subtitle(),
            subtitleWidth: 240,
            onBack: { coordinator.goBack() },
            onContinue: {
                if let logoData { store.business.logoData = logoData }
                coordinator.businessLogoDidFinish()
            },
            onSkip: { coordinator.businessLogoDidFinish() }
        ) {
            PhotosPicker(selection: $pickerItem, matching: .images) {
                dropZone
            }
            .buttonStyle(.plain)
        }
        .onAppear {
            guard !didLoad else { return }
            didLoad = true
            logoData = store.business.logoData
        }
        .onChange(of: pickerItem) { item in
            guard let item else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    logoData = Self.normalized(data)
                }
            }
        }
        .trackScreen(.businessLogo)
    }

    /// Lavender 25% fill, 0.5pt dashed ink border, radius 10. Shows the picked
    /// logo once there is one.
    private var dropZone: some View {
        VStack(spacing: 9) {
            if let logoData, let image = UIImage(data: logoData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 160, maxHeight: 96)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                Text(R.stringLocalizable.onboarding_logo_change())
                    .font(.subheadline)
                    .foregroundStyle(Color(R.color.color6A4DF5))
            } else {
                Image(R.image.ic_onboarding_upload)
                Text(R.stringLocalizable.onboarding_logo_upload())
                    .font(.subheadline)
                    .foregroundStyle(Color(R.color.color6A4DF5))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, logoData == nil ? 50 : 24)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(R.color.colorCFC3FF).opacity(0.25))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(Color(R.color.color111118), style: StrokeStyle(lineWidth: 0.5, dash: [4, 3]))
        )
        .contentShape(Rectangle())
    }

    /// Downscale big photos so the in-memory profile stays small (max 512pt side).
    private static func normalized(_ data: Data) -> Data? {
        guard let image = UIImage(data: data) else { return nil }
        let maxSide: CGFloat = 512
        let scale = min(1, maxSide / max(image.size.width, image.size.height))
        guard scale < 1 else { return image.pngData() }
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let resized = UIGraphicsImageRenderer(size: size).image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        return resized.pngData()
    }
}

#if DEBUG
#Preview {
    BusinessLogoView()
        .environmentObject(AppFlowCoordinator())
}
#endif
