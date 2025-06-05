//
//  FrameWatchConfiguration.swift
//  FrameWatch
//
//  Created by Leonardo Modro on 04/06/25.
//

import Foundation

public struct FrameWatchConfiguration {
    public var frameDropThreshold: Double = 1.0 / 50.0
    public var printFPS: Bool = false
    public var showOverlay: Bool = false

    public init() {}
}
