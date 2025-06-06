//
//  FrameWatchConfiguration.swift
//  FrameWatch
//
//  Created by Leonardo Modro on 04/06/25.
//

import Foundation

public struct FrameWatchConfiguration {
    public var fpsTarget: Int = 50
    public var printFPS: Bool = true
    public var showOverlay: Bool = true
    
    public var frameDropThreshold: Double {
        return 1.0 / Double(fpsTarget)
    }

    public init(fpsTarget: Int = 50, printFPS: Bool = true, showOverlay: Bool = true) {
        self.fpsTarget = fpsTarget
        self.printFPS = printFPS
        self.showOverlay = showOverlay
    }
    
    // MARK: - Presets
    
    /// Balanced for modern devices (50 FPS budget)
    public static var `default`: FrameWatchConfiguration {
        FrameWatchConfiguration(fpsTarget: 50)
    }
    
    /// For performance-intensive or animation-heavy views (60 FPS target)
    public static var highPerformance: FrameWatchConfiguration {
        FrameWatchConfiguration(fpsTarget: 60)
    }
    
    /// For low-end device simulation or relaxed frame tolerance (30 FPS target)
    public static var lowPower: FrameWatchConfiguration {
        FrameWatchConfiguration(fpsTarget: 30)
    }
}
