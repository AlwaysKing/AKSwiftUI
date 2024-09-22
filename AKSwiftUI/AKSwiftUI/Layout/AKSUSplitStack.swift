//
//  SpliteView.swift
//  AKSwiftUI
//
//  Created by AlwaysKing on 2024/9/6.
//

import SwiftUI

enum AKSUSplitStackDirection {
    case vertical
    case horizontal
}

struct AKSUSplitStack: View {
    var content: [AKSUSplitStackItemView]
    let direction: AKSUSplitStackDirection

    init(direction: AKSUSplitStackDirection = .horizontal, @AKSUSplitStackItemBuilder content: @escaping () -> [AKSUSplitStackItemView]) {
        self.content = content()
        self.direction = direction
    }

    var body: some View {
//        if direction == .horizontal {
//            _VariadicView.Tree(AKSUSplitHorizontalLayout(), content: content)
//        } else {
//            _VariadicView.Tree(AKSUSplitVerticalLayout(), content: content)
        AKSUSplitHorizontalLayout(children: content)
//        }
    }
}

struct AKSUSplitVerticalLayout: _VariadicView_UnaryViewRoot {
    @ViewBuilder
    func body(children: _VariadicView.Children) -> some View {
        VStack {
            ForEach(children) { child in
                child
            }
        }
    }
}

struct AKSUSplitHorizontalLayout: View {
    @State var totalLength: CGFloat = 0
    @State var lengths: [(tmp: CGFloat, current: CGFloat, min: CGFloat, max: CGFloat)] = []
    @State var children: [AKSUSplitStackItemView]
    @State var startDrag: NSPoint?
    @State var startChange: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // content
                HStack(spacing: 0) {
                    ForEach(Array(0 ..< children.count), id: \.self) { index in
                        children[index]
                            .frame(width: index < lengths.count ? lengths[index].tmp : 0.0)
                    }
                }.frame(maxWidth: .infinity, alignment: .leading)

                // bar
                HStack(spacing: 0) {
                    ForEach(Array(0 ..< lengths.count), id: \.self) { index in
                        if index < lengths.count - 1 {
                            AKSUSplitBar()
                                .padding(.leading, lengths[index].0 - (index == 0 ? 5 : 10))
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            if let startDrag = startDrag {
                                                let new = NSEvent.mouseLocation
                                                changeLength(index: index, change: new.x - startDrag.x + startChange, end: false)
                                            } else {
                                                startDrag = NSEvent.mouseLocation
                                                startChange = value.location.x - value.startLocation.x
                                                if let startDrag = startDrag {
                                                    let new = NSEvent.mouseLocation
                                                    changeLength(index: index, change: new.x - startDrag.x + startChange, end: false)
                                                }
                                            }
                                        }
                                        .onEnded { value in
                                            if let startDrag = startDrag {
                                                let new = NSEvent.mouseLocation
                                                changeLength(index: index, change: new.x - startDrag.x + startChange, end: true)
                                            }
                                            startDrag = nil
                                        }
                                )
                        }
                    }
                }.frame(maxWidth: .infinity, alignment: .leading)
            }
            .onAppear {
                resize(length: geometry.size.width)
            }
            .onChange(of: geometry.size) { _ in
                resize(length: geometry.size.width)
            }
        }
    }

    func resize(length: CGFloat) {
        if lengths.count == 0 {
            // 初始化内容
            lengths = [(CGFloat, CGFloat, CGFloat, CGFloat)](repeating: (0, 0, 0, 0), count: children.count)

            // 先给有idea的分配idea
            for (index, item) in children.enumerated() {
                if let idea = item.idea {
                    lengths[index] = (idea, idea, item.min ?? 10, item.max ?? 4096000)
                    totalLength += idea
                } else if let max = item.max {
                    lengths[index] = (max, max, item.min ?? 10, item.max ?? 4096000)
                    totalLength += max
                } else if let min = item.min {
                    lengths[index] = (min, min, item.min ?? 10, item.max ?? 4096000)
                    totalLength += min
                }
            }
        }

        // 开始缩放
        if totalLength > length {
            // 收缩
            var subed = false
            let perSub = (totalLength - length) / CGFloat(children.count)
            for (index, item) in children.enumerated() {
                let new = lengths[index].tmp - perSub
                if lengths[index].tmp == 10 {
                    continue
                }

                if let min = item.min, new < min {
                    totalLength -= lengths[index].tmp - min
                    if lengths[index].tmp != min {
                        subed = true
                    }
                    lengths[index].tmp = min
                    lengths[index].current = min
                } else if new < 10 {
                    totalLength -= lengths[index].0 - 10
                    lengths[index].tmp = 10
                    lengths[index].current = 10
                    subed = true
                } else {
                    totalLength -= perSub
                    lengths[index].tmp = new
                    lengths[index].current = new
                    subed = true
                }
            }

            if abs(totalLength - length) > 1.0 {
                if subed {
                    resize(length: length)
                }
//                else {
//                    // 说明没法减少了
//                    // 开始折叠
//                    for (index, _) in lengths.enumerated() {
//                        if lengths[index].0 != 10 {
//                            totalLength -= (lengths[index].0 - 10)
//                            lengths[index].0 = 10
//                            lengths[index].1 = 10
//                        }
//
//                        // 折叠够了
//                        if totalLength <= length {
//                            break
//                        }
//                    }
//
//                    // 折叠之后又太小了，要扩充一些
//                    if totalLength < length {
//                        resize(length: length)
//                    }
//                }
            }

        } else if totalLength < length {
            // 放大
            var added = false
            let perAdd = (length - totalLength) / CGFloat(children.count)
            for (index, item) in children.enumerated() {
                // 折叠的跳过
                if lengths[index].tmp == 10 {
                    continue
                }

                let new = lengths[index].tmp + perAdd
                if let max = item.max, new > max {
                    totalLength += max - lengths[index].0
                    if lengths[index].tmp != max {
                        added = true
                    }
                    lengths[index].tmp = max
                    lengths[index].current = max
                } else {
                    totalLength += perAdd
                    lengths[index].tmp = new
                    lengths[index].current = new
                    added = true
                }
            }
            if added && abs(totalLength - length) > 1.0 {
                resize(length: length)
            }
        }

        print("=============================================================")
        for (index, item) in lengths.enumerated() {
            print("index :\(index)    \(item.tmp) / \(item.current)")
        }
    }

    func changeLength(index: Int, change: CGFloat, end: Bool) {
        let current = lengths[index].current
        print("=============================================================")
        print("初始化 index:\(index) \(lengths[index].current) change:\(change)")
        for no in 0 ..< lengths.count {
            lengths[no].tmp = lengths[no].current
        }

        if change < 0 {
            // 缩小
//            print("index:\(index) 缩小")
            var newLength = current + change
//            print("index:\(index) 缩小后的尺寸为 \(newLength)")
            if newLength < lengths[index].min {
//                print("index:\(index) 缩小后的尺寸小于最小尺寸了, 折叠\(lengths[index].min)")
                newLength = 10
            }

            if current == 10 && index != 0 {
                // 尝试缩小前面的
                changeLength(index: index - 1, change: change, end: end)
                return
            } else if newLength == current {
//                print("index:\(index) 缩小后的尺寸无变化, 结束")
                return
            }
            var realChange = current - newLength
//            print("index:\(index) 尺寸缩小了 \(realChange)")

            // 向后寻找可增加的项目
//            print("先尝试向已经展开的视图分配空间")
            for next in index + 1 ..< children.count {
                if lengths[next].current == 10 {
//                    print("next: \(next) 折叠了暂时不分配展开")
                    continue
                }
                // 那么就开始增加了
                let canUsed = lengths[next].max - lengths[next].current
//                print("next: \(next) 当前大小 \(lengths[next].current) 可接收的大小为 \(canUsed)")
                let realUsed = min(canUsed, realChange)
//                print("next: \(next) 实际接收大小为 \(realUsed)")
                lengths[next].tmp = lengths[next].current + realUsed
//                print("next: \(next) 实际大小变更为 \(lengths[next].tmp)")
                realChange -= realUsed
//                print("next: \(next) 剩余待分配尺寸为 \(realChange)")
                if realChange <= 0 {
//                    print("next: \(next) 尺寸已全部分配完成")
                    break
                }
            }

            // 如果还有宽裕，可是试着展开
            if realChange > 0 {
//                print("已经展开的视图无法接收全部的空间, 开始向后寻找可以展开接收空间的视图")
                for next in index + 1 ..< children.count {
                    if lengths[next].1 != 10 {
//                        print("next: \(next) 已经是展开状态了")
                        continue
                    }

//                    print("next: \(next) 尝试展开")
                    let minNeed = lengths[next].min - lengths[next].current
//                    print("next: \(next) 的最小展开大小需要 \(minNeed)")
                    if minNeed <= realChange {
                        realChange -= minNeed
                        lengths[next].tmp = minNeed + lengths[next].current
//                        print("next: \(next) 展开后空间后空间仍然剩余 \(realChange), 尝试扩展")

                        let canUsed = lengths[next].max - lengths[next].tmp
//                        print("next: \(next) 仍然可接收的大小为 \(canUsed)")
                        let realUsed = min(canUsed, realChange)
//                        print("next: \(next) 实际接收大小为 \(realUsed)")
                        lengths[next].tmp = lengths[next].tmp + realUsed
//                        print("next: \(next) 实际大小变更为 \(lengths[next].tmp)")
                        realChange -= realUsed
//                        print("next: \(next) 剩余待分配尺寸为 \(realChange)")
                        if realChange <= 0 {
//                            print("next: \(next) 尺寸已全部分配完成")
                            break
                        }
                    } else {
                        // 空间不够了
                        let needMore = minNeed - realChange
//                        print("next: \(next) 展开后空间不足，需要多余的空间 \(needMore)")
                        let subNewLength = newLength - needMore
//                        print("next: \(next) 再次缩减后 index:\(index) 的空间缩减为 \(subNewLength)")
                        if subNewLength < lengths[index].min {
//                            print("next: \(next) index:\(index) 再次缩减后的空间不足，所以无法展开")
                        } else {
//                            print("next: \(next) 空间足够, 准备展开")
                            newLength = subNewLength
                            lengths[next].tmp = minNeed + lengths[next].current
//                            print("next: \(next) 尺寸已全部分配完成")
                            realChange = 0
                            break
                        }
                    }
                }
            }

            if realChange != 0 {
//                print("index:\(index) 剩余的空间 \(realChange) 无法缩小")
//                changeLength(index: index - 1, change: -realChange, end: end)
                return
            }
            lengths[index].0 = newLength + realChange
        } else {
            // 放大
//            print("index:\(index) 放大")
            var newLength = current + change
//            print("index:\(index) 放大后的尺寸为 \(newLength)")
            if newLength < lengths[index].min {
                newLength = lengths[index].min
            }
            if newLength > lengths[index].max {
//                print("index:\(index) 放大后的尺寸大于最大尺寸了, 限制\(lengths[index].max)")
                newLength = lengths[index].max
            }
            if newLength == current {
//                print("index:\(index) 放大后的尺寸无变化, 结束")
                return
            }

            var realChange = newLength - current
//            print("index:\(index) 尺寸放大了 \(realChange)")

//            print("先尝试向已经展开的视图缩减空间")
            for next in index + 1 ..< children.count {
                if lengths[next].current == 10 {
//                    print("next: \(next) 折叠了无法再缩减了")
                    continue
                }
                // 逐个缩减
                let canshark = lengths[next].current - lengths[next].min
//                print("next: \(next) 当前大小 \(lengths[next].current) 可缩减的大小为 \(canshark)")
                let realShark = min(canshark, realChange)
//                print("next: \(next) 实际接收大小为 \(realShark)")
                lengths[next].tmp = lengths[next].current - realShark
//                print("next: \(next) 实际大小变更为 \(lengths[next].tmp)")
                realChange -= realShark
//                print("next: \(next) 剩余待分配尺寸为 \(realChange)")
                if realChange <= 0 {
                    print("next: \(next) 尺寸已全部分配完成")
                    break
                }
            }

            // 说明不够缩减, 可以试着 压缩
            if realChange > 0 {
//                print("已经展开的视图无法收缩全部的空间, 开始向后寻找可以折叠空间的视图")
                for next in (index + 1 ..< children.count).reversed() {
                    if lengths[next].current == 10 {
//                        print("next: \(next) 折叠了无法再缩减了")
                        continue
                    }
                    let canShark = lengths[next].tmp - 10
//                    print("next: \(next) 折叠后可再接收 \(canShark)")

                    if realChange >= canShark {
                        realChange -= canShark
                        lengths[next].tmp = lengths[next].tmp - canShark
//                        print("next: \(next) 折叠空间后空间仍然剩余 \(realChange)")
                        if realChange <= 0 {
//                            print("next: \(next) 尺寸已全部分配完成")
                            break
                        }
                    } else {
                        let needMore = canShark - realChange
//                        print("next: \(next) 折叠后空间过大，需要多余的空间 \(needMore)")
                        let addNewLength = newLength + needMore
//                        print("next: \(next) 再次扩展后 index:\(index) 的空间增加为 \(addNewLength)")
                        if addNewLength > lengths[index].max {
//                            print("next: \(next) index:\(index) 再次扩展后的空间过大，所以无法折叠")
                        } else {
//                            print("next: \(next) 空间足够, 准备折叠")
                            newLength = addNewLength
                            lengths[next].tmp = lengths[next].tmp - canShark
                            print("next: \(next) 尺寸已全部分配完成")
                            realChange = 0
                            break
                        }
                    }
                }
            }

            if realChange != 0 {
                print("index:\(index) 剩余的空间 \(realChange) 无法扩大")
            }
            lengths[index].0 = newLength - realChange
        }

        if end {
            for no in 0 ..< lengths.count {
                lengths[no].current = lengths[no].tmp
            }
        }

//        print("--------------------------------------")
//        for (index, item) in lengths.enumerated() {
//            print("index :\(index) \(item.tmp) / \(item.current)")
//        }
    }
}

struct AKSUSplitBar: View {
    @State var hovering: Bool = false

    var body: some View {
        VStack {
        }
        .frame(width: 10)
        .frame(maxHeight: .infinity)
        .background(.gray.opacity(hovering ? 1.0 : 0.4))
        .mask(Rectangle().frame(width: 2))
        .onHover {
            hovering = $0
            if hovering {
                NSCursor.resizeLeftRight.push()
            } else {
                NSCursor.pop()
            }
        }
    }
}

public struct AKSUSplitStackItemView: View {
    let content: [AnyView]
    let min: CGFloat?
    let idea: CGFloat?
    let max: CGFloat?
    let growth: Bool?

    init(min: CGFloat? = nil, idea: CGFloat? = nil, max: CGFloat? = nil, growth: Bool = true, @AKSUAnyViewArrayBuilder content: () -> [AnyView]) {
        self.content = content()
        self.min = min
        self.max = max
        self.idea = idea
        self.growth = growth
    }

    public var body: some View {
        ZStack {
            ForEach(Array(0 ..< self.content.count), id: \.self) { i in
                self.content[i]
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// AKSUDropdownItem 的 AKSUDropdownBuilder 定义
@resultBuilder public enum AKSUSplitStackItemBuilder {
    static func buildBlock() -> [AKSUSplitStackItemView] {
        []
    }

    public static func buildBlock(_ components: AKSUSplitStackItemView...) -> [AKSUSplitStackItemView] {
        components
    }

    public static func buildBlock(_ components: [AKSUSplitStackItemView]...) -> [AKSUSplitStackItemView] {
        components.flatMap {
            $0
        }
    }

    public static func buildExpression(_ expression: AKSUSplitStackItemView) -> [AKSUSplitStackItemView] {
        [expression]
    }

    public static func buildExpression(_ expression: ForEach<Range<Int>, Int, AKSUSplitStackItemView>) -> [AKSUSplitStackItemView] {
        expression.data.map {
            expression.content($0)
        }
    }

    public static func buildEither(first: [AKSUSplitStackItemView]) -> [AKSUSplitStackItemView] {
        return first
    }

    public static func buildEither(second: [AKSUSplitStackItemView]) -> [AKSUSplitStackItemView] {
        return second
    }

    public static func buildIf(_ element: [AKSUSplitStackItemView]?) -> [AKSUSplitStackItemView] {
        return element ?? []
    }
}

extension View {
    func AKSUSplitItem(min: CGFloat? = nil, idea: CGFloat? = nil, max: CGFloat? = nil, growth: Bool = true) -> AKSUSplitStackItemView {
        AKSUSplitStackItemView(min: min, idea: idea, max: max, growth: growth, content: { self })
    }
}

struct AKSUSplitStack_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AKSUSplitStackPreviewsView()
        }
        .frame(width: 800, height: 800)
    }
}

struct AKSUSplitStackPreviewsView: View {
    @State var left: Bool = true
    @State var top: Bool = true
    @State var horizontal: Bool = true

    @State var edges: [Edge.Set] = []

    var body: some View {
        AKSUSplitStack {
            VStack {}
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.red)
                .AKSUSplitItem(min: 200)

            VStack {}
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.green)
                .AKSUSplitItem(min: 200)

            VStack {}
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.blue)
                .AKSUSplitItem(min: 200)
        }
    }
}
