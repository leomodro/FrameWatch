//
//  FPSOverlay.swift
//  FrameWatch
//
//  Created by Leonardo Modro on 04/06/25.
//

import UIKit

final class FPSOverlay: UILabel {
    private var containerWindow: UIWindow?

    init() {
        super.init(frame: CGRect(x: 10, y: 10, width: 60, height: 24))
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        self.textColor = .white
        self.font = UIFont.monospacedDigitSystemFont(ofSize: 13, weight: .medium)
        self.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        self.textAlignment = .center
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
    }

    func show() {
        let window = UIWindow(frame: frame)
        window.rootViewController = UIViewController()
        window.windowLevel = .alert + 1
        window.isHidden = false
        window.addSubview(self)
        containerWindow = window
    }

    func update(fps: Double) {
        self.text = "FPS: \(Int(round(fps)))"
        self.textColor = fps >= 55 ? .green : (fps >= 45 ? .orange : .red)
    }

    func remove() {
        removeFromSuperview()
        containerWindow?.isHidden = true
        containerWindow = nil
    }
}
