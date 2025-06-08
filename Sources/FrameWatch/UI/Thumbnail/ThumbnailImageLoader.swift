//
//  ThumbnailImageLoader.swift
//  FrameWatch
//
//  Created by Leonardo Modro on 08/06/25.
//

import SwiftUI
import UIKit

final class ThumbnailImageLoader: ObservableObject {
    @Published var image: UIImage?

    init(fileURL: URL, maxSize: CGSize) {
        loadThumbnail(from: fileURL, maxSize: maxSize)
    }

    private func loadThumbnail(from url: URL, maxSize: CGSize) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else { return }
            let options: [CFString: Any] = [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceThumbnailMaxPixelSize: max(maxSize.width, maxSize.height),
                kCGImageSourceCreateThumbnailWithTransform: true
            ]
            guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else { return }

            let uiImage = UIImage(cgImage: cgImage)
            DispatchQueue.main.async {
                self.image = uiImage
            }
        }
    }
}
