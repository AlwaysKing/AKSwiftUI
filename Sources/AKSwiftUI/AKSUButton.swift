//
//  AKSUButton.swift
//  AKSwiftUI
//
//  Created by alwaysking on 2024/8/29.
//

import SwiftUI

public enum AKSUButtonStyle {
    case normal
    case plain
    case circle
}

public enum AKSUButtonClickAnimation {
    case none
    case center
    case offset
}

public struct AKSUButton<T: View>: View {
    @Environment(\.isEnabled) private var isEnabled
    @ViewBuilder let content: () -> T

    @State var hovering: Bool = false
    @State var circleStyleSize: CGFloat = 0.0

    let color: Color
    let bgColor: Color
    let height: CGFloat?
    let maxWidth: CGFloat?
    let action: () -> Void
    let style: AKSUButtonStyle
    let autoPadding: Bool
    let clickStyke: AKSUButtonClickAnimation

    // 点击动画
    @State var animationCircleWidth: CGFloat = 0.0
    @State var animationCircleOpacity: CGFloat = 0.0
    @State var animationCircleOffset: (x: CGFloat, y: CGFloat) = (0, 0)
    @State var animationCircleSize: CGFloat = 100.0

    public init(style: AKSUButtonStyle = .normal, clickStyke: AKSUButtonClickAnimation = .offset, color: Color = .aksuWhite, bgColor: Color = .aksuPrimary, height: CGFloat? = nil, maxWidth: CGFloat? = nil, autoPadding: Bool = true, content: @escaping () -> T, action: @escaping () -> Void) {
        self.color = color
        self.bgColor = bgColor
        self.content = content
        self.action = action
        self.style = style
        self.height = height
        self.maxWidth = maxWidth
        self.animationCircleSize = height ?? 0
        self.autoPadding = autoPadding
        self.clickStyke = clickStyke
    }

    public var body: some View {
        ZStack {
            content()
                .foregroundColor(color)
                .padding([.leading, .trailing], autoPadding ? 16 : 0)
                .padding([.top, .bottom], autoPadding ? 8 : 0)
                .frame(maxWidth: maxWidth)
                .overlay {
                    GeometryReader { geometry in
                        Color.clear.task {
                            if let height = height {
                                circleStyleSize = height
                            } else {
                                circleStyleSize = max(geometry.size.width, geometry.size.height)
                            }
                        }
                    }
                }
        }
        .frame(height: height)
        .frame(width: style != .circle || circleStyleSize == 0 ? nil : circleStyleSize, height: style != .circle || circleStyleSize == 0 ? nil : circleStyleSize)
        .background(
            GeometryReader { g in
                if clickStyke != .none {
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.5))
                            .frame(width: animationCircleWidth, height: animationCircleWidth)
                            .opacity(animationCircleOpacity)
                            .offset(x: clickStyke == .center ? 0 : animationCircleOffset.x - g.size.width / 2, y: clickStyke == .center ? 0 : animationCircleOffset.y - g.size.height / 2)
                    }
                    .frame(width: g.size.width, height: g.size.height)
                    .onAppear {
                        animationCircleSize = g.size.width * 2
                    }
                }
            }
        )
        .background(hovering ? .black.opacity(0.1) : .clear)
        .background(isEnabled ? .clear : .aksuGrayMask)
        .background(bgColor)
        .cornerRadius(style == .plain ? 0 : AKSUAppearance.cornerRadius)
        .onHover {
            hovering = $0
            if hovering {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
        .mask {
            if style == .circle {
                Circle()
            } else {
                Rectangle()
            }
        }
        .shadow(color: bgColor != .white && bgColor != .aksuWhite && bgColor != .aksuTextBackground ? bgColor : .black.opacity(0.3), radius: style == .plain ? 0 : (hovering ? 4 : 2))
        .onTapGestureLocation { location in
            if isEnabled {
                animationCircleOffset = (location.x, location.y)
                animationCircleWidth = 0
                animationCircleOpacity = 1.0
                withAnimation {
                    animationCircleOpacity = 0.0
                    animationCircleWidth = animationCircleSize
                }
                action()
            }
        }
    }
}

public extension AKSUButton where T == Text {
    init<S>(_ title: S, style: AKSUButtonStyle = .normal, clickStyke: AKSUButtonClickAnimation = .offset, color: Color = .aksuWhite, bgColor: Color = .aksuPrimary, height: CGFloat? = nil, maxWidth: CGFloat? = nil, autoPadding: Bool = true, action: @escaping () -> Void) where S: StringProtocol {
        self.color = color
        self.bgColor = bgColor
        content = { Text(title).font(.title) }
        self.action = action
        self.style = style
        self.height = height
        self.maxWidth = maxWidth
        self.animationCircleSize = height ?? 0
        self.autoPadding = autoPadding
        self.clickStyke = clickStyke
    }
}

struct AKSUButton_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AKSUButtonPreviewsView()
        }

        .frame(width: 700, height: 600)
    }
}

struct AKSUButtonPreviewsView: View {
    @State var checked: Bool = false
    @State var list: [String] = []

    var body: some View {
        VStack {
            AKSUButton {
                Text("子视图")
                    .font(.title)
            } action: {
            }

            AKSUButton("文本") {
            }

            AKSUButton {
                Text("自定义内容")
                    .font(.title)
                    .frame(maxWidth: .infinity)
            } action: {
            }

            AKSUButton(style: .plain, clickStyke: .center, height: 100) {
                Text("height")
                    .foregroundColor(.white)
                    .font(.title)
                    .frame(maxWidth: .infinity)
            }
            action: {
            }
            .frame(width: 100)

            HStack {
                AKSUButton(style: .circle, clickStyke: .center) {
                    Text("Plain")
                        .foregroundColor(.white)
                        .font(.title)
                        .frame(maxWidth: .infinity)
                }
                action: {
                }
                .frame(width: 100)

                AKSUButton(style: .circle, clickStyke: .none) {
                    Image(systemName: "folder").imageScale(.large)
                } action: {
                }

                AKSUButton(style: .circle, height: 40, autoPadding: false) {
                    Image(systemName: "folder").imageScale(.large)
                } action: {
                }
                AKSUButton(style: .circle, autoPadding: false) {
                    Image(systemName: "folder").imageScale(.large)
                } action: {
                }
            }

            HStack {
                AKSUButton("文本", color: .aksuTextForeground, bgColor: .aksuTextBackground) {
                }
                AKSUButton("文本", color: .white, bgColor: .aksuGray) {
                }
                AKSUButton("文本", color: .white, bgColor: .aksuText) {
                }
                AKSUButton("文本", color: .white, bgColor: .aksuTitle) {
                }
                AKSUButton("文本", color: .white, bgColor: .aksuLessText) {
                }
                AKSUButton("文本", color: .white, bgColor: .aksuSecondaryText) {
                }
                AKSUButton("文本", color: .white, bgColor: .aksuTextForeground) {
                }
                AKSUButton("文本", color: .white, bgColor: .aksuBlack) {
                }
            }

            HStack {
                AKSUButton("文本", color: .white, bgColor: .aksuBlue) {
                }

                AKSUButton("文本", color: .aksuTextForeground, bgColor: .aksuWhite) {
                }
                AKSUButton("文本", color: .white, bgColor: .aksuDanger) {
                }
                AKSUButton("文本", color: .white, bgColor: .aksuSuccess) {
                }
                AKSUButton("文本", color: .white, bgColor: .aksuWarning) {
                }
                AKSUButton("文本", color: .white, bgColor: .aksuLightBlue) {
                }
            }
        }
    }
}
