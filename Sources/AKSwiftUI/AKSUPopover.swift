//
//  AKSUPopover.swift
//  AKSwiftUI
//
//  Created by alwaysking on 2024/9/2.
//

import SwiftUI

enum AKSUPopoverAligment {
    case upLeading
    case upTrailling
    case upCenter

    case downLeading
    case downTrailling
    case downCenter

    case leftTop
    case leftBottom
    case leftCenter

    case rightTop
    case rightBottom
    case rightCenter
}

class AKSUPopover: AKSUPopWnd {
    func show(rect: CGRect, size: CGSize, padding: CGFloat = 10, alignment: AKSUPopoverAligment, autoRePosition: Bool = false, autoHidden: Bool = true, parent: NSWindow, view: AnyView? = nil, rePosition: ((_ alignment: AKSUPopoverAligment, _ edge: [AKSUScreenEdge]) -> AKSUPopoverAligment)? = nil) {
        var newAligment = alignment
        var point = getPoint(rect: rect, size: size, padding: padding, alignment: alignment)

        if autoRePosition || rePosition != nil {
            // 先判断窗口
            let inWndRect = CGRect(x: point.x, y: point.y, width: size.width, height: size.height)
            let wndEdge = AKSUScreen.window(window: parent, rect: inWndRect)
            if wndEdge.count != 0 {
                if let rePosition = rePosition {
                    newAligment = rePosition(alignment, wndEdge)
                    point = getPoint(rect: rect, size: size, padding: padding, alignment: newAligment)
                } else {
                    // 自动重置位置
                    newAligment = self.autoRePosition(alignment, wndEdge)
                    point = getPoint(rect: rect, size: size, padding: padding, alignment: newAligment)
                }
            }

            let inScreenRect = CGRect(x: point.x + parent.frame.minX, y: point.y + parent.frame.minY, width: size.width, height: size.height)
            let screenEdge = AKSUScreen.mainScreen(rect: inScreenRect)
            if screenEdge.count != 0 {
                if let rePosition = rePosition {
                    newAligment = rePosition(alignment, screenEdge)
                    point = getPoint(rect: rect, size: size, padding: padding, alignment: newAligment)
                } else {
                    // 自动重置位置
                    newAligment = self.autoRePosition(alignment, screenEdge)
                    point = getPoint(rect: rect, size: size, padding: padding, alignment: newAligment)
                }
            }
        }

        show(point: point, width: size.width, height: size.height, autoHidden: autoHidden, parent: parent, view: view)
    }

    func autoRePosition(_ alignment: AKSUPopoverAligment, _ edge: [AKSUScreenEdge]) -> AKSUPopoverAligment {
        if edge.contains(.top) {
            if edge.contains(.left) {
                // 左上冲突了
                return .rightTop
            } else if edge.contains(.right) {
                return .leftTop
            } else {
                if alignment == .upLeading {
                    return .downLeading
                } else if alignment == .upTrailling {
                    return .downTrailling
                } else {
                    return .downCenter
                }
            }
        } else if edge.contains(.bottom) {
            if edge.contains(.left) {
                return .rightBottom
            } else if edge.contains(.right) {
                return .leftBottom
            } else {
                if alignment == .downLeading {
                    return .upLeading
                } else if alignment == .downTrailling {
                    return .upTrailling
                } else {
                    return .upCenter
                }
            }
        } else if edge.contains(.left) {
            if alignment == .leftTop {
                return .rightTop
            } else if alignment == .leftBottom {
                return .rightBottom
            } else {
                return .rightCenter
            }
        } else if edge.contains(.right) {
            if alignment == .rightTop {
                return .leftTop
            } else if alignment == .rightBottom {
                return .leftBottom
            } else {
                return .leftCenter
            }
        }

        return alignment
    }

    func getPoint(rect: CGRect, size: CGSize, padding: CGFloat, alignment: AKSUPopoverAligment) -> CGPoint {
        var point = CGPoint.zero
        // 封装常用计算逻辑
        let top: () -> CGFloat = { rect.minY - size.height - padding }
        let bottom: () -> CGFloat = { rect.maxY + padding }
        let left: () -> CGFloat = { rect.minX - size.width - padding }
        let right: () -> CGFloat = { rect.maxX + padding }
        let centerX: () -> CGFloat = { rect.midX - size.width / 2 }
        let centerY: () -> CGFloat = { rect.midY - size.height / 2 }
        let trailing: () -> CGFloat = { rect.maxX - size.width }
        let bottomY: () -> CGFloat = { rect.maxY - size.height }

        switch alignment {
        case .upLeading:
            point.y = top()
            point.x = rect.minX
        case .upTrailling:
            point.y = top()
            point.x = trailing()
        case .upCenter:
            point.y = top()
            point.x = centerX()
        case .downLeading:
            point.y = bottom()
            point.x = rect.minX
        case .downTrailling:
            point.y = bottom()
            point.x = trailing()
        case .downCenter:
            point.y = bottom()
            point.x = centerX()
        case .leftTop:
            point.x = left()
            point.y = rect.minY
        case .leftBottom:
            point.x = left()
            point.y = bottomY()
        case .leftCenter:
            point.x = left()
            point.y = centerY()
        case .rightTop:
            point.x = right()
            point.y = rect.minY
        case .rightBottom:
            point.x = right()
            point.y = bottomY()
        case .rightCenter:
            point.x = right()
            point.y = centerY()
        }
        return point
    }
}

struct AKSUPopover_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AKSUPopoverPreviewsView()
        }
        .frame(width: 600, height: 600)
    }
}

struct AKSUPopoverPreviewsView: View {
    let menu = AKSUPopover()

    var body: some View {
        VStack {
            HStack(spacing: 20) {
                AKSUWarpStack {
                    reader in
                    AKSUButton("upLeading") {
                        guard let global = reader.global else { return }
                        guard let window = reader.window else { return }
                        menu.menuContent = AnyView(menuContent())
                        menu.show(rect: global, size: CGSize(width: 100, height: 100), alignment: .upLeading, parent: window)
                    }
                }

                AKSUWarpStack {
                    reader in
                    AKSUButton("upTrailling") {
                        guard let global = reader.global else { return }
                        guard let window = reader.window else { return }
                        menu.menuContent = AnyView(menuContent())
                        menu.show(rect: global, size: CGSize(width: 100, height: 100), alignment: .upTrailling, parent: window)
                    }
                }

                AKSUWarpStack {
                    reader in
                    AKSUButton("upCenter") {
                        guard let global = reader.global else { return }
                        guard let window = reader.window else { return }
                        menu.menuContent = AnyView(menuContent())
                        menu.show(rect: global, size: CGSize(width: 100, height: 100), alignment: .upCenter, parent: window)
                    }
                }
            }

            HStack(spacing: 20) {
                AKSUWarpStack {
                    reader in
                    AKSUButton("downLeading") {
                        guard let global = reader.global else { return }
                        guard let window = reader.window else { return }
                        menu.menuContent = AnyView(menuContent())
                        menu.show(rect: global, size: CGSize(width: 100, height: 100), alignment: .downLeading, parent: window)
                    }
                }

                AKSUWarpStack {
                    reader in
                    AKSUButton("downTrailling") {
                        guard let global = reader.global else { return }
                        guard let window = reader.window else { return }
                        menu.menuContent = AnyView(menuContent())
                        menu.show(rect: global, size: CGSize(width: 100, height: 100), alignment: .downTrailling, parent: window)
                    }
                }

                AKSUWarpStack {
                    reader in
                    AKSUButton("downCenter") {
                        guard let global = reader.global else { return }
                        guard let window = reader.window else { return }
                        menu.menuContent = AnyView(menuContent())
                        menu.show(rect: global, size: CGSize(width: 100, height: 100), alignment: .downCenter, parent: window)
                    }
                }
            }
            .padding(.bottom, 100)

            HStack(spacing: 100) {
                VStack(spacing: 100) {
                    AKSUWarpStack {
                        reader in
                        AKSUButton("leftTop") {
                            guard let global = reader.global else { return }
                            guard let window = reader.window else { return }
                            menu.menuContent = AnyView(menuContent())
                            menu.show(rect: global, size: CGSize(width: 100, height: 100), alignment: .leftTop, parent: window)
                        }
                    }

                    AKSUWarpStack {
                        reader in
                        AKSUButton("leftBottom") {
                            guard let global = reader.global else { return }
                            guard let window = reader.window else { return }
                            menu.menuContent = AnyView(menuContent())
                            menu.show(rect: global, size: CGSize(width: 100, height: 100), alignment: .leftBottom, parent: window)
                        }
                    }

                    AKSUWarpStack {
                        reader in
                        AKSUButton("leftCenter") {
                            guard let global = reader.global else { return }
                            guard let window = reader.window else { return }
                            menu.menuContent = AnyView(menuContent())
                            menu.show(rect: global, size: CGSize(width: 100, height: 100), alignment: .leftCenter, parent: window)
                        }
                    }
                }
                VStack(spacing: 100) {
                    AKSUWarpStack {
                        reader in
                        AKSUButton("rightTop") {
                            guard let global = reader.global else { return }
                            guard let window = reader.window else { return }
                            menu.menuContent = AnyView(menuContent())
                            menu.show(rect: global, size: CGSize(width: 100, height: 100), alignment: .rightTop, parent: window)
                        }
                    }

                    AKSUWarpStack {
                        reader in
                        AKSUButton("rightBottom") {
                            guard let global = reader.global else { return }
                            guard let window = reader.window else { return }
                            menu.menuContent = AnyView(menuContent())
                            menu.show(rect: global, size: CGSize(width: 100, height: 100), alignment: .rightBottom, parent: window)
                        }
                    }

                    AKSUWarpStack {
                        reader in
                        AKSUButton("rightCenter") {
                            guard let global = reader.global else { return }
                            guard let window = reader.window else { return }
                            menu.menuContent = AnyView(menuContent())
                            menu.show(rect: global, size: CGSize(width: 100, height: 100), alignment: .rightCenter, parent: window)
                        }
                    }
                }
            }
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
