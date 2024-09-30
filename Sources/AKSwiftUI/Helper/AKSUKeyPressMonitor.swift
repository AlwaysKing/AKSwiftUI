//
//  AKSUKeyPressMonitor.swift
//  AKSwiftUI
//
//  Created by AlwaysKing on 2024/9/30.
//

import SwiftUI

struct AKSUKeyPressMonitor: NSViewRepresentable {
    let onEvent: (NSEvent) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = AKSUKeyPressMonitorView()
        view.onEvent = onEvent
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

private class AKSUKeyPressMonitorView: NSView {
    var onEvent: (NSEvent) -> Void = { _ in }

    override var acceptsFirstResponder: Bool { true }
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
