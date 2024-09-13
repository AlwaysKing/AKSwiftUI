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
    func show(rect: CGRect, size: CGSize, padding: CGFloat = 10, alignment: AKSUPopoverAligment, autoHidden: Bool = true, parent: NSWindow, view: AnyView? = nil) {
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

        show(point: point, width: size.width, height: size.height, autoHidden: autoHidden, parent: parent, view: view)
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
