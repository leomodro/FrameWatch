//
//  Diagnostics.swift
//  FrameWatch
//
//  Created by Leonardo Modro on 04/06/25.
//

import Foundation
import OSLog

public struct FrameDropEvent: Codable {
    public let timestamp: Date
    public let duration: TimeInterval
    public let frameRate: Double

    public init(timestamp: Date, duration: TimeInterval, frameRate: Double) {
        self.timestamp = timestamp
        self.duration = duration
        self.frameRate = frameRate
    }
}

public final class Diagnostics {
    public static let shared = Diagnostics()

    private(set) var droppedFrames: [FrameDropEvent] = []
    private let logger = Logger(subsystem: "com.leomodro.FrameWatch", category: "Diagnostics")

    private init() {}

    public func recordDrop(duration: TimeInterval, frameRate: Double) {
        let event = FrameDropEvent(
            timestamp: Date(),
            duration: duration,
            frameRate: frameRate
        )
        droppedFrames.append(event)
        logger.warning("🔻 Frame dropped: duration=\(duration, privacy: .public), fps=\(frameRate, privacy: .public)")
    }

    public func exportJSON() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return try? String(data: encoder.encode(droppedFrames), encoding: .utf8)
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
        droppedFrames.removeAll()
    }
}
