//
//  FPSOverlay.swift
//  FrameWatch
//
//  Created by Leonardo Modro on 04/06/25.
//

import UIKit

/// A floating HUD overlay that displays FPS and provides a toggleable timeline view.
final class FPSOverlay: UIView {
    private var containerWindow: UIWindow?
    private var fpsLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.monospacedDigitSystemFont(ofSize: 15, weight: .medium)
        lbl.textAlignment = .center
        return lbl
    }()

    init() {
        super.init(frame: CGRect(x: 10, y: 10, width: 100, height: 60))
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        self.backgroundColor = UIColor.clear //UIColor.black.withAlphaComponent(0.7)
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        self.isUserInteractionEnabled = true
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.systemThinMaterialDark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurEffectView)
        
        fpsLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(fpsLabel)
        NSLayoutConstraint.activate([
            fpsLabel.heightAnchor.constraint(equalTo: self.heightAnchor),
            fpsLabel.widthAnchor.constraint(equalTo: self.widthAnchor)
        ])

    }

    /// Shows the overlay in the current key window.
    func show() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.tryShow()
        }
        
        NotificationCenter.default.addObserver(forName: UIScene.didActivateNotification, object: nil, queue: .main) { _ in
            self.tryShow()
        }
    }

    /// Updates the FPS label and adjusts its color based on configured threshold.
    func update(fps: Double) {
        fpsLabel.text = "FPS: \(Int(round(fps)))"
        fpsLabel.textColor = FrameWatch.configuration.color(for: fps)
    }

    /// Hides the overlay from the screen.
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
