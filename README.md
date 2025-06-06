# FrameWatch 🖼️📉

**Real-time frame drop and FPS monitor for iOS apps.**

FrameWatch helps you spot UI performance issues like dropped frames, stutter, and rendering hitches — without launching Instruments. Perfect for adding to your development builds to catch layout and animation regressions before release.

## 📦 Features

* ✅ Real-time FPS counter
* ✅ Detect and log dropped frames
* ✅ Configurable frame threshold
* ✅ Optional floating overlay HUD
* ✅ Zero dependencies — Swift Package Manager native
* ✅ Debug-only usage (safe for production)

---

## 🚀 Getting Started

### ✅ Install via Swift Package Manager

```swift
.package(url: "https://github.com/yourname/FrameWatch.git", from: "0.1.0")
```

---

## 🧪 Usage

```swift
import FrameWatch

@main
struct MyApp: App {
    init() {
        FrameWatch.configuration.printFPS = true
        FrameWatch.configuration.showOverlay = true
        FrameWatch.start()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

---

## ⚙️ Configuration

Customize how FrameWatch behaves:

```swift
FrameWatch.configuration = .init(
    frameDropThreshold: 1.0 / 50.0, // 50 FPS target
    printFPS: true,                 // Log FPS to console
    showOverlay: true              // Show on-screen overlay
)
```

You can also use convenience presets:

```swift
// 🎯 Default (50 FPS target)
FrameWatch.configuration = .default

// 🚀 High Performance (60 FPS target)
FrameWatch.configuration = .highPerformance

// 🔋 Low Power Mode (30 FPS target)
FrameWatch.configuration = .lowPower
```

---

## 🖼️ Overlay Example

---

## 📜 License

FrameWatch is released under the [MIT License](LICENSE).

---

## 🧠 Roadmap Highlights

* View hierarchy snapshots on frame drops
* Export metrics to JSON or remote
* SwiftUI overlay integration
* Scroll jank detector
* Performance timeline view

---
