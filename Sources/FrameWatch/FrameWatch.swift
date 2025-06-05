//
//  FrameWatch.swift
//  FrameWatch
//
//  Created by Leonardo Modro on 04/06/25.
//

import Foundation

public enum FrameWatch {
    public static var configuration = FrameWatchConfiguration()

    public static func start() {
        #if DEBUG
        FrameMonitor.shared.start()
        #endif
    }

    public static func stop() {
        FrameMonitor.shared.stop()
    }
}

