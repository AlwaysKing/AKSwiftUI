//
//  AKFlex.swift
//  AKSwiftUI
//
//  Created by alwaysking on 2024/9/2.
//

import SwiftUI

struct AKSUFlexStack<Content: View>: View {
    @ViewBuilder var content: () -> Content

    let isLeftToRight: Bool
    let isTopToBottom: Bool
    let horizontal: Bool
    let edges: Edge.Set

    init(isLeftToRight: Bool = true, isTopToBottom: Bool = true, horizontal: Bool = true, edges: Edge.Set = [.trailing, .bottom], @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.isLeftToRight = isLeftToRight
        self.isTopToBottom = isTopToBottom
        self.horizontal = horizontal
        self.edges = edges
    }

    var body: some View {
        _VariadicView.Tree(FlexStackLayout(left: isLeftToRight, top: isTopToBottom, horizontal: horizontal, edges: edges), content: content)
    }
}

struct FlexStackLayout: _VariadicView_UnaryViewRoot {
    let left: Bool
    let top: Bool
    let horizontal: Bool
    let edges: Edge.Set

    @ViewBuilder
    func body(children: _VariadicView.Children) -> some View {
        GeometryReader { geometry in
            VStack {
                if edges.contains(.vertical) || edges.contains(.top) || edges.contains(.all) {
                    Spacer()
                }
                self.layout(geometry: geometry, children: children)
                if edges.contains(.vertical) || edges.contains(.bottom) || edges.contains(.all) {
                    Spacer()
                }
            }
        }
    }

    private func layout(geometry: GeometryProxy, children: _VariadicView.Children) -> some View {
        let computer = FlexStackLayoutOffset(stackWidth: geometry.size.width, stackHeight: geometry.size.height, left: left, top: top, horizontal: horizontal)
        return HStack(alignment: .center) {
            if edges.contains(.horizontal) || edges.contains(.leading) || edges.contains(.all) {
                Spacer()
            }
            ZStack(alignment: .topLeading) {
                ForEach(children) { child in
                    child
                        .alignmentGuide(.leading, computeValue: { d in
                            // 主要是收集所有组件的大小
                            return computer.getX(size: CGSize(width: d.width, height: d.height))
                        })
                        .alignmentGuide(.top, computeValue: { d in
                            let last = child.id == children.last?.id
                            // 开始计算
                            return computer.getY(last: last)
                        })
                }
            }
            if edges.contains(.horizontal) || edges.contains(.trailing) || edges.contains(.all) {
                Spacer()
            }
        }
    }
}

private class FlexStackLayoutOffset {
    var index: Int = 0
    var sizeList: [Int: CGSize] = [:]

    let stackWidth: CGFloat
    let stackHeight: CGFloat

    var currentHeight: CGFloat = 0

    let left: Bool
    let top: Bool
    let horizontal: Bool

    init(stackWidth: CGFloat, stackHeight: CGFloat, left: Bool, top: Bool, horizontal: Bool) {
        self.stackHeight = stackHeight
        self.stackWidth = stackWidth
        self.left = left
        self.top = top
        self.horizontal = horizontal
    }

    func getX(size: CGSize) -> CGFloat {
        if horizontal {
            return getHX(size: size)
        } else {
            return getVX(size: size)
        }
    }

    func getY(last: Bool) -> CGFloat {
        if horizontal {
            return getHY(last: last)
        } else {
            return getVY(last: last)
        }
    }

    func getHX(size: CGSize) -> CGFloat {
        // 存入仓库
        sizeList[index] = size

        var width = 0.0
        var maxHiehgt = 0.0
        currentHeight = 0
        for no in 0 ... index {
            let itemWidth = sizeList[no]!.width
            let itemHeight = sizeList[no]!.height

            if no == index {
                if width + itemWidth > stackWidth {
                    width = 0
                    currentHeight += maxHiehgt
                    maxHiehgt = itemHeight
                }

                if !left {
                    width += itemWidth
                }

                if !top {
                    currentHeight += itemHeight
                }
            } else {
                width += itemWidth

                if width > stackWidth {
                    width = itemWidth
                    currentHeight += maxHiehgt
                    maxHiehgt = itemHeight
                } else {
                    maxHiehgt = max(maxHiehgt, itemHeight)
                }
            }
        }

        if left {
            return 0 - width
        } else {
            return width
        }
    }

    func getHY(last: Bool) -> CGFloat {
        index += 1
        if last { index = 0 }
        let height = currentHeight
        currentHeight = 0

        if top {
            return 0 - height
        } else {
            return height
        }
    }

    func getVX(size: CGSize) -> CGFloat {
        // 存入仓库
        sizeList[index] = size

        var width = 0.0
        var maxWidth = 0.0
        currentHeight = 0
        for no in 0 ... index {
            let itemWidth = sizeList[no]!.width
            let itemHeight = sizeList[no]!.height

            if no == index {
                if currentHeight + itemHeight > stackHeight {
                    currentHeight = 0
                    width += maxWidth
                    maxWidth = itemWidth
                }
                if !left {
                    width += itemWidth
                }

                if !top {
                    currentHeight += itemHeight
                }
            } else {
                currentHeight += itemHeight
                if currentHeight > stackHeight {
                    currentHeight = itemHeight
                    width += maxWidth
                    maxWidth = itemWidth
                } else {
                    maxWidth = max(maxWidth, itemWidth)
                }
            }
        }

        if left {
            return 0 - width
        } else {
            return width
        }
    }

    func getVY(last: Bool) -> CGFloat {
        index += 1
        if last { index = 0 }
        let height = currentHeight
        currentHeight = 0

        if top {
            return 0 - height
        } else {
            return height
        }
    }
}

struct AKSUFlex_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AKSUFlexPreviewsView()
        }
        .frame(width: 600, height: 600)
    }
}

struct AKSUFlexPreviewsView: View {
    @State var left: Bool = true
    @State var top: Bool = true
    @State var horizontal: Bool = true

    @State var edges: [Edge.Set] = []

    var body: some View {
        VStack {
            HStack {
                AKSUButton("水平") {
                    horizontal = true
                }
                AKSUButton("垂直") {
                    horizontal = false
                }
            }

            VStack {
                AKSUContainBox(label: "All", key: .all, list: $edges)
                HStack {                    
                    AKSUContainBox(label: "horizontal", key: .horizontal, list: $edges)
                    AKSUContainBox(label: "leading", key: .leading, list: $edges)
                    AKSUContainBox(label: "trailing", key: .trailing, list: $edges)
                }
                HStack {
                    AKSUContainBox(label: "vertical", key: .vertical, list: $edges)
                    AKSUContainBox(label: "top", key: .top, list: $edges)
                    AKSUContainBox(label: "bottom", key: .bottom, list: $edges)
                }
            }

            HStack {
                AKSUButton("左") {
                    left = true
                }
                VStack {
                    AKSUButton("上") {
                        top = true
                    }
                    AKSUFlexStack(isLeftToRight: left, isTopToBottom: top, horizontal: horizontal, edges: Edge.Set(edges)) {
                        ForEach(Array(1 ... 5), id: \.self) {
                            index in

                            VStack {
                                Text("\(index)")
                            }
                            .frame(width: 55, height: 55)
                            .background(.green)
                            .padding(3)
                        }
                    }
                    .frame(width: 200, height: 200)
                    .background(.blue)
                    AKSUButton("下") {
                        top = false
                    }
                }

                AKSUButton("右") {
                    left = false
                }
            }
        }
    }
}
