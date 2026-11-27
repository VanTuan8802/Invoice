//
//  PhotoScreen.swift
//  Invoice
//
//  Invoice/Photo: an attached photo with its description and details. With no
//  `photoID` it starts a new photo and opens Invoice/Photo/Options right away.
//

import SwiftUI
import Factory

struct PhotoScreen: View {
    /// Photo on the open document; `nil` adds a new one.
    let photoID: UUID?

    @InjectedObject(\.documentEditor) private var editor: DocumentEditor
    @Injected(\.app) private var app

    @State private var imageData: Data?
    @State private var title = ""
    @State private var detail = ""
    @State private var didLoad = false
    @State private var showOptions = false

    var body: some View {
        VStack(spacing: 0) {
            BasicHeaderView(R.stringLocalizable.doc_photo_title(), showBack: true, backAction: { app.navi.pop() }, trailingView: {
                HeaderTextButton(title: R.stringLocalizable.common_done(), action: save)
            })

            ScrollView {
                VStack(spacing: 30) {
                    photo
                    fields
                }
                .padding(.horizontal, 16)
                .padding(.top, 7)
                .padding(.bottom, 24)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .groupedScreenBackground()
        .photoSourcePicker(isPresented: $showOptions) { data in
            imageData = data
        }
        .onAppear(perform: load)
        .trackScreen(.documentPhoto)
    }

    private var photo: some View {
        Button {
            showOptions = true
        } label: {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(.systemGray5))
                .frame(width: 224, height: 283)
                .overlay {
                    if let imageData, let image = UIImage(data: imageData) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image(R.image.ic_document_image_add)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var fields: some View {
        VStack(spacing: 16) {
            field(R.stringLocalizable.doc_photo_description(), text: $title)
            DocumentRowDivider()
            field(R.stringLocalizable.doc_photo_details(), text: $detail)
        }
        .documentCard()
    }

    private func field(_ placeholder: String, text: Binding<String>) -> some View {
        TextField("", text: text, prompt: Text(placeholder).foregroundColor(Color(R.color.colorA5A5B0)))
            .font(.body)
            .foregroundStyle(Color(R.color.color111118))
    }

    // MARK: - Data

    private func load() {
        guard !didLoad else { return }
        didLoad = true
        if let photoID, let existing = editor.document.photos.first(where: { $0.id == photoID }) {
            imageData = existing.imageData
            title = existing.title
            detail = existing.detail
        } else {
            showOptions = true
        }
    }

    private func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDetail = detail.trimmingCharacters(in: .whitespacesAndNewlines)
        if let photoID, let index = editor.document.photos.firstIndex(where: { $0.id == photoID }) {
            editor.document.photos[index].title = trimmedTitle
            editor.document.photos[index].detail = trimmedDetail
            editor.document.photos[index].imageData = imageData
        } else if imageData != nil {
            editor.document.photos.append(DocumentPhoto(title: trimmedTitle, detail: trimmedDetail, imageData: imageData))
        }
        app.navi.pop()
    }
}
