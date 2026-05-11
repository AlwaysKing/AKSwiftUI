//
//  AKSUKeyPressMonitor.swift
//  AKSwiftUI
//
//  Created by AlwaysKing on 2024/9/30.
//

import SwiftUI

struct AKSUKeyPressMonitor: NSViewRepresentable {    
    var isFocused: Bool = false
    let onEvent: (NSEvent) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = AKSUKeyPressMonitorView()
        view.onEvent = onEvent
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        guard let monitorView = nsView as? AKSUKeyPressMonitorView else { return }
        monitorView.onEvent = onEvent
        if isFocused {
            DispatchQueue.main.async {
                if let window = monitorView.window, window.firstResponder !== monitorView {
                    window.makeFirstResponder(monitorView)
                }
            }
        }
    }
}

private class AKSUKeyPressMonitorView: NSView {
    var onEvent: (NSEvent) -> Void = { _ in }

    override var acceptsFirstResponder: Bool { true }
    override var canBecomeKeyView: Bool { true }

    override func keyDown(with event: NSEvent) {
        onEvent(event)
    }
}

extension View {
    func onAKSUKeyPress(_ event: @escaping (NSEvent) -> Void) -> some View {
        return self.background {
            AKSUKeyPressMonitor(onEvent: event)
        }
    }
}
