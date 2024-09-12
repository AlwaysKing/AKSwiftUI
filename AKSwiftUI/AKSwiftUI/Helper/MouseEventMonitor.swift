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
    static var cbList: [UUID: (filter: [NSEvent.EventType], cb: (CGPoint, NSEvent) -> Bool)] = [:]

    static func start(uuid: UUID, filter: [NSEvent.EventType], cb: @escaping (CGPoint, NSEvent) -> Bool) {
        // 插入列队
        cbList[uuid] = (filter, cb)

        if eventMonitor == nil {
            eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown, .rightMouseDragged, .leftMouseUp, .rightMouseUp, .leftMouseDragged, .mouseEntered, .mouseMoved, .mouseExited, .otherMouseDown, .otherMouseUp, .otherMouseDragged]) { event -> NSEvent? in
                guard let location = filpLocationPoint(event: event) else { return event }

                var stopEvent = false
                for item in cbList {
                    if item.value.filter.contains(event.type) {
                        stopEvent = item.value.cb(location, event) || stopEvent
                    }
                }
                if stopEvent {
                    return nil
                }
                return event
            }
        }
    }

    static func stop(uuid: UUID) {
        cbList.removeValue(forKey: uuid)
    }

    static func filpLocationPoint(event: NSEvent?) -> CGPoint? {
        guard let event = event else { return nil }
        guard let height = event.window?.contentView?.frame.height else { return nil }
        let locationInWindow = event.locationInWindow
        let flippedY = height - locationInWindow.y
        return NSPoint(x: locationInWindow.x, y: flippedY)
    }
}
