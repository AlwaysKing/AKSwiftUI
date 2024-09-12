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
    static var sort: [UUID] = []

    static func start(uuid: UUID, filter: [NSEvent.EventType], cb: @escaping (CGPoint, NSEvent) -> Bool) {
        // 插入列队
        cbList[uuid] = (filter, cb)
        sort.insert(uuid, at: 0) // (uuid)

        if eventMonitor == nil {
            eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown, .rightMouseDragged, .leftMouseUp, .rightMouseUp, .leftMouseDragged, .mouseEntered, .mouseMoved, .mouseExited, .otherMouseDown, .otherMouseUp, .otherMouseDragged]) { event -> NSEvent? in
                guard let location = filpLocationPoint(event: event) else { return event }


                for uuid in sort {
                    if let item = cbList[uuid] {
                        if item.filter.contains(event.type) {
                            if item.cb(location, event) {
//                                return nil
                            }
                        }
                    }
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
