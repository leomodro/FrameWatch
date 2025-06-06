//
//  Configuration.swift
//  FrameWatch
//
//  Created by Leonardo Modro on 04/06/25.
//

import UIKit

/// Configuration settings for FrameWatch.
public struct Configuration {
    /// Desired FPS target. Default is 50
    public var fpsTarget: Int = 50
    /// Whether FrameWatch should log to console FPS information
    public var printFPS: Bool = true
    /// Whether FrameWatch will show overlay with realtime FPS information
    public var showOverlay: Bool = true
    /// Whether to capture screenshots on frame drops (default: true)
    public var captureScreenshots: Bool = true
    /// Directory where screenshots should be saved (default: temporary)
    public var screenshotDirectory: URL? = nil

    public var frameDropThreshold: Double {
        return 1.0 / Double(fpsTarget)
    }

    /// Initializes a new configuration.
    ///
    /// - Parameters:
    ///   - fpsTarget: Desired FPS target
    ///   - printFPS: Enable console logging.
    ///   - showOverlay: Show the overlay HUD.
    public init(fpsTarget: Int = 50, printFPS: Bool = true, showOverlay: Bool = true) {
        self.fpsTarget = fpsTarget
        self.printFPS = printFPS
        self.showOverlay = showOverlay
    }
    
    // MARK: - Presets
    
    /// Balanced for modern devices (50 FPS budget)
    public static var `default`: Configuration {
        Configuration(fpsTarget: 50)
    }
    
    /// For performance-intensive or animation-heavy views (60 FPS target)
    public static var highPerformance: Configuration {
        Configuration(fpsTarget: 60)
    }
    
    /// For low-end device simulation or relaxed frame tolerance (30 FPS target)
    public static var lowPower: Configuration {
        Configuration(fpsTarget: 30)
    }
    
    // MARK: - Helpers
    public func color(for fps: Double) -> UIColor {
        let percentage = fps / Double(fpsTarget)
        
        switch percentage {
        case let p where p >= 0.9:
            return .systemGreen
        case let p where p >= 0.75:
            return .systemOrange
        default:
            return .systemRed
        }
    }
}
