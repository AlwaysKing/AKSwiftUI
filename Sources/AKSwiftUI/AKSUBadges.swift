//
//  AKSUBudge.swift
//  demo
//
//  Created by AlwaysKing on 2024/9/5.
//

import SwiftUI

public struct AKSUBadges<T: View>: View {
    @Environment(\.isEnabled) private var isEnabled
    @ViewBuilder let content: () -> T
    let color: Color
    let bgColor: Color
    let action: () -> Void
    let radius: CGFloat
    let autoPadding: Bool
    let circle: Bool
    @State var size: CGFloat = 0.0

    public init(color: Color = .white, bgColor: Color = AKSUColor.primary, circle: Bool = false, radius: CGFloat = 8, autoPadding: Bool = true, content: @escaping () -> T, action: @escaping () -> Void) {
        self.color = color
        self.bgColor = bgColor
        self.content = content
        self.action = action
        self.radius = radius
        self.autoPadding = autoPadding
        self.circle = circle
    }

    public var body: some View {
        ZStack {
            content()
                .foregroundColor(color)
                .padding(.vertical, autoPadding && !circle ? 4 : 0)
                .padding(.horizontal, autoPadding && !circle ? 8 : 0)
                .padding(autoPadding && circle ? 8 : 0)
                .overlay {
                    GeometryReader { geometry in
                        Color.clear.task {
                            size = max(geometry.size.width, geometry.size.height)
                        }
                    }
                }
        }
        .frame(width: !circle || size == 0 ? nil : size, height: !circle || size == 0 ? nil : size)
        .background(bgColor)
        .cornerRadius(radius)
        .mask {
            if circle {
                Circle()
            } else {
                Rectangle()
            }
        }
    }
}

public extension AKSUBadges where T == Text {
    init<S>(_ title: S, color: Color = .white, bgColor: Color = AKSUColor.primary, circle: Bool = false, radius: CGFloat = 8, autoPadding: Bool = true, action: @escaping () -> Void) where S: StringProtocol {
        self.color = color
        self.bgColor = bgColor
        content = { Text(title).font(.title2) }
        self.action = action
        self.radius = radius
        self.autoPadding = autoPadding
        self.circle = circle
    }
}

struct AKSUBadges_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AKSUBadgesPreviewsView()
        }
        .frame(width: 600, height: 600)
    }
}

struct AKSUBadgesPreviewsView: View {
    @State var checked: Bool = false
    @State var list: [String] = []

    var body: some View {
        VStack {
            AKSUBadges {
                Text("子视图")
                    .font(.title)
            } action: {
            }

            AKSUBadges("文本") {
            }

            AKSUBadges("文本", autoPadding: false) {
            }

            AKSUBadges("文本", circle: true) {
            }

            AKSUBadges(circle: true) {
                Image(systemName: "folder").imageScale(.large)
            } action: {
            }
        }
    }
}
