//
//  FrameDropEvent.swift
//  FrameWatch
//
//  Created by Leonardo Modro on 06/06/25.
//

import Foundation

/// Represents a single dropped frame event captured by FrameWatch.
public struct FrameDropEvent: Codable, Hashable {
    /// Timestamp of when the drop occurred.
    public let timestamp: Date
    /// Duration of dropped frame
    public let duration: TimeInterval
    /// FPS at the time of drop.
    public let frameRate: Double
    /// Amount of frames dropped
    public let droppedFrames: Int
    /// Screenshot filename (optional).
    public var screenshotFileName: String?
    
    public init(timestamp: Date, duration: TimeInterval, frameRate: Double, droppedFrame: Int, screenshotFileName: String?) {
        self.timestamp = timestamp
        self.duration = duration
        self.frameRate = frameRate
        self.droppedFrames = droppedFrame
        self.screenshotFileName = screenshotFileName
    }
}
