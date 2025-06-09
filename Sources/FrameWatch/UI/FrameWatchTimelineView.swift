//
//  FrameWatchTimelineView.swift
//  FrameWatch
//
//  Created by Leonardo Modro on 05/06/25.
//

import SwiftUI
import Combine

public struct FrameWatchTimelineView: View {
    @State var events: [FrameDropEvent] = []
    @State private var timer: AnyCancellable?
    
    @State private var selectedEvent: FrameDropEvent?
    @State private var selectedIndex: Int?
    @State private var showTooltip = false
    @State private var dismissTask: DispatchWorkItem?

    private let maxBarHeight: CGFloat = 200
    private let tickCount: Int = 5
    private let tooltipDismissDelay: TimeInterval = 2.5
    
    public init(values: [FrameDropEvent]) {
        _events = State(initialValue: values)
    }

    public var body: some View {
        let maxDuration = events.map(\.duration).max() ?? 0.1
        
        NavigationView {
            ScrollView(.vertical) {
                VStack(spacing: 0) {
                    ZStack(alignment: .bottomLeading) {
                        HStack(alignment: .bottom, spacing: 8) {
                            yAxis(maxDuration: maxDuration)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(alignment: .bottom, spacing: 4) {
                                    chart(with: maxDuration)
                                }
                                .padding(.vertical, 15)
                            }
                        }
                        
                        tooltip
                    }
                    .padding()
                    .frame(height: maxBarHeight + 60)
                    
                    if !events.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Screenshots")
                                .font(.title2)
                                .bold()
                                .padding(.leading, 16)
                            screenshotGrid
                        }
                        .padding(.vertical, 24)
                    }
                    
                    Spacer()
                }
            }
            .onAppear {
                timer = Timer.publish(every: 2.0, on: .main, in: .common)
                    .autoconnect()
                    .sink { _ in
                        self.events = Diagnostics.shared.droppedFramesEvent
                    }
            }
            .onDisappear {
                timer?.cancel()
                dismissTask?.cancel()
                FrameMonitor.shared.isPaused(false)
            }
            .navigationTitle("Timeline")
        }
    }
}

// MARK: - View Components
extension FrameWatchTimelineView {
    @ViewBuilder func yAxis(maxDuration: TimeInterval) -> some View {
        VStack(alignment: .trailing, spacing: 0) {
            ForEach((0...tickCount).reversed(), id: \.self) { i in
                let fraction = Double(i) / Double(tickCount)
                let value = fraction * maxDuration
                Text("\(Int(value * 1000)) ms")
                    .font(.caption2)
                    .frame(height: maxBarHeight / CGFloat(tickCount))
            }
        }
    }
    
    @ViewBuilder func chart(with maxDuration: TimeInterval) -> some View {
        ForEach($events, id: \.self) { $event in
            let normalizedHeight = CGFloat(event.duration / maxDuration) * maxBarHeight
            
            RoundedRectangle(cornerRadius: 4)
                .fill(severityColor(for: event.duration))
                .frame(width: 12, height: normalizedHeight)
                .onTapGesture {
                    guard let index = events.firstIndex(of: event) else { return }
                    select(event: event, at: index)
                }
        }
    }
    
    @ViewBuilder var tooltip: some View {
        if let index = selectedIndex, let event = selectedEvent, showTooltip {
            VStack(spacing: 2) {
                Text("\(Int(event.duration * 1000)) ms")
                Text("\(event.droppedFrames) frames")
            }
            .font(.caption2)
            .padding(8)
            .background(Color.black.opacity(0.8))
            .cornerRadius(6)
            .foregroundColor(.white)
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.3), value: showTooltip)
            .offset(x: CGFloat(index) * 16 + 20)
        }
    }
    
    var screenshotGrid: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 0) {
                ForEach($events, id: \.self) { $event in
                    let dir = FileManager.default.frameWatchDirectory
                    let file = dir.appendingPathComponent(event.screenshotFileName ?? "")
                    AsyncThumbnailImageView(fileURL: file)
                        .padding(.leading, 16)
                }
            }
        }
    }
}

// MARK: - Helpers
extension FrameWatchTimelineView {
    private func severityColor(for duration: TimeInterval) -> Color {
        switch duration {
        case 0..<0.05: return Color(UIColor.systemGreen)
        case 0.05..<0.1: return Color(UIColor.systemOrange)
        default: return Color(UIColor.systemRed)
        }
    }
    
    private func select(event: FrameDropEvent, at index: Int) {
        selectedEvent = event
        selectedIndex = index
        withAnimation {
            showTooltip = true
        }
        
        // Cancel any previous auto-dismiss
        dismissTask?.cancel()
        
        // Schedule dismissal
        let task = DispatchWorkItem {
            withAnimation {
                self.showTooltip = false
                self.selectedEvent = nil
                self.selectedIndex = nil
            }
        }
        dismissTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + tooltipDismissDelay, execute: task)
    }
}

#Preview {
    FrameWatchTimelineView(values: [
        FrameDropEvent(timestamp: Date(), duration: 0.04, frameRate: 60, droppedFrame: 0, screenshotFileName: nil),
        FrameDropEvent(timestamp: Date().addingTimeInterval(100), duration: 0.09, frameRate: 30, droppedFrame: 4, screenshotFileName: nil),
        FrameDropEvent(timestamp: Date().addingTimeInterval(200), duration: 0.12, frameRate: 15, droppedFrame: 9, screenshotFileName: nil)
    ])
}
