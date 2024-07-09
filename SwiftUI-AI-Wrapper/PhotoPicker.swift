// AI Wrapper SwiftUI
// Created by Adam Lyttle on 7/9/2024

// Make cool stuff and share your build with me:

//  --> x.com/adamlyttleapps
//  --> github.com/adamlyttleapps

import SwiftUI
import PhotosUI

struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var selectedImage: UIImage?
    @Binding var filename: String?

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())//PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPicker

        init(_ parent: PhotoPicker) {
            self.parent = parent
        }
        
        
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.isPresented = false

            if let result = results.first {
                let assetID = result.assetIdentifier
                let options = PHImageRequestOptions()
                options.isSynchronous = false
                options.deliveryMode = .highQualityFormat
                options.isNetworkAccessAllowed = true

                if let assetID = assetID {
                    PHPhotoLibrary.requestAuthorization { status in
                        if status == .authorized {
                            let asset = PHAsset.fetchAssets(withLocalIdentifiers: [assetID], options: nil).firstObject
                            PHImageManager.default().requestImageDataAndOrientation(for: asset!, options: options) { imageData, dataUTI, orientation, info in
                                if let imageData = imageData {
                                    DispatchQueue.main.async {
                                        self.parent.selectedImage = UIImage(data: imageData)
                                        // Get metadata
                                        if let imageSource = CGImageSourceCreateWithData(imageData as CFData, nil),
                                           let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [CFString: Any] {
                                            // Get the original file format
                                            let fileFormat = imageProperties[kCGImageSourceTypeIdentifierHint]
                                            print("File format: \(fileFormat ?? "Unknown")")

                                            // Get the resolution
                                            let width = imageProperties[kCGImagePropertyPixelWidth] ?? "Unknown"
                                            let height = imageProperties[kCGImagePropertyPixelHeight] ?? "Unknown"
                                            print("Resolution: \(width) x \(height)")

                                            // Get the file size
                                            let fileSize = imageProperties[kCGImagePropertyFileSize] ?? "Unknown"
                                            print("File size: \(fileSize) bytes")
                                            
                                            
                                            // Get the filename
                                            let resources = PHAssetResource.assetResources(for: asset!)
                                            if let resource = resources.first {
                                                let filename = resource.originalFilename
                                                print("Filename: \(filename)")
                                                DispatchQueue.main.async {
                                                    self.parent.filename = filename
                                                }
                                            }
                                            
                                        }
                                    }
                                }
                            }
                        } else {
                            print("Authorization not granted")
                        }
                    }
                }
            }
        }




    }
}
