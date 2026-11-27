//
//  PhotoSourcePicker.swift
//  Invoice
//
//  Invoice/Photo/Options: "Take photo" / "Select photos" sheet, then the camera or
//  the photo library. Hands back the picked image as JPEG data.
//

import SwiftUI
import PhotosUI

extension View {
    func photoSourcePicker(isPresented: Binding<Bool>, onPick: @escaping (Data) -> Void) -> some View {
        modifier(PhotoSourcePickerModifier(isPresented: isPresented, onPick: onPick))
    }
}

private struct PhotoSourcePickerModifier: ViewModifier {
    @Binding var isPresented: Bool
    let onPick: (Data) -> Void

    @State private var showLibrary = false
    @State private var showCamera = false
    @State private var libraryItem: PhotosPickerItem?

    /// The camera needs hardware and an `NSCameraUsageDescription`; otherwise fall back to the library.
    private var canUseCamera: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
            && Bundle.main.object(forInfoDictionaryKey: "NSCameraUsageDescription") != nil
    }

    func body(content: Content) -> some View {
        content
            .optionsSheet(isPresented: $isPresented) {
                Button(R.stringLocalizable.doc_take_photo()) {
                    if canUseCamera { showCamera = true } else { showLibrary = true }
                }
                Button(R.stringLocalizable.doc_select_photos()) { showLibrary = true }
            }
            .photosPicker(isPresented: $showLibrary, selection: $libraryItem, matching: .images)
            .onChange(of: libraryItem) { item in
                guard let item else { return }
                Task {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let jpeg = UIImage(data: data)?.jpegData(compressionQuality: 0.85) {
                        await MainActor.run { onPick(jpeg) }
                    }
                    await MainActor.run { libraryItem = nil }
                }
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraPicker { image in
                    if let jpeg = image.jpegData(compressionQuality: 0.85) { onPick(jpeg) }
                }
                .ignoresSafeArea()
            }
    }
}

/// `UIImagePickerController` in camera mode.
private struct CameraPicker: UIViewControllerRepresentable {
    let onImage: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ controller: UIImagePickerController, context: Context) {}

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        private let parent: CameraPicker

        init(_ parent: CameraPicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage { parent.onImage(image) }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
