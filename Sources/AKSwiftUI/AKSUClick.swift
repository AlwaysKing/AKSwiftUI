//
//  AKSUClick.swift
//  AKSwiftUI
//
//  Created by alwaysking on 2024/9/2.
//

import SwiftUI

public struct AKSUClick<T: View>: View {
    @Environment(\.self) var environment
    @Environment(\.isEnabled) private var isEnabled

    let color: Color
    let actionColor: Color
    @ViewBuilder let content: () -> T
    let action: () -> Void

    @State var hovering: Bool = false
    @State var mouseDown: Bool = false

    public init(color: Color = .aksuText, actionColor: Color = .aksuPrimary, content: @escaping () -> T, action: @escaping () -> Void) {
        self.color = color
        self.actionColor = actionColor
        self.content = content
        self.action = action
    }

    public var body: some View {
        ZStack {
            content()
                .foregroundColor(hovering || mouseDown ? actionColor.opacity(mouseDown ? 0.6 : 1.0) : isEnabled ? color : color.merge(up: .aksuGrayMask, mode: environment))
        }
        .onHover {
            hovering = $0
            if hovering {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    mouseDown = true
                }
                .onEnded { _ in
                    mouseDown = false
                    action()
                }
        )
    }
}

public extension AKSUClick where T == Text {
    init<S>(_ title: S, color: Color = .aksuText, actionColor: Color = .aksuPrimary, action: @escaping () -> Void) where S: StringProtocol {
        self.color = color
        self.actionColor = actionColor
        self.action = action
        self.content = { Text(title).font(.title) }
    }
}

struct AKSUClick_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AKSUClickPreviewsView()
        }
        .frame(width: 600, height: 600)
    }
}

struct AKSUClickPreviewsView: View {
    @State var checked: Bool = false
    @State var list: [String] = []

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                AKSUClick("文本") {
                }
            }

            AKSUClick {
                HStack {
                    Image(systemName: "list.bullet.rectangle.fill").imageScale(.large)
                    Text("自定义内容")
                }
            } action: {
            }
        }
    }
}
