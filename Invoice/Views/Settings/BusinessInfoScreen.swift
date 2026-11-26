//
//  BusinessInfoScreen.swift
//  Invoice
//
//  Settings/Business Info: logo upload + business, address and contact fields.
//  Edits `DataStore.business`; owner name, business number and mobile have no
//  model field yet and are kept in `@AppStorage`.
//

import SwiftUI
import PhotosUI
import Factory

struct BusinessInfoScreen: View {
    @InjectedObject(\.dataStore) private var store: DataStore
    @Injected(\.app) private var app

    @AppStorage(SettingsStorage.Key.businessOwnerName) private var storedOwnerName = ""
    @AppStorage(SettingsStorage.Key.businessNumber) private var storedBusinessNumber = ""
    @AppStorage(SettingsStorage.Key.businessMobile) private var storedMobile = ""

    @State private var draft = BusinessProfile()
    /// "Address 1…3" rows; joined into `BusinessProfile.address` (one per line) on save.
    @State private var addressLines = ["", "", ""]
    @State private var ownerName = ""
    @State private var businessNumber = ""
    @State private var mobile = ""
    @State private var photoItem: PhotosPickerItem?
    @State private var didLoad = false

    var body: some View {
        VStack(spacing: 0) {
            BasicHeaderView(R.stringLocalizable.settings_business_info(),
                            showBack: true,
                            backAction: { app.navi.pop() }) {
                HeaderTextButton(title: R.stringLocalizable.save(), action: save)
            }

            Form {
                Section {
                    field(R.stringLocalizable.settings_business_name(), text: $draft.name)
                        .textContentType(.organizationName)
                    field(R.stringLocalizable.settings_business_owner(), text: $ownerName)
                        .textContentType(.name)
                    field(R.stringLocalizable.settings_business_number(), text: $businessNumber)
                } header: {
                    // In the header (not a row) so the cell's rounded mask doesn't clip it.
                    logoPicker
                        .textCase(nil)
                        .padding(.horizontal, -16)
                        .padding(.bottom, 8)
                }

                Section {
                    ForEach(addressLines.indices, id: \.self) { index in
                        field(R.stringLocalizable.settings_address_line(index + 1), text: $addressLines[index])
                    }
                }

                Section {
                    field(R.stringLocalizable.settings_email(), text: $draft.email, keyboard: .emailAddress)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    field(R.stringLocalizable.settings_phone(), text: $draft.phone, keyboard: .phonePad)
                        .textContentType(.telephoneNumber)
                    field(R.stringLocalizable.settings_mobile(), text: $mobile, keyboard: .phonePad)
                    field(R.stringLocalizable.settings_website(), text: $draft.website, keyboard: .URL)
                        .textContentType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
            }
            .settingsFormStyle(topMargin: 0, sectionSpacing: 16)
        }
        .groupedScreenBackground()
        .onAppear(perform: load)
        .onChange(of: photoItem) { item in
            Task { await loadLogo(from: item) }
        }
        .trackScreen(.settingsBusinessInfo)
    }

    // MARK: Logo

    private var logoPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(R.stringLocalizable.settings_business_logo())
                .font(.subheadline)
                .foregroundStyle(Color(R.color.color111118))
                .padding(.leading, 3)

            PhotosPicker(selection: $photoItem, matching: .images) {
                logoBox
            }
            .buttonStyle(.plain)
        }
    }

    private var logoBox: some View {
        ZStack {
            if let data = draft.logoData, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 75)
            } else {
                VStack(spacing: 9) {
                    Image(R.image.ic_settings_upload)
                    Text(R.stringLocalizable.settings_upload_photo())
                        .font(.footnote)
                        .foregroundStyle(Color(R.color.color6A4DF5))
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 99)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(R.color.colorCFC3FF).opacity(0.25))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(Color(R.color.color111118),
                              style: StrokeStyle(lineWidth: 0.5, dash: [4, 3]))
        )
        .contentShape(Rectangle())
    }

    // MARK: Fields

    private func field(_ placeholder: String,
                       text: Binding<String>,
                       keyboard: UIKeyboardType = .default) -> some View {
        TextField("", text: text, prompt: settingsPrompt(placeholder))
            .font(.subheadline)
            .foregroundStyle(Color(R.color.color111118))
            .keyboardType(keyboard)
    }

    // MARK: Data

    private func load() {
        guard !didLoad else { return }
        didLoad = true
        draft = store.business
        let lines = store.business.address
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map(String.init)
        addressLines = (0..<3).map { $0 < lines.count ? lines[$0] : "" }
        if lines.count > 3 {
            addressLines[2] = lines[2...].joined(separator: " ")
        }
        ownerName = storedOwnerName
        businessNumber = storedBusinessNumber
        mobile = storedMobile
    }

    private func loadLogo(from item: PhotosPickerItem?) async {
        guard let item, let data = try? await item.loadTransferable(type: Data.self) else { return }
        draft.logoData = data
    }

    private func save() {
        var profile = draft
        profile.address = addressLines
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .joined(separator: "\n")
        store.business = profile
        storedOwnerName = ownerName
        storedBusinessNumber = businessNumber
        storedMobile = mobile
        app.navi.pop()
    }
}

#if DEBUG
#Preview {
    BusinessInfoScreen()
}
#endif
