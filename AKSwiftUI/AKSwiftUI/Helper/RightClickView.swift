//
//  RightClickView.swift
//  AKSwiftUI
//
//  Created by AlwaysKing on 2024/9/9.
//

import SwiftUI

struct AKSURightClickView<V: View>: View {
    @State var tick: Bool = false
    @State var point: CGPoint = .zero
    @State var event: NSEvent? = nil

    @ViewBuilder let content: () -> V
    let rightClick: (CGPoint, NSEvent?) -> Void
    @State var uuid: UUID = UUID()

    var body: some View {
        VStack {
            content()
        }
        .onAppear {
            MouseEventMonitor.start(uuid: uuid, filter: [.rightMouseDown]) { location, event in
                self.event = event
                point = location
                tick = true
            }
        }.onDisappear {
            MouseEventMonitor.stop(uuid: uuid)
        }
        .overlay {
            if tick {
                GeometryReader { g in
                    Color.clear.task {
                        let rect = g.frame(in: .global)
                        if rect.contains(point) {
                            rightClick(CGPoint(x: point.x - rect.origin.x, y: point.y - rect.origin.y), event)
                        }
                        tick = false
                    }
                }
            }
        }
    }
}

extension View {
    func onRightClick(click: @escaping (CGPoint, NSEvent?) -> Void) -> some View {
        return AKSURightClickView(content: { self }, rightClick: click)
    }
}

#Preview {
    AKSURightClickView {} rightClick: { _ ,_ in }
}
