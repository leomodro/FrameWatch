//
//  FPSTimelineView.swift
//  FrameWatch
//
//  Created by Leonardo Modro on 05/06/25.
//

import SwiftUI
import Combine

struct FPSTimelineView: View {
    @State private var events: [FrameDropEvent] = []
    @State private var timer: AnyCancellable?

    var body: some View {
        VStack(alignment: .leading) {
            Text("📊 Frame Drop Timeline")
                .font(.headline)

            if events.isEmpty {
                Text("No frame drops recorded yet.")
                    .foregroundColor(.secondary)
            } else {
                ScrollView {
                    ForEach(events.indices, id: \.self) { index in
                        let event = events[index]
                        HStack {
                            if #available(iOS 15.0, *) {
                                Text(event.timestamp.formatted(date: .omitted, time: .standard))
                                    .font(.caption.monospaced())
                            } else {
                                // Fallback on earlier versions
                            }
                            Spacer()
                            Text("Duration: \(String(format: "%.2f", event.duration))s")
                            Text("FPS: \(Int(event.frameRate))")
                                .foregroundColor(event.frameRate < 45 ? .red : .green)
                        }
                        .padding(.vertical, 4)
                        Divider()
                    }
                }
                .frame(maxHeight: 300)
            }
        }
        .padding()
        .onAppear {
            timer = Timer.publish(every: 2.0, on: .main, in: .common)
                .autoconnect()
                .sink { _ in
                    self.events = Diagnostics.shared.droppedFrames
                }
        }
        .onDisappear {
            timer?.cancel()
        }
    }
}

struct FPSTimelineView_Previews: PreviewProvider {
    static var previews: some View {
        FPSTimelineView()
    }
}
