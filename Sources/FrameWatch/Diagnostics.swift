//
//  Diagnostics.swift
//  FrameWatch
//
//  Created by Leonardo Modro on 04/06/25.
//

import Foundation
import OSLog
import UIKit

/// Diagnostics is a logging utility that stores frame drop events in memory for analytics or debugging.
final class Diagnostics {
    /// Singleton instance for accessing logged diagnostics.
    public static let shared = Diagnostics()

    /// All recorded frame drop events.
    private(set) var droppedFramesEvent: [FrameDropEvent] = []
    private let logger = Logger(subsystem: "com.leomodro.FrameWatch", category: "Diagnostics")

    private init() {}

    /// Records a new dropped frame event.
    ///
    /// - Parameter date: The date when dropped frame event happened
    /// - Parameter duration: How long dropped frame happened
    /// - Parameter frameRate: Amount of frames
    /// - Parameter droppedFrames: Amount of dropped frames
    public func recordDrop(_ date: Date, duration: TimeInterval, frameRate: Double, droppedFrames: Int) {
        let event = FrameDropEvent(
            timestamp: date,
            duration: duration,
            frameRate: frameRate,
            droppedFrame: droppedFrames,
            screenshotFileName: nil
        )
        droppedFramesEvent.append(event)
        logger.warning("🔻 Frame dropped: duration=\(duration, privacy: .public), fps=\(frameRate, privacy: .public)")
    }
    
    /// Update desired event to apply screenshot file name
    /// - Parameters:
    ///   - timestamp: Date when event happened
    ///   - fileName: Screenshot file name
    public func updateEvent(with timestamp: Date, and fileName: String?) {
        guard let index = droppedFramesEvent.firstIndex(where: { $0.timestamp == timestamp }) else { return }
        droppedFramesEvent[index].screenshotFileName = fileName
    }
    
    /// Find specific event given a date
    /// - Parameter timestamp: Date when event happened
    /// - Returns: Optional `FrameDropEvent`
    public func findEvent(with timestamp: Date) -> FrameDropEvent? {
        droppedFramesEvent.first { $0.timestamp == timestamp }
    }

    /// Clears all stored events.
    public func clear() {
        droppedFramesEvent.removeAll()
    }
}
