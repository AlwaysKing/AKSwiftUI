//
//  AKSUSegment.swift
//  AKSwiftUI
//
//  Created by alwaysking on 2024/9/3.
//

import SwiftUI

public enum AKSUSegmentStyle {
    case fat
    case slim
}

// AKSUSegment 本体定义
public struct AKSUSegment<K: Hashable>: View {
    @Environment(\.self) var environment
    @Environment(\.isEnabled) private var isEnabled

    @Binding var selected: K
    var color: Color
    var bgColor: Color
    var height: CGFloat?
    var content: [K: AKSUSegmentItem<K>] = [:]
    var sort: [K] = []
    var style: AKSUSegmentStyle
    @Namespace var animation
    @State var realHeight: CGFloat = 0.0

    public init(selected: Binding<K>, style: AKSUSegmentStyle = .fat, color: Color = .white, bgColor: Color = AKSUColor.primary, height: CGFloat? = nil, horizontal: Bool = false, @AKSUSegmentBuilder<K> content: () -> [AKSUSegmentItem<K>]) {
        self._selected = selected
        for item in content() {
            self.content[item.index] = AKSUSegmentItem(index: item.index, selected: selected, style: style, color: color, bgColor: bgColor, content: item.content)
            self.sort.append(item.index)
        }
        self.color = color
        self.bgColor = bgColor
        self.height = height
        self.style = style
    }

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(self.sort, id: \.self) { index in
                self.content[index]
                    .onTapGesture {
                        withAnimation {
                            self.selected = index
                        }
                    }
                    .background {
                        // 选中的背景色
                        if index == self.selected {
                            VStack {}
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(self.style == .slim ? self.bgColor : self.bgColor.merge(up: .white.opacity(0.2), mode: environment))
                                .matchedGeometryEffect(id: "AKSUSegment", in: self.animation)
                        }
                    }

                // 增加
                if index != self.sort.last {
                    VStack {}
                        .frame(width: 1, height: max(0, self.realHeight / 2))
                        .background(self.style == .slim ? AKSUColor.dyGrayBG : .white.opacity(0.4))
                        .padding([.leading, .trailing], -0.5)
                }
            }
        }
        .background(self.style == .slim ? .clear : self.bgColor)
        .overlay {
            GeometryReader { g in
                RoundedRectangle(cornerRadius: AKSUAppearance.cornerRadius)
                    .stroke(self.style == .slim ? AKSUColor.gray : .clear, lineWidth: 2)
                    .padding(1)
                    .onAppear {
                        self.realHeight = g.size.height
                    }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay {
            if !self.isEnabled {
                RoundedRectangle(cornerRadius: AKSUAppearance.cornerRadius)
                    .fill(AKSUColor.dyGrayMask)
                    .padding(1)
            }
        }
        .mask {
            RoundedRectangle(cornerRadius: AKSUAppearance.cornerRadius)
                .padding(1)
        }
    }
}

// AKSUSegment Content Item 定义
public struct AKSUSegmentItem<K: Hashable>: View {
    var index: K
    @Binding var selected: K
    var content: [AnyView]

    private var canAction: Bool = false
    private var color: Color = .white
    private var hoverColor: Color = AKSUColor.primary
    private var style: AKSUSegmentStyle = .fat
    @State private var hovering: Bool = false

    public init(index: K, @AKSUAnyViewArrayBuilder content: () -> [AnyView]) {
        self.index = index
        self.content = content()
        self._selected = .constant(index)
    }

    public init(index: K, selected: Binding<K>, style: AKSUSegmentStyle, color: Color, bgColor: Color, content: [AnyView]) {
        self.index = index
        self.color = color
        self.hoverColor = bgColor
        self.content = content
        self.style = style
        self._selected = selected
    }

    public var body: some View {
        HStack {
            ForEach(Array(0 ..< self.content.count), id: \.self) { i in
                self.content[i]
            }
        }
        .foregroundColor(self.hovering || index == selected ? .white : self.color)
        .frame(maxWidth: .infinity)
        .padding([.top, .bottom], 10)
        .onHover {
            self.hovering = $0
        }
        .background(self.hovering ? (self.style == .slim ? self.hoverColor.opacity(0.8) : .white.opacity(0.2)) : .clear)
    }
}

// AKSUSegment Content Item 修饰函数定义
public extension View {
    public func AKSUSegmentTag<K: Hashable>(index: K) -> AKSUSegmentItem<K> {
        AKSUSegmentItem(index: index, content: { self })
    }
}

// AKSUSegmentItem 的 AKSUSegmentBuilder 定义
@resultBuilder public enum AKSUSegmentBuilder<K: Hashable> {
    static func buildBlock() -> [AKSUSegmentItem<K>] {
        []
    }

    public static func buildBlock(_ components: AKSUSegmentItem<K>...) -> [AKSUSegmentItem<K>] {
        components
    }

    public static func buildBlock(_ components: [AKSUSegmentItem<K>]...) -> [AKSUSegmentItem<K>] {
        components.flatMap {
            $0
        }
    }

    public static func buildExpression(_ expression: AKSUSegmentItem<K>) -> [AKSUSegmentItem<K>] {
        [expression]
    }

    public static func buildExpression(_ expression: ForEach<Range<Int>, Int, AKSUSegmentItem<K>>) -> [AKSUSegmentItem<K>] {
        expression.data.map {
            expression.content($0)
        }
    }

    public static func buildEither(first: [AKSUSegmentItem<K>]) -> [AKSUSegmentItem<K>] {
        return first
    }

    public static func buildEither(second: [AKSUSegmentItem<K>]) -> [AKSUSegmentItem<K>] {
        return second
    }

    public static func buildIf(_ element: [AKSUSegmentItem<K>]?) -> [AKSUSegmentItem<K>] {
        return element ?? []
    }
}

struct AKSUSegment_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AKSUSegmentPreviewsView()
        }
        .frame(width: 600, height: 600)
    }
}

struct AKSUSegmentPreviewsView: View {
    @State var progress: CGFloat = 0
    @State var range: CGFloat = 0

    @State var index: String = "1"

    var body: some View {
        VStack {
            AKSUButton("颜色比较") {
            }
            AKSUSegment(selected: self.$index) {
                ForEach(0 ..< 5) {
                    index in
                    Text("\(index)").AKSUSegmentTag(index: "\(index)")
                }
            }

            AKSUSegment(selected: self.$index, style: .slim, color: AKSUColor.gray) {
                ForEach(0 ..< 5) {
                    index in
                    Text("\(index)").AKSUSegmentTag(index: "\(index)")
                }
            }
        }
        .frame(width: 200)
    }
}
