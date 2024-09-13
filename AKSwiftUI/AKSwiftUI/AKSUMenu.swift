//
//  AKSUMenu.swift
//  AKSwiftUI
//
//  Created by AlwaysKing on 2024/9/11.
//

import SwiftUI

class AKSUMenu: NSObject {
    var window: NSWindow
    var parent: NSWindow? = nil
    var menuContent: AnyView? = nil
    var hiddenEvent: (() -> Void)? = nil
    var monitor: Bool = false
    var uuid: UUID

    override init() {
        uuid = UUID()
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 0, height: 0),
            styleMask: [.fullSizeContentView, .borderless],
            backing: .buffered, defer: false
        )
        window.titlebarAppearsTransparent = true
        window.backgroundColor = .clear
        window.level = .popUpMenu
        window.isReleasedWhenClosed = false
        window.hasShadow = false
        super.init()
    }

    func show(point: CGPoint, width: CGFloat, height: CGFloat, parent: NSWindow) {
        guard let menuContent = menuContent else { return }
        window.contentView = NSHostingView(rootView: AKSUMenuView(width: width, height: height, content: menuContent))

        // 将windowMenu添加到父亲窗口
        if parent.childWindows != nil {
            if !parent.childWindows!.contains(window) {
                parent.addChildWindow(window, ordered: .above)
            }
        } else {
            parent.addChildWindow(window, ordered: .above)
        }

        // 改变大小和移动到相应位置
        // 获取window的位置
        let parentRect = parent.frame
        self.parent = parent
        window.setFrame(NSRect(x: point.x + parentRect.minX - 4, y: parentRect.maxY - point.y - height + 4, width: width, height: height), display: true)
        if !monitor {
            monitor = true
            NotificationCenter.default.addObserver(forName: NSWindow.didResignKeyNotification, object: parent, queue: nil) { notification in
                self.close()
                self.hiddenEvent?()
            }

            // 监听窗口为点击
            MouseEventMonitor.start(uuid: uuid, window: window, filter: [.leftMouseDown, .rightMouseDown]) { _, event in
                if event.window != self.window {
                    self.close()
                    self.hiddenEvent?()
                }
                return false
            }
        }
    }

    func close() {
        print("close")
        self.window.close()
        monitor = false
        NotificationCenter.default.removeObserver(self, name: NSWindow.didResignKeyNotification, object: parent)
        MouseEventMonitor.stop(uuid: uuid)
    }
}

struct AKSUMenuView: View {
    let width: CGFloat
    let height: CGFloat
    @State var contentHeight: CGFloat = 0

    var content: AnyView

    var body: some View {
        VStack {
            content.cornerRadius(4)
        }
        .frame(width: width, height: height, alignment: .top)
        .cornerRadius(4)
        .shadow(radius: 2)
        .padding(4)
    }
}

struct AKSUMenu_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AKSUMenuPreviewsView()
        }
        .frame(width: 600, height: 600)
    }
}

struct AKSUMenuPreviewsView: View {
    let menu = AKSUMenu()

    var body: some View {
        ZStack {
        }
        .frame(width: 600, height: 600)
        .background(.green)
        .onMouseEvent(event: [.rightMouseDown]) { point, event in
            menu.menuContent = AnyView(menuContent())
            menu.hiddenEvent = {
                print("hidden")
            }
            guard let point = MouseEventMonitor.filpLocationPoint(event: event) else { return false }
            menu.show(point: point, width: 120, height: 300, parent: event!.window!)
            return true
        }
    }

    func menuContent() -> some View {
        VStack {
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.yellow)
        .ignoresSafeArea()
    }
}
