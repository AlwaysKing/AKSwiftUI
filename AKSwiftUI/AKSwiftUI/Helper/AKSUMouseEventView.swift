//
//  RightClickView.swift
//  AKSwiftUI
//
//  Created by AlwaysKing on 2024/9/9.
//

import SwiftUI

struct AKSUMouseEventView<V: View>: View {
    @State var rect: CGRect = CGRect.zero

    let filter: [NSEvent.EventType]

    @ViewBuilder let content: () -> V
    let mouseEventCB: (CGPoint, NSEvent?) -> Bool
    @State var uuid: UUID = UUID()

    var body: some View {
        VStack {
            content()
        }
        .onAppear {
            MouseEventMonitor.start(uuid: uuid, filter: filter) { location, event in
                if rect.contains(location) {
                   return mouseEventCB(CGPoint(x: location.x - rect.origin.x, y: location.y - rect.origin.y), event)
                }
                return false
            }
        }.onDisappear {
            MouseEventMonitor.stop(uuid: uuid)
        }
        .overlay {
            GeometryReader {
                g in
                Color.clear.onAppear {
                    rect = g.frame(in: .global)
                }
                .onChange(of: g.frame(in: .global)) { _ in
                    rect = g.frame(in: .global)
                }
            }
        }
    }
}

extension View {
    func onMouseEvent(event: [NSEvent.EventType], click: @escaping (CGPoint, NSEvent?) -> Bool) -> some View {
        return AKSUMouseEventView(filter: event, content: { self }, mouseEventCB: click)
    }
}
