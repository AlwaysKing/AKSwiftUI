//
//  RightClickView.swift
//  AKSwiftUI
//
//  Created by AlwaysKing on 2024/9/9.
//

import SwiftUI

struct WindowAccessor: NSViewRepresentable {
    let getWindow: (NSWindow) -> Void

    func makeNSView(context: Context) -> NSView {
        let nsView = NSView()

        // 此时可以通过添加一个延迟操作来确保视图层级已经建立，从而获取 NSWindow 对象
        DispatchQueue.main.async {
            if let window = nsView.window {
                // 在这里存储或使用 window 对象
                getWindow(window)
            }
        }

        return nsView
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        // 不需要在这里做任何事情
    }
}

struct AKSUMouseEventView<V: View>: View {
    @State var rect: CGRect = CGRect.zero

    let filter: [NSEvent.EventType]

    @ViewBuilder let content: () -> V
    let mouseEventCB: ((CGPoint, NSEvent?) -> Bool)?
    let outsideClick: ((_ inside: Bool) -> Void)?
    @State var uuid: UUID = UUID()
    @State var window: NSWindow? = nil

    var body: some View {
        ZStack {
            content()
            if window == nil {
                VStack {
                    WindowAccessor {
                        window = $0
                    }.frame(width: 0, height: 0)
                }.frame(width: 0, height: 0)
            }
        }
        .onChange(of: window) { _ in
            MouseEventMonitor.start(uuid: uuid, window: window, filter: filter) { location, event in
                if rect.contains(location) {
                    if let mouseEventCB = mouseEventCB {
                        return mouseEventCB(CGPoint(x: location.x - rect.origin.x, y: location.y - rect.origin.y), event)
                    }
                    if let outsideClick = outsideClick {
                        outsideClick(true)
                    }
                } else {
                    if let outsideClick = outsideClick {
                        outsideClick(false)
                    }
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
    func onMouseEvent(event: [NSEvent.EventType], click: ((CGPoint, NSEvent?) -> Bool)? = nil, side: ((Bool) -> Void)? = nil) -> some View {
        return AKSUMouseEventView(filter: event, content: { self }, mouseEventCB: click, outsideClick: side)
    }

    func onOutsideClick(click: @escaping (Bool) -> Void) -> some View {
        return AKSUMouseEventView(filter: [.leftMouseDown, .rightMouseDown], content: { self }, mouseEventCB: nil, outsideClick: click)
    }
}
