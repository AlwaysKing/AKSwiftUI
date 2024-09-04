//
//  AKSUPicker.swift
//  AKSwiftUI
//
//  Created by alwaysking on 2024/9/3.
//

import SwiftUI

enum AKSUSegmentStyle {
    case fat
    case slim
}

// AKSUSegment 本体定义
struct AKSUSegment<K: Hashable>: View {
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

    init(selected: Binding<K>, style: AKSUSegmentStyle = .fat, color: Color = .white, bgColor: Color = AKSUColor.primary, height: CGFloat? = nil, horizontal: Bool = false, @AKSUSegmentBuilder<K> content: () -> [AKSUSegmentItem<K>]) {
        self._selected = selected
        for item in content() {
            self.content[item.index] = AKSUSegmentItem(index: item.index, style: style, color: color, bgColor: bgColor, content: item.content)
            self.sort.append(item.index)
        }
        self.color = color
        self.bgColor = bgColor
        self.height = height
        self.style = style
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(sort, id: \.self) { index in
                content[index]
                    .onTapGesture {
                        withAnimation {
                            selected = index
                        }
                    }
                    .background {
                        if index == selected {
                            Rectangle()
                                .fill(bgColor)
                                .fill(style == .slim ? .clear : .white.opacity(0.2))
                                .matchedGeometryEffect(id: "AKSUSegment", in: animation)
                        }
                    }
                if index != sort.last {
                    VStack {
                    }
                    .frame(width: 1, height: max(0, realHeight / 2))
                    .background(style == .slim ? AKSUColor.dyGrayBG : .white.opacity(0.4))
                    .padding([.leading, .trailing], -0.5)
                }
            }
        }
        .background(style == .slim ? .clear : bgColor)
        .overlay {
            GeometryReader { g in
                RoundedRectangle(cornerRadius: 8)
                    .stroke(style == .slim ? AKSUColor.gray : .clear, lineWidth: 2)
                    .padding(1)
                    .onAppear {
                        realHeight = g.size.height
                    }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay {
            if !isEnabled {
                RoundedRectangle(cornerRadius: 8)
                    .fill(AKSUColor.dyGrayMask)
                    .padding(1)
            }
        }
        .mask {
            RoundedRectangle(cornerRadius: 8)
                .padding(1)
        }
    }
}

// AKSUSegment Content Item 定义
public struct AKSUSegmentItem<K: Hashable>: View {
    var index: K
    var content: [AnyView]

    private var canAction: Bool = false
    private var color: Color = .white
    private var hoverColor: Color = AKSUColor.primary
    private var style: AKSUSegmentStyle = .fat
    @State private var hovering: Bool = false

    init(index: K, @AKSUAnyViewArrayBuilder content: () -> [AnyView]) {
        self.index = index
        self.content = content()
    }

    init(index: K, style: AKSUSegmentStyle, color: Color, bgColor: Color, content: [AnyView]) {
        self.index = index
        self.color = color
        self.hoverColor = bgColor
        self.content = content
        self.style = style
    }

    public var body: some View {
        HStack {
            ForEach(Array(0 ..< content.count), id: \.self) { i in
                content[i]
            }
        }
        .foregroundColor(color)
        .frame(maxWidth: .infinity)
        .padding([.top, .bottom], 10)
        .onHover {
            hovering = $0
        }
        .background(hovering ? (style == .slim ? hoverColor.opacity(0.8) : .white.opacity(0.2)) : .clear)
    }
}

// AKSUSegment Content Item 修饰函数定义
extension View {
    func AKSUSegmentTag<K: Hashable>(index: K) -> AKSUSegmentItem<K> {
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
            AKSUSegment(selected: $index) {
                ForEach(0 ..< 5) {
                    index in
                    Text("\(index)").AKSUSegmentTag(index: "\(index)")
                }
            }

            AKSUSegment(selected: $index, style: .slim, color: AKSUColor.gray) {
                ForEach(0 ..< 5) {
                    index in
                    Text("\(index)").AKSUSegmentTag(index: "\(index)")
                }
            }
        }
        .frame(width: 200)
    }
}
