//
//  AKSUGroup.swift
//  AKSwiftUI
//
//  Created by alwaysking on 2024/12/21.
//
import SwiftUI

public enum AKSUGroupStyle {
    case horizontal
    case vertical
}

public struct AKSUGroup: View {
    var style: AKSUGroupStyle = .vertical
    var disableFocus: Bool = false
    var hiddenDivider: Bool = false
    var hiddenBoard: Bool = false
    
    private var itemView: [AnyView] = []
    @State private var fouced: Int?
    @State private var itemSize: [Int: CGSize] = [:]
    
    public init(style: AKSUGroupStyle = .horizontal, disableFocus: Bool = false, hiddenDivider: Bool = false, hiddenBoard: Bool = false) {
        self.style = style
        self.disableFocus = disableFocus
        self.hiddenDivider = hiddenDivider
        self.hiddenBoard = hiddenBoard
    }

    public var body: some View {
        AKSUMouseEventView(filter: [.leftMouseDown, .rightMouseDown])
            {
                AKSUStackView(stack: style == .horizontal ? .hstack : .vstack, spacing: 0) {
                    ForEach(Array(0 ..< itemView.count), id: \.self) {
                        index in

                        itemView[index]
                            .frame(minWidth: 40)
                            .zIndex(2)
                            .background(
                                GeometryReader { g in
                                    Color.white.opacity(0.01)
                                        .onAppear { itemSize[index] = g.size }
                                        .onChange(of: g.size) { _ in itemSize[index] = g.size }
                                }
                            )
                            .padding(.horizontal, -0.5)

                        if index != itemView.count - 1 && !hiddenDivider {
                            ZStack {
                                Divider()
                                    .frame(width: style == .vertical ? maxWidth() : (!disableFocus && (fouced == index || fouced == index + 1) ? 2 : 1),
                                           height: style == .horizontal ? maxHeight() : (!disableFocus && (fouced == index || fouced == index + 1) ? 2 : 1))
                                    .background(!disableFocus && (fouced == index || fouced == index + 1) ? AKSUColor.primary : Color.gray)
                            }
                            .frame(width: style == .horizontal ? 2 : nil)
                            .frame(height: style == .vertical ? 2 : nil)
                        }
                    }
                }
                .background(
                    ZStack {
                        if !hiddenBoard {
                            RoundedRectangle(cornerRadius: AKSUAppearance.cornerRadius)
                                .stroke(Color.gray, lineWidth: 1)
                                .padding(1)

                            if fouced != nil && !disableFocus {
                                RoundedRectangle(cornerRadius: AKSUAppearance.cornerRadius)
                                    .stroke(AKSUColor.primary, lineWidth: 2)
                                    .padding(1)
                                    .mask {
                                        Color.black
                                            .padding(.trailing, getTrailling())
                                            .padding(.leading, getLeading())
                                            .padding(.bottom, getBottom())
                                            .padding(.top, getTop())
                                    }
                            }
                        }
                    }
                )
                .mask {
                    RoundedRectangle(cornerRadius: AKSUAppearance.cornerRadius)
                }
            } mouseEventCB: { point, _ in
                select(point: point)
                return false
            } outsideClick: { inside in
                if !inside {
                    fouced = nil
                }
            }
    }

    public func addView<V: View>(@ViewBuilder builder: () -> V) -> Self {
        var tmp = self
        tmp.itemView.append(AnyView(builder()))
        return tmp
    }

    func select(point: CGPoint) {
        // 理论上同一个元素 不是 @State 的变化应该会重新生成元素的，但是不知道为 style 有点问题，所以不能直接用过style 判断排列顺序
        // 所以直接通过试探判断出是那种方式
        var style: AKSUGroupStyle = .vertical
        if let first = itemSize.first {
            if point.x > first.value.width {
                style = .horizontal
            } else if point.y > first.value.height {
                style = .vertical
            } else {
                fouced = 0
                return
            }
        }

        if style == .horizontal {
            var totalWidth = point.x
            for item in 0 ..< itemView.count {
                let width = itemSize[item]?.width ?? 0
                if totalWidth < width {
                    fouced = item
                    return
                } else {
                    totalWidth -= (width + 1)
                }
            }
        } else if style == .vertical {
            var totalHeight = point.y
            for item in 0 ..< itemView.count {
                let height = itemSize[item]?.height ?? 0
                if totalHeight < height {
                    fouced = item
                    return
                } else {
                    totalHeight -= (height + 1)
                }
            }
        }
    }

    func maxWidth() -> CGFloat {
        var rv = 0.0
        for item in 0 ..< itemView.count {
            let width = itemSize[item]?.width ?? 0
            rv = max(rv, width)
        }
        return rv
    }

    func maxHeight() -> CGFloat {
        var rv = 0.0
        for item in 0 ..< itemView.count {
            let height = itemSize[item]?.height ?? 0
            rv = max(rv, height)
        }
        return rv
    }

    func getLeading() -> CGFloat {
        if style == .vertical { return 0 }
        guard let fouced = fouced else { return 0 }

        var leading: CGFloat = 0
        for item in 0 ..< fouced {
            let width = itemSize[item]?.width ?? 0
            leading += width + (hiddenDivider ? 0 : 1)
        }

        return max(0, leading - 2)
    }

    func getTrailling() -> CGFloat {
        if style == .vertical { return 0 }
        guard let fouced = fouced else { return 0 }

        var trailling: CGFloat = 0
        for item in (fouced + 1) ..< itemView.count {
            let width = itemSize[item]?.width ?? 0
            trailling += width + (hiddenDivider ? 0 : 1)
        }
        return trailling - 2
    }

    func getTop() -> CGFloat {
        if style == .horizontal { return 0 }
        guard let fouced = fouced else { return 0 }
        var top: CGFloat = 0
        for item in 0 ..< fouced {
            let height = itemSize[item]?.height ?? 0
            top += height + (hiddenDivider ? 0 : 1)
        }

        return top + 1
    }

    func getBottom() -> CGFloat {
        if style == .horizontal { return 0 }
        guard let fouced = fouced else { return 0 }

        var bottom: CGFloat = 0
        for item in (fouced + 1) ..< itemView.count {
            let height = itemSize[item]?.height ?? 0
            bottom += height + (hiddenDivider ? 0 : 1)
        }
        return bottom + 1
    }
}

struct AKSUGroup_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AKSUGroupPreviewsView()
        }
        .frame(width: 1000, height: 600)
    }
}

struct AKSUGroupPreviewsView: View {
    @State var focued: Int? = nil
    @State var input: String = ""
    @State var style: AKSUGroupStyle = .horizontal
    @State var hiddenDivider: Bool = false
    @State var hiddenBoard: Bool = false
    @State var disableFocus: Bool = false

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("排列方式")
                }.frame(width: 80)
                AKSUSegment(selected: $style) {
                    Text("水平").AKSUSegmentTag(index: .horizontal)
                    Text("垂直").AKSUSegmentTag(index: .vertical)
                }
                .frame(width: 200)
            }

            HStack {
                VStack(alignment: .leading) {
                    Text("分割线")
                }.frame(width: 80)
                AKSUSegment(selected: $hiddenDivider) {
                    Text("启用").AKSUSegmentTag(index: false)
                    Text("禁用").AKSUSegmentTag(index: true)
                }
                .frame(width: 200)
            }
            HStack {
                VStack(alignment: .leading) {
                    Text("边框")
                }.frame(width: 80)
                AKSUSegment(selected: $hiddenBoard) {
                    Text("启用").AKSUSegmentTag(index: false)
                    Text("禁用").AKSUSegmentTag(index: true)
                }
                .frame(width: 200)
            }

            HStack {
                VStack(alignment: .leading) {
                    Text("焦点")
                }.frame(width: 80)

                AKSUSegment(selected: $disableFocus) {
                    Text("启用").AKSUSegmentTag(index: false)
                    Text("禁用").AKSUSegmentTag(index: true)
                }
                .frame(width: 200)
            }

            AKSUGroup(style: style, disableFocus: disableFocus, hiddenDivider: hiddenDivider, hiddenBoard: hiddenBoard)
                .addView {
                    AKSUInput(style: .plain, label: "输入内容", text: $input)
                        .frame(width: 200, height: 40)
                }
                .addView {
                    AKSUInput(style: .plain, label: "输入内容", text: $input)
                        .frame(width: 200, height: 40)
                }
                .addView {
                    AKSUInput(style: .plain, label: "输入内容", text: $input)
                        .frame(width: 200, height: 40)
                }

            AKSUGroup(style: style, disableFocus: disableFocus, hiddenDivider: hiddenDivider, hiddenBoard: hiddenBoard)
                .addView {
                    AKSUButton("xxx", style: .plain) {
                    }
                }
                .addView {
                    AKSUButton("xxx", style: .plain) {
                    }
                }
                .addView {
                    AKSUButton("xxx", style: .plain) {
                    }
                }

            AKSUGroup(style: style, disableFocus: disableFocus, hiddenDivider: hiddenDivider, hiddenBoard: hiddenBoard)
                .addView {
                    Text("xxx").frame(width: 100, height: 40)
                }
                .addView {
                    Text("xxx").frame(width: 100, height: 40)
                }
                .addView {
                    Text("xxx").frame(width: 100, height: 40)
                }
        }
    }
}
