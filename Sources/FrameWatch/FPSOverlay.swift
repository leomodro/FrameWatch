//
//  FPSOverlay.swift
//  FrameWatch
//
//  Created by Leonardo Modro on 04/06/25.
//

import UIKit

public final class FPSOverlay: UILabel {
    private var containerWindow: UIWindow?

    init() {
        super.init(frame: CGRect(x: 10, y: 10, width: 80, height: 50))
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        self.font = UIFont.monospacedDigitSystemFont(ofSize: 13, weight: .medium)
        self.textColor = .label
        self.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.7)
        self.textAlignment = .center
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        self.isUserInteractionEnabled = true
    }

    func show() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.tryShow()
        }
        
        NotificationCenter.default.addObserver(forName: UIScene.didActivateNotification, object: nil, queue: .main) { _ in
            self.tryShow()
        }
    }

    func update(fps: Double) {
        self.text = "FPS: \(Int(round(fps)))"
        self.textColor = FrameWatch.configuration.color(for: fps)
    }

    func remove() {
        removeFromSuperview()
        containerWindow?.isHidden = true
        containerWindow = nil
    }
    
    private func tryShow() {
        guard superview == nil else { return }
        guard let windowScene = UIApplication.shared
            .connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
            let window = windowScene.windows.first else {
            return
        }
        window.windowLevel = .alert + 1
        window.isHidden = false
        self.frame.origin = .init(x: 10, y: window.safeAreaInsets.top)
        window.addSubview(self)
        containerWindow = window
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        self.addGestureRecognizer(pan)
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        self.center = CGPoint(x: self.center.x + translation.x, y: self.center.y + translation.y)
        gesture.setTranslation(.zero, in: self.superview)
    }
}
