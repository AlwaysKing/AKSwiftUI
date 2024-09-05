//
//  MouseEventMonitor.swift
//  AKSwiftUI
//
//  Created by AlwaysKing on 2024/9/5.
//

import AppKit
import Foundation

class MouseEventMonitor {
    static var eventMonitor: Any?
    static var cbList: [UUID: (CGPoint) -> Void] = [:]

    static func start(uuid: UUID, cb: @escaping (CGPoint) -> Void) {
        // 插入列队
        cbList[uuid] = cb

        if eventMonitor == nil {
            eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .leftMouseDown) { event -> NSEvent? in
                if let window = event.window {
                    let height = window.contentView!.frame.height
                    let locationInWindow = event.locationInWindow
                    let flippedY = height - locationInWindow.y
                    let flippedLocation = NSPoint(x: locationInWindow.x, y: flippedY)
                    for item in cbList {
                        item.value(flippedLocation)
                    }
                }
                return event
            }
        }
    }

    static func stop(uuid: UUID) {}
}
