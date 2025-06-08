//
//  AsyncThumbnailImageView.swift
//  FrameWatch
//
//  Created by Leonardo Modro on 08/06/25.
//

import SwiftUI

struct AsyncThumbnailImageView: View {
    @StateObject private var loader: ThumbnailImageLoader

    init(fileURL: URL, maxSize: CGSize = CGSize(width: 150, height: 300)) {
        _loader = StateObject(wrappedValue: ThumbnailImageLoader(fileURL: fileURL, maxSize: maxSize))
    }

    var body: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(ProgressView())
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
