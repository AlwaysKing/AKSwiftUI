//
//  AKSUWindowAccessor.swift
//  AKSwiftUI
//
//  Created by AlwaysKing on 2024/9/14.
//

import SwiftUI

struct AKSUWindowAccessor: NSViewRepresentable {
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
