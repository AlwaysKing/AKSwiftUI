//
//  AKSUHostView.swift
//  AKSwiftUI
//
//  Created by AlwaysKing on 2024/9/29.
//

import Foundation
import SwiftUI

public class AKSUWindow {
    public static func create(view: (any View)?, title: String, width: Int = 480, height: Int = 300, style: NSWindow.StyleMask = [.titled, .closable, .fullSizeContentView], level: NSWindow.Level = .floating, supportEditShortcut: Bool = false) -> NSWindow
    {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: width, height: height),
            styleMask: style,
            backing: .buffered, defer: false
        )
        window.titlebarAppearsTransparent = true
        window.isReleasedWhenClosed = true
        window.isMovableByWindowBackground = true
        window.setFrameAutosaveName(title)
        window.level = level
        if let view = view {
            if supportEditShortcut {
                window.contentView = AKSUHostViewWithEditShortcut(rootView: AnyView(view))
            } else {
                window.contentView = NSHostingView(rootView: AnyView(view))
            }
        }

        return window
    }
}

public class AKSUHostViewWithEditShortcut<Content>: NSHostingView<Content> where Content: View {
    override public func performKeyEquivalent(with event: NSEvent) -> Bool {
        if event.modifierFlags.contains(.command) {
            let shortcuts = [
                "a": #selector(NSText.selectAll(_:)),
                "x": #selector(NSText.cut(_:)),
                "c": #selector(NSText.copy(_:)),
                "v": #selector(NSText.paste(_:)),
                "z": Selector(("undo:")),
                "Z": Selector(("redo:"))
            ]
            if event.characters != nil && shortcuts[event.characters!] != nil {
                NSApp.sendAction(shortcuts[event.characters!]!, to: nil, from: nil)
                return true
            }
        }

        return super.performKeyEquivalent(with: event)
    }
}
