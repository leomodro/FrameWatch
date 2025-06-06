//
//  FPSTimelineView.swift
//  FrameWatch
//
//  Created by Leonardo Modro on 05/06/25.
//

import SwiftUI
import Combine

public struct FrameWatchTimelineView: View {
    @State var events: [FrameDropEvent] = []
    @State private var timer: AnyCancellable?
    
    public init(values: [FrameDropEvent]) {
        _events = State(initialValue: values)
    }

    public var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(events.indices, id: \.self) { i in
                    let event = events[i]
                    RoundedRectangle(cornerRadius: 5)
                        .fill(severityColor(for: event.duration))
                        .frame(width: 10, height: CGFloat(event.duration * 1000))
                        .onTapGesture {
                            print("Dropped frames \(event.droppedFrames)")
                        }
                }
            }
            .padding()
            .onAppear {
                timer = Timer.publish(every: 2.0, on: .main, in: .common)
                    .autoconnect()
                    .sink { _ in
                        self.events = Diagnostics.shared.droppedFramesEvent
                    }
            }
            .onDisappear {
                timer?.cancel()
            }
        }
    }

    func severityColor(for duration: TimeInterval) -> Color {
        switch duration {
        case 0..<0.05: return .green
        case 0.05..<0.1: return .yellow
        default: return .red
        }
    }
}

#Preview {
    FrameWatchTimelineView(values: [
        FrameDropEvent(timestamp: Date(), duration: 0.016, frameRate: 60, droppedFrame: 0, screenshotFileName: nil),
        FrameDropEvent(timestamp: Date(), duration: 0.09, frameRate: 30, droppedFrame: 4, screenshotFileName: nil),
        FrameDropEvent(timestamp: Date(), duration: 0.12, frameRate: 15, droppedFrame: 9, screenshotFileName: nil)
    ])
}
