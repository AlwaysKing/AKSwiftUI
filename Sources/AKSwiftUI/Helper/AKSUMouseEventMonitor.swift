//
//  MouseEventMonitor.swift
//  AKSwiftUI
//
//  Created by AlwaysKing on 2024/9/5.
//

import AppKit
import Foundation

public class AKSUMouseEventMonitor {
    static var eventMonitor: Any?

    static var cbList: [UUID: (window: NSWindow?, filter: [NSEvent.EventType], cb: (CGPoint, NSEvent) -> Bool)] = [:]
    static var sort: [UUID] = []

    public static func start(uuid: UUID, window: NSWindow?, filter: [NSEvent.EventType], cb: @escaping (CGPoint, NSEvent) -> Bool) {
        // 插入列队
        cbList[uuid] = (window, filter, cb)
        sort.insert(uuid, at: 0) // (uuid)

        if eventMonitor == nil {
            eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown, .rightMouseDragged, .leftMouseUp, .rightMouseUp, .leftMouseDragged, .mouseEntered, .mouseMoved, .mouseExited, .otherMouseDown, .otherMouseUp, .otherMouseDragged]) { event -> NSEvent? in
                guard let location = filpLocationPoint(event: event) else { return event }

                for uuid in sort {
                    if let item = cbList[uuid] {
                        if item.window != nil {
                            if item.window != event.window {
                                continue
                            }
                        }

                        if item.filter.contains(event.type) {
                            if item.cb(location, event) {
                                return nil
                            }
                        }
                    }
                }
                return event
            }
        }
    }

    public static func stop(uuid: UUID) {
        cbList.removeValue(forKey: uuid)
    }

    public static func filpLocationPoint(event: NSEvent?) -> CGPoint? {
        guard let event = event else { return nil }
        guard let height = event.window?.contentView?.frame.height else { return nil }
        let locationInWindow = event.locationInWindow
        let flippedY = height - locationInWindow.y
        return NSPoint(x: locationInWindow.x, y: flippedY)
    }
}
