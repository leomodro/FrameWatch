//
//  FrameMonitor.swift
//  FrameWatch
//
//  Created by Leonardo Modro on 04/06/25.
//

import Foundation
import os
import UIKit

final class FrameMonitor {
    static let shared = FrameMonitor()
    
    private var displayLink: CADisplayLink?
    private(set) var lastTimestamp: CFTimeInterval = 0
    private var frameCount = 0

    private var overlay: FPSOverlay?
    
    public var onDrop: ((TimeInterval, Double, Int) -> Void)?
    
    private let logger = Logger(subsystem: "com.leomodro.FrameWatch", category: "FrameMonitor")

    private init() {}

    func start() {
        guard displayLink == nil else { return }
        
        if FrameWatch.configuration.showOverlay {
            DispatchQueue.main.async {
                self.overlay = FPSOverlay()
                self.overlay?.show()
            }
        }

        displayLink = CADisplayLink(target: self, selector: #selector(tick))
        displayLink?.add(to: .main, forMode: .common)
    }

    func stop() {
        displayLink?.invalidate()
        displayLink = nil
        lastTimestamp = 0
        frameCount = 0
        DispatchQueue.main.async {
            self.overlay?.remove()
            self.overlay = nil
        }
    }

    @objc private func tick(link: CADisplayLink) {
        guard lastTimestamp > 0 else {
            lastTimestamp = link.timestamp
            return
        }

        frameCount += 1
        let currentTime = link.timestamp
        let elapsedTime = currentTime - lastTimestamp
        
        if elapsedTime >= 1 {
            let fps = Double(frameCount) / elapsedTime
            let expectedFrames = elapsedTime * Double(FrameWatch.configuration.fpsTarget)
            let droppedFrames = max(Int(expectedFrames.rounded()) - frameCount, 0)

            if FrameWatch.configuration.printFPS {
                logger.info("📋 FPS: \(Int(round(fps))), Dropped Frames: \(droppedFrames)")
            }

            overlay?.update(fps: fps)
            
            if droppedFrames > 0 {
                ScreenshotManager.shared.captureIfNeeded(duration: elapsedTime, frameRate: fps, droppedFrames: droppedFrames)
            }

            frameCount = 0
            lastTimestamp = currentTime
        }
    }
}
