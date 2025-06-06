//
//  Diagnostics.swift
//  FrameWatch
//
//  Created by Leonardo Modro on 04/06/25.
//

import Foundation
import OSLog
import UIKit

public struct FrameDropEvent: Codable {
    public let timestamp: Date
    public let duration: TimeInterval
    public let frameRate: Double
    public let droppedFrames: Int
    public let screenshotPath: String?
    
    public init(timestamp: Date, duration: TimeInterval, frameRate: Double, droppedFrame: Int, screenshotPath: String?) {
        self.timestamp = timestamp
        self.duration = duration
        self.frameRate = frameRate
        self.droppedFrames = droppedFrame
        self.screenshotPath = screenshotPath
    }
}

public final class Diagnostics {
    public static let shared = Diagnostics()

    private(set) var droppedFramesEvent: [FrameDropEvent] = []
    private let logger = Logger(subsystem: "com.leomodro.FrameWatch", category: "Diagnostics")

    private init() {}

    public func recordDrop(duration: TimeInterval, frameRate: Double, droppedFrames: Int) {
        let screenshotPath = captureScreenshot()
        
        let event = FrameDropEvent(
            timestamp: Date(),
            duration: duration,
            frameRate: frameRate,
            droppedFrame: droppedFrames,
            screenshotPath: screenshotPath
        )
        droppedFramesEvent.append(event)
        logger.warning("🔻 Frame dropped: duration=\(duration, privacy: .public), fps=\(frameRate, privacy: .public)")
    }

    public func exportJSON() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return try? String(data: encoder.encode(droppedFramesEvent), encoding: .utf8)
    }

    public func exportToFile(filename: String = "frame_drops.json") -> URL? {
        guard let json = exportJSON() else { return nil }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        do {
            try json.write(to: url, atomically: true, encoding: .utf8)
            logger.info("✅ Exported frame drop diagnostics to file at \(url.path, privacy: .public)")
            return url
        } catch {
            logger.error("❌ Failed to write diagnostics file: \(error.localizedDescription, privacy: .public)")
            return nil
        }
    }

    public func clear() {
        droppedFramesEvent.removeAll()
    }
    
    private func captureScreenshot() -> String? {
        let renderer = UIGraphicsImageRenderer(bounds: UIScreen.main.bounds)
        let image = renderer.image { ctx in
            UIApplication.shared.windows.first?.layer.render(in: ctx.cgContext)
        }
        let filename = "screenshot_\(Date().timeIntervalSince1970).png"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        do {
            try image.pngData()?.write(to: url)
            logger.info("✅ Saved screenshot: \(url.path, privacy: .public)")
            return url.path
        } catch {
            logger.error("❌ Failed to save screenshot: \(error.localizedDescription, privacy: .public)")
            return nil
        }
    }
}
