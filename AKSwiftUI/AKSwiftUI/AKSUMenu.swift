//
//  AKSUMenu.swift
//  AKSwiftUI
//
//  Created by AlwaysKing on 2024/9/11.
//

import SwiftUI

class AKSUMenu {
    var hiddenEvent: (() -> Void)? = nil
    var menuContent: AnyView?
    var menuList: [UUID: NSView] = [:]

    func showView(point: CGPoint, width: CGFloat, height: CGFloat, view: NSView?) {
        guard let view = view else { return }
        close()
        let uuid = UUID()
        let rootView = AKSUMenuView(width: width, height: height, content: menuContent!, uuid: uuid, close: close)
        let contentView = NSHostingView(rootView: rootView)
        contentView.frame = NSRect(x: point.x, y: point.y, width: width, height: height)
        menuList[uuid] = contentView
        view.addSubview(contentView, positioned: .above, relativeTo: nil)
    }

    func close(uuid: UUID) {
        menuList[uuid]?.removeFromSuperview()
        menuList.removeValue(forKey: uuid)
//        if menuList.count == 0 {
//            hiddenEvent?()
//        }
    }

    func close() {
        for item in menuList {
            item.value.removeFromSuperview()
        }
        menuList.removeAll()
    }
}

struct AKSUMenuView: View {
    let width: CGFloat
    let height: CGFloat
    @State var contentHeight: CGFloat = 0

    var content: AnyView

    let uuid: UUID
    var close: (UUID) -> Void

    var body: some View {
        VStack {
            content
                .frame(width: width, height: contentHeight)
        }
        .frame(width: width, height: height, alignment: .top)
        .cornerRadius(4)
        .shadow(radius: 2)
        .onOutsideClick { inSide in
            if !inSide {
                close(uuid)
            }
        }
        .onAppear {
            contentHeight = 0
            withAnimation {
                contentHeight = height
            }
        }
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
            menu.showView(point: point, width: 120, height: 300, view: event?.window?.contentView)
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
