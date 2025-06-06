//
//  FrameDropEvent.swift
//  FrameWatch
//
//  Created by Leonardo Modro on 06/06/25.
//

import Foundation

public struct FrameDropEvent: Codable {
    public let timestamp: Date
    public let duration: TimeInterval
    public let frameRate: Double
    public let droppedFrames: Int
    public var screenshotFileName: String?
    
    public init(timestamp: Date, duration: TimeInterval, frameRate: Double, droppedFrame: Int, screenshotFileName: String?) {
        self.timestamp = timestamp
        self.duration = duration
        self.frameRate = frameRate
        self.droppedFrames = droppedFrame
        self.screenshotFileName = screenshotFileName
    }
}
