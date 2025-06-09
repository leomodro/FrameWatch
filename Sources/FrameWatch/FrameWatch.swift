//
//  FrameWatch.swift
//  FrameWatch
//
//  Created by Leonardo Modro on 04/06/25.
//

import Foundation
import os
import UIKit

/// FrameWatch is the main entry point for enabling frame performance monitoring in your app.
public enum FrameWatch {
    /// The current configuration used by FrameWatch.
    ///
    /// Customize this before calling `start()`. Modifying it at runtime updates behavior dynamically.
    public static var configuration = Configuration()
    
    private static let logger = Logger(subsystem: "com.leomodro.FrameWatch", category: "FrameWatch")

    /// Starts monitoring FPS and dropped frames.
    ///
    /// You should call this early in your app’s lifecycle (e.g., `AppDelegate`, `@main`, or `SceneDelegate`).
    public static func start() {
        #if DEBUG
        FrameMonitor.shared.start()
        logger.info("🖼️ FrameWatch started with FPS target: \(configuration.fpsTarget)")
        #endif
    }

    public static func stop() {
        FrameMonitor.shared.stop()
    }
}

