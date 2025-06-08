//
//  ScreenshotManager.swift
//  FrameWatch
//
//  Created by Leonardo Modro on 06/06/25.
//

import UIKit
import os

final class ScreenshotManager {
    static let shared = ScreenshotManager()
    private let logger = Logger(subsystem: "com.leomodro.FrameWatch", category: "ScreenshotManager")

    private var lastCaptureTime: TimeInterval = 0
    private let minInterval: TimeInterval = 2.0

    private init() {}

    func captureIfNeeded(duration: TimeInterval, frameRate: Double, droppedFrames: Int) {
        let now = Date()
        let timestamp = now.timeIntervalSince1970
        Diagnostics.shared.recordDrop(now, duration: duration, frameRate: frameRate, droppedFrames: droppedFrames)
        
        guard FrameWatch.configuration.shouldCaptureScreenshot else { return }
        guard timestamp - lastCaptureTime >= minInterval else { return }

        lastCaptureTime = timestamp
        captureScreenshot(timestamp: timestamp, date: now, fps: frameRate, droppedFrames: droppedFrames)
    }

    private func captureScreenshot(timestamp: TimeInterval, date: Date, fps: Double, droppedFrames: Int) {
        guard let window = UIApplication.shared.windows.first(where: \.isKeyWindow) else { return }

        DispatchQueue.main.async {
            let renderer = UIGraphicsImageRenderer(size: window.bounds.size)
            let image = renderer.image { _ in
                window.drawHierarchy(in: window.bounds, afterScreenUpdates: false)
            }

            DispatchQueue.global(qos: .background).async {
                let filenameBase = "framewatch_\(Int(timestamp))"
                let imageName = filenameBase + ".jpg"
                let jsonName = filenameBase + ".json"

                let directory = FileManager.default.frameWatchDirectory
                let imageURL = directory.appendingPathComponent(imageName)
                let jsonURL = directory.appendingPathComponent(jsonName)

                do {
                    if let data = image.jpegData(compressionQuality: 0.7) {
                        try data.write(to: imageURL)
                    }

                    Diagnostics.shared.updateEvent(with: date, and: imageName)
                    if let event = Diagnostics.shared.findEvent(with: date) {
                        let metadata = try JSONEncoder().encode(event)
                        try metadata.write(to: jsonURL)
                    }
                    self.logger.debug("📸 Saved screenshot and metadata at \(imageURL)")
                } catch {
                    self.logger.error("❌ Failed to save screenshot or metadata: \(error.localizedDescription)")
                }
            }
        }
    }
}
