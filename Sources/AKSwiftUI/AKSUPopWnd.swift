//
//  AKSUMenu.swift
//  AKSwiftUI
//
//  Created by AlwaysKing on 2024/9/11.
//

import SwiftUI

public class AKSUPopWnd: NSObject {
    var window: NSWindow
    var parent: NSWindow? = nil
    var pointRect: CGRect = CGRect.zero
    public var menuContent: AnyView? = nil
    public var hiddenEvent: (() -> Void)? = nil
    var monitor: Bool = false
    var uuid: UUID

    override public init() {
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

    public func show(point: CGPoint, pointRect: CGRect? = nil, toggle: Bool = false, width: CGFloat, height: CGFloat, autoHidden: Bool = true, parent: NSWindow, view: AnyView? = nil) {
        if let view = view {
            window.contentView = NSHostingView(rootView: AKSUPopWndView(width: width, height: height, content: view))
        } else if let menuContent = menuContent {
            window.contentView = NSHostingView(rootView: AKSUPopWndView(width: width, height: height, content: menuContent))
        } else {
            return
        }

        // 如果窗口当前是显示的
        if window.isVisible && toggle {
            // 如果都没变化，这直接关闭
            if self.parent == parent && self.pointRect == pointRect {
                self.close()
                self.hiddenEvent?()
                return
            }
        }

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
        self.pointRect = pointRect ?? CGRect.zero

        // 边缘测试
        window.setFrame(NSRect(x: point.x + parentRect.minX - 4, y: parentRect.maxY - point.y - height + 4, width: width, height: height), display: true)
        if !autoHidden {
            return
        }
        if !monitor {
            monitor = true
            NotificationCenter.default.addObserver(forName: NSWindow.didResignKeyNotification, object: parent, queue: nil) { notification in
                self.close()
                self.hiddenEvent?()
            }

            // 监听窗口为点击
            AKSUMouseEventMonitor.start(uuid: uuid, window: nil, filter: [.leftMouseDown, .rightMouseDown]) { _, event in
                if event.window == self.parent {
                    let point = AKSUMouseEventMonitor.filpLocationPoint(event: event)!
                    if !self.pointRect.contains(point) {
                        self.close()
                        self.hiddenEvent?()
                    }
                } else if event.window != self.window {
                    self.close()
                    self.hiddenEvent?()
                }
                return false
            }
        }
    }

    public func close() {
        monitor = false
        self.window.close()
        NotificationCenter.default.removeObserver(self, name: NSWindow.didResignKeyNotification, object: parent)
        AKSUMouseEventMonitor.stop(uuid: uuid)
    }
}

struct AKSUPopWndView: View {
    let width: CGFloat
    let height: CGFloat
    @State var contentHeight: CGFloat = 0

    var content: AnyView

    var body: some View {
        VStack {
            content.cornerRadius(AKSUAppearance.cornerRadius)
        }
        .frame(width: width, height: height, alignment: .top)
        .cornerRadius(AKSUAppearance.cornerRadius)
        .shadow(radius: 2)
        .padding(4)
    }
}

struct AKSUPopWnd_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AKSUPopWndPreviewsView()
        }
        .frame(width: 600, height: 600)
    }
}

struct AKSUPopWndPreviewsView: View {
    let menu = AKSUPopWnd()

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
            guard let point = AKSUMouseEventMonitor.filpLocationPoint(event: event) else { return false }
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
