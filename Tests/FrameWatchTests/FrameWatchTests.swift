import Testing
@testable import FrameWatch
import UIKit

@Suite("Configuration")
struct ConfigurationTests {
    @Test("Custom Configuration") func appliesCorrectly() {
        let config = Configuration(fpsTarget: 30, screenshotDirectory: URL(string: "file:///Test"))
        FrameWatch.configuration = config
        
        #expect(FrameWatch.configuration.frameDropThreshold == 1.0 / 30.0)
        #expect(FrameWatch.configuration.printFPS)
        #expect(FrameWatch.configuration.showOverlay)
        #expect(FrameWatch.configuration.screenshotDirectory == URL(string: "file:///Test"))
        #expect(FileManager.default.frameWatchDirectory == URL(string: "file:///Test/FrameWatch/"))
    }
    
    @Test("Defaults") func defaultsApplied() {
        #expect(Configuration.default.fpsTarget == 50)
        #expect(Configuration.lowPower.fpsTarget == 30)
        #expect(Configuration.highPerformance.fpsTarget == 60)
    }
    
    @Test("Color per FPS") func colorPerFPS() {
        let green = Configuration.default.color(for: 50)
        let red = Configuration.default.color(for: 15)
        let orange = Configuration.default.color(for: 40)
        
        #expect(green == UIColor.systemGreen)
        #expect(red == UIColor.systemRed)
        #expect(orange == UIColor.systemOrange)
    }
}

@Suite("Diagnostics")
struct DiagnosticsTests {
    @Test("Record Drop") func recordDrop() {
        Diagnostics.shared.clear()
        Diagnostics.shared.recordDrop(Date(), duration: 0.18, frameRate: 55, droppedFrames: 9)
        
        #expect(Diagnostics.shared.droppedFramesEvent.count == 1)
        #expect(Diagnostics.shared.droppedFramesEvent.first?.droppedFrames == 9)
    }
    
    @Test("Update Event") func updateEvent() {
        Diagnostics.shared.clear()
        Diagnostics.shared.recordDrop(Date(), duration: 0.18, frameRate: 55, droppedFrames: 9)
        #expect(Diagnostics.shared.droppedFramesEvent.count == 1)
        
        Diagnostics.shared.updateEvent(with: Diagnostics.shared.droppedFramesEvent[0].timestamp, and: "test-name")
        let eventUpdated = Diagnostics.shared.findEvent(with: Diagnostics.shared.droppedFramesEvent[0].timestamp)
        
        #expect(eventUpdated?.screenshotFileName == "test-name")
    }
}

@Suite("FrameMonitor", .serialized)
struct FrameMonitorTests {
    @Test("Start and Stop") func startAndStop() async throws {
        FrameMonitor.shared.start()
        
        try await Task.sleep(nanoseconds: 2_000_000_000)
        #expect(FrameMonitor.shared.lastTimestamp != 0)
        
        FrameWatch.stop()
    }
    
    @Test("Background") func handleBackground() async throws {
        FrameMonitor.shared.start()
        
        // Simulate backgrounding
        NotificationCenter.default.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
        try await Task.sleep(nanoseconds: 1_000_000_000)
        #expect(FrameMonitor.shared.displayLink?.isPaused == true)
        
        FrameMonitor.shared.stop()
    }
    
    @Test("Foreground") func handleForeground() async throws {
        FrameMonitor.shared.start()
        
        NotificationCenter.default.post(name: UIApplication.willEnterForegroundNotification, object: nil)
        try await Task.sleep(nanoseconds: 1_000_000_000)
        #expect(FrameMonitor.shared.displayLink?.isPaused == false)
        
        FrameMonitor.shared.stop()
    }
}
