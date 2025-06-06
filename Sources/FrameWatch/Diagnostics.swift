//
//  Diagnostics.swift
//  FrameWatch
//
//  Created by Leonardo Modro on 04/06/25.
//

import Foundation
import OSLog
import UIKit

public final class Diagnostics {
    public static let shared = Diagnostics()

    private(set) var droppedFramesEvent: [FrameDropEvent] = []
    private let logger = Logger(subsystem: "com.leomodro.FrameWatch", category: "Diagnostics")

    private init() {}

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
    
    public func updateEvent(with timestamp: Date, and fileName: String?) {
        guard let index = droppedFramesEvent.firstIndex(where: { $0.timestamp == timestamp }) else { return }
        droppedFramesEvent[index].screenshotFileName = fileName
    }
    
    public func findEvent(with timestamp: Date) -> FrameDropEvent? {
        droppedFramesEvent.first { $0.timestamp == timestamp }
    }

    public func clear() {
        droppedFramesEvent.removeAll()
    }
}
