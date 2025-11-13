import SwiftUI
import UIKit
import PhotosUI

class PhotoService: ObservableObject {

    // MARK: - Image Compression

    /// Compress image to specified max size in KB
    func compressImage(_ image: UIImage, maxSizeKB: Int = 500) -> Data? {
        let maxBytes = maxSizeKB * 1024

        // Start with high quality
        var compression: CGFloat = 0.9
        var imageData = image.jpegData(compressionQuality: compression)

        // Reduce size if needed
        if let originalImage = image.resizedToMaxDimension(2000) {
            imageData = originalImage.jpegData(compressionQuality: compression)
        }

        // Progressively reduce quality if still too large
        while let data = imageData, data.count > maxBytes && compression > 0.1 {
            compression -= 0.1
            imageData = image.jpegData(compressionQuality: compression)
        }

        // If still too large, resize further
        if let data = imageData, data.count > maxBytes {
            if let resizedImage = image.resizedToMaxDimension(1000) {
                imageData = resizedImage.jpegData(compressionQuality: 0.7)
            }
        }

        return imageData
    }

    /// Load image from data
    func loadImage(from data: Data) -> UIImage? {
        UIImage(data: data)
    }
}

// MARK: - UIImage Extension

extension UIImage {
    /// Resize image to fit within max dimension while maintaining aspect ratio
    func resizedToMaxDimension(_ maxDimension: CGFloat) -> UIImage? {
        let size = self.size

        if size.width <= maxDimension && size.height <= maxDimension {
            return self
        }

        let aspectRatio = size.width / size.height
        var newSize: CGSize

        if size.width > size.height {
            newSize = CGSize(width: maxDimension, height: maxDimension / aspectRatio)
        } else {
            newSize = CGSize(width: maxDimension * aspectRatio, height: maxDimension)
        }

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resizedImage
    }
}

// MARK: - Photo Picker View

struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: PhotoPicker

        init(_ parent: PhotoPicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.editedImage] as? UIImage {
                parent.image = image
            } else if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - Modern Photo Picker (iOS 16+)

struct ModernPhotoPicker: View {
    @Binding var selectedImage: UIImage?
    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        PhotosPicker(
            selection: $selectedItem,
            matching: .images,
            photoLibrary: .shared()) {
                Label("Choose Photo", systemImage: "photo")
                    .font(Theme.Typography.headline)
                    .foregroundColor(Theme.Colors.primary)
            }
            .onChange(of: selectedItem) { oldValue, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        selectedImage = image
                    }
                }
            }
    }
}