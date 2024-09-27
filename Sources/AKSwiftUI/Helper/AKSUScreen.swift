//
//  AKSUScreen.swift
//  AKSwiftUI
//
//  Created by AlwaysKing on 2024/9/14.
//

import SwiftUI

// 定义枚举 Edge
public enum AKSUScreenEdge {
    case top
    case bottom
    case left
    case right
}

public class AKSUScreen {
    public static func mainScreen(rect: CGRect) -> [AKSUScreenEdge] {
        guard let screen = NSScreen.main?.frame else { return [] }
        return edgesOutOfBounds(outerRect: screen, innerRect: rect)
    }

    public static func window(window: NSWindow, rect: CGRect) -> [AKSUScreenEdge] {
        return edgesOutOfBounds(outerRect: window.frame, innerRect: rect)
    }

    // 函数判断第二个 CGRect 超出第一个 CGRect 的边
    public static func edgesOutOfBounds(outerRect: CGRect, innerRect: CGRect) -> [AKSUScreenEdge] {
        var edges: [AKSUScreenEdge] = []

        // 检查顶部边是否超出
        if innerRect.minY < outerRect.minY {
            edges.append(.bottom)
        }

        // 检查底部边是否超出
        if innerRect.maxY > outerRect.maxY {
            edges.append(.top)
        }

        // 检查左边缘是否超出
        if innerRect.minX < outerRect.minX {
            edges.append(.left)
        }

        // 检查右边缘是否超出
        if innerRect.maxX > outerRect.maxX {
            edges.append(.right)
        }

        return edges
    }
}
