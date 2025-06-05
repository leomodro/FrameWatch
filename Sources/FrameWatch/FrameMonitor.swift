//
//  FrameMonitor.swift
//  FrameWatch
//
//  Created by Leonardo Modro on 04/06/25.
//

import Foundation
import UIKit

final class FrameMonitor {
    static let shared = FrameMonitor()
    
    private var displayLink: CADisplayLink?
    private var lastTimestamp: CFTimeInterval = 0
    private var frameCount = 0

    private var overlay: FPSOverlay?

    private init() {}

    func start() {
        guard displayLink == nil else { return }

        if FrameWatch.configuration.showOverlay {
            overlay = FPSOverlay()
            overlay?.show()
        }

        displayLink = CADisplayLink(target: self, selector: #selector(tick))
        displayLink?.add(to: .main, forMode: .common)
    }

    func stop() {
        displayLink?.invalidate()
        displayLink = nil
        overlay?.remove()
        overlay = nil
    }

    @objc private func tick(link: CADisplayLink) {
        guard lastTimestamp > 0 else {
            lastTimestamp = link.timestamp
            return
        }

        frameCount += 1
        let delta = link.timestamp - lastTimestamp

        if delta >= 1 {
            let fps = Double(frameCount) / delta
            if FrameWatch.configuration.printFPS {
                print("[FrameWatch] FPS: \(Int(round(fps)))")
            }
            overlay?.update(fps: fps)
            frameCount = 0
            lastTimestamp = link.timestamp
        }
    }
}
