//
//  FrameWatch.swift
//  FrameWatch
//
//  Created by Leonardo Modro on 04/06/25.
//

import Foundation
import os

public enum FrameWatch {
    public static var configuration = FrameWatchConfiguration()
    
    private static let logger = Logger(subsystem: "com.leomodro.FrameWatch", category: "FrameWatch")

    public static func start() {
        #if DEBUG
        FrameMonitor.shared.start()
        logger.info("FrameWatch started with FPS target: \(configuration.fpsTarget)")
        #endif
    }

    public static func stop() {
        FrameMonitor.shared.stop()
    }
}

