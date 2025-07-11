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

    static var colorScheme: ColorScheme = .light

    public static func setColorScheme(_ colorScheme: ColorScheme) {
        AKSUPopWnd.colorScheme = colorScheme
    }

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

    public func show(point: CGPoint, pointRect: CGRect? = nil, toggle: Bool = false, width: CGFloat, height: CGFloat, darkTheme: Bool? = nil, autoHidden: Bool = true, parent: NSWindow, limit: Bool = false, view: AnyView? = nil) {
        var scheme = AKSUPopWnd.colorScheme
        if let darkTheme = darkTheme {
            scheme = darkTheme ? .dark : .light
        }

        if let view = view {
            window.contentView = NSHostingView(rootView: AKSUPopWndView(width: width, height: height, colorScheme: scheme, content: view))
        } else if let menuContent = menuContent {
            window.contentView = NSHostingView(rootView: AKSUPopWndView(width: width, height: height, colorScheme: scheme, content: menuContent))
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
        // 这里要增加约束？不超过父窗口内容？
        window.setFrame(getRect(point: point, parentRect: parentRect, width: width, height: height, limit: limit), display: true)
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

    public func getRect(point: CGPoint, parentRect: CGRect, width: CGFloat, height: CGFloat, limit: Bool) -> NSRect {
        if !limit {
            return NSRect(x: point.x + parentRect.minX - 4, y: parentRect.maxY - point.y - height + 4, width: width, height: height)
        }

        print("point:\(point.y) height:\(width) maxY:\(parentRect.maxX)")

        // 先确定x
        var x: CGFloat = point.x
        // 需要收缩
        if parentRect.width < width {
            // 放到原点即可
            x = 0
        } else if point.x + width > parentRect.width {
            x = parentRect.width - width
        }

        var y: CGFloat = point.y
        if parentRect.height < height {
            y = 0
        } else if point.y + height > parentRect.height {
            y = parentRect.height - height
        }

        return NSRect(x: x + parentRect.minX - 4, y: parentRect.maxY - y - height + 4, width: width, height: height)
    }
}

struct AKSUPopWndView: View {
    let width: CGFloat
    let height: CGFloat
    var colorScheme: ColorScheme
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
        .preferredColorScheme(colorScheme)
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
