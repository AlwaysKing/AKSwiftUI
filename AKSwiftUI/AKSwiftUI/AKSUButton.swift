//
//  AKSUButton.swift
//  AKSwiftUI
//
//  Created by alwaysking on 2024/8/29.
//

import SwiftUI

var AKSUButtonPadding: CGFloat = 10

func AKSUButtonContentHeight(totalHeight: CGFloat) -> CGFloat {
    return max(totalHeight - AKSUButtonPadding * 2, 0)
}

struct AKSUButton<T: View>: View {
    @Environment(\.isEnabled) private var isEnabled
    @ViewBuilder let content: () -> T
    @State var hovering: Bool = false
    let color: Color
    let bgColor: Color
    let height: CGFloat?
    let action: () -> Void

    @State var circleWidth: CGFloat = 0.0
    @State var circleOpacity: CGFloat = 0.0
    @State var circleOffset: (x: CGFloat, y: CGFloat) = (0, 0)
    @State var circleSize: CGFloat = 100.0
    var plain: Bool

    init(plain: Bool = false, color: Color = .white, bgColor: Color = AKSUColor.primary, height: CGFloat? = nil, content: @escaping () -> T, action: @escaping () -> Void) {
        self.color = color
        self.bgColor = bgColor
        self.content = content
        self.action = action
        self.plain = plain
        self.height = height
    }

    var body: some View {
        ZStack {
            content()
                .foregroundColor(color)
                .padding([.leading, .trailing])
                .padding([.top, .bottom], AKSUButtonPadding)
        }
        .background(
            GeometryReader { g in
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.5))
                        .frame(width: circleWidth, height: circleWidth)
                        .opacity(circleOpacity)
                        .offset(x: circleOffset.x - g.size.width / 2, y: circleOffset.y - g.size.height / 2)
                }
                .frame(width: g.size.width, height: g.size.height)
                .clipped()
                .onAppear {
                    circleSize = g.size.width * 2
                }
            }
        )
        .frame(height: height)
        .background(hovering ? .black.opacity(0.1) : .clear)
        .background(isEnabled ? .clear : AKSUColor.dyGrayMask)
        .background(bgColor)
        .cornerRadius(plain ? 0 : 4)
        .onHover {
            hovering = $0
            if hovering {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
        .shadow(color: bgColor != .white ? bgColor : .black, radius: plain ? 0 : (hovering ? 4 : 2))
        .onTapGestureLocation { location in
            if isEnabled {
                circleOffset = (location.x, location.y)
                circleWidth = 0
                circleOpacity = 1.0
                withAnimation {
                    circleOpacity = 0.0
                    circleWidth = circleSize
                }
                action()
            }
        }
    }
}

extension AKSUButton where T == Text {
    init<S>(_ title: S, plain: Bool = false, color: Color = .white, bgColor: Color = AKSUColor.primary, height: CGFloat? = nil, action: @escaping () -> Void) where S: StringProtocol {
        self.color = color
        self.bgColor = bgColor
        content = { Text(title).font(.title) }
        self.action = action
        self.plain = plain
        self.height = height
    }
}

struct AKSUButton_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AKSUButtonPreviewsView()
        }

        .frame(width: 600, height: 600)
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

            HStack {
                AKSUButton(plain: true, height: 40) {
                    Text("Plain")
                        .foregroundColor(.white)
                        .font(.title)
                        .frame(maxWidth: .infinity)
                }
                action: {
                }
                .frame(width: 100)
            }
        }
    }
}
