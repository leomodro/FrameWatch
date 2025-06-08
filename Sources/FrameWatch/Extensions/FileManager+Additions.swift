//
//  FileManager+Additions.swift
//  FrameWatch
//
//  Created by Leonardo Modro on 08/06/25.
//

import Foundation

public extension FileManager {
    var frameWatchDirectory: URL {
        let baseDir = FrameWatch.configuration.screenshotDirectory ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first ?? FileManager.default.temporaryDirectory
        let frameWatchDir = baseDir.appendingPathComponent("FrameWatch", isDirectory: true)

        if !FileManager.default.fileExists(atPath: frameWatchDir.path) {
            try? FileManager.default.createDirectory(at: frameWatchDir, withIntermediateDirectories: true)
        }

        return frameWatchDir
    }
}
