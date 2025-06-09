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
    
    private let logger = Logger(subsystem: "com.leomodro.FrameWatch", category: "FrameMonitor")
    private(set) var displayLink: CADisplayLink?
    private(set) var lastTimestamp: CFTimeInterval = 0
    private var frameCount = 0
    private var overlay: FPSOverlay?
    public var onDrop: ((TimeInterval, Int) -> Void)?

    private init() {}
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func start() {
        NotificationCenter.default.addObserver(self, selector: #selector(appEnteredBackground), name: .background, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appEnteredForeground), name: .foreground, object: nil)
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
        resetTiming()
        DispatchQueue.main.async {
            self.overlay?.remove()
            self.overlay = nil
        }
    }
    
    func isPaused(_ isPaused: Bool) {
        DispatchQueue.global(qos: .background).async {
            self.resetTiming()
            self.displayLink?.isPaused = isPaused
        }
    }
    
    private func resetTiming() {
        frameCount = 0
        lastTimestamp = 0
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
                self.onDrop?(lastTimestamp, droppedFrames)
                ScreenshotManager.shared.captureIfNeeded(duration: elapsedTime, frameRate: fps, droppedFrames: droppedFrames)
            }

            frameCount = 0
            lastTimestamp = currentTime
        }
    }
    
    @objc private func appEnteredForeground() {
        guard displayLink != nil else { return }
        logger.debug("App entered foreground — Resuming monitoring")
        isPaused(false)
    }
    
    @objc private func appEnteredBackground() {
        guard displayLink != nil else { return }
        logger.debug("App entered background — Pausing monitoring")
        isPaused(true)
    }
}
