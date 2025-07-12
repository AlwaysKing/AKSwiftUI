//
//  AKSUStepScrollview.swift
//  AKSwiftUI
//
//  Created by AlwaysKing on 2025/3/5.
//

import SwiftUI

public enum AKSUStepScrollviewDirection {
    case vertical
    case horizontal
}

public enum AKSUStepScrollviewAlignment {
    case head
    case center
    case end
}

public struct AKSUStepScrollview<K, V: View>: View {
    @State var boardSize: CGSize = .zero
    @State var contentSize: CGSize = .zero
    @State var showIndex: [Int] = []

    @State var leftHovering: Bool = false
    @State var rightHovering: Bool = false
    @State var showPreBtn: Bool = false
    @State var showNextBtn: Bool = false

    let keys: [K]
    let direction: AKSUStepScrollviewDirection
    let alignment: AKSUStepScrollviewAlignment
    let btnSmartHidden: Bool
    let crossShrink: Bool
    let contentBuilder: (K) -> V

    var btnBuilder: ((Bool, CGFloat, @escaping () -> Void) -> AnyView)? = nil

    public init(keys: [K], direction: AKSUStepScrollviewDirection = .horizontal, alignment: AKSUStepScrollviewAlignment = .center, crossShrink: Bool = true, btnSmartHidden: Bool = false, contentBuilder: @escaping (K) -> V) {
        self.keys = keys
        self.direction = direction
        self.crossShrink = crossShrink
        self.contentBuilder = contentBuilder
        self.btnSmartHidden = btnSmartHidden
        self.alignment = alignment
    }

    public var body: some View {
        ScrollViewReader { scrollProxy in
            ZStack {
                AKSUStackView(stack: direction == .horizontal ? .hstack : .vstack) {
                    if alignment != .head {
                        Spacer()
                    }
                    if showPreButton() {
                        if let btnBuilder = btnBuilder {
                            btnBuilder(true, crossSize()) {
                                scrollProxy.scrollTo(max((showIndex.min() ?? 0) - 1, 0), anchor: direction == .horizontal ? .leading : .top)
                            }
                        } else {
                            ZStack {
                                Image(systemName: direction == .horizontal ? "chevron.compact.left" : "chevron.compact.up")
                                    .foregroundStyle(.aksuWhite)
                            }
                            .frame(width: direction == .horizontal ? 20 : 40, height: direction == .horizontal ? 40 : 20)
                            .background(leftHovering ? .aksuGrayMask : .aksuGrayBackground)
                            .cornerRadius(8)
                            .onHover {
                                leftHovering = $0
                                if $0 {
                                    NSCursor.pointingHand.push()
                                } else {
                                    NSCursor.pop()
                                }
                            }
                            .onTapGesture {
                                scrollProxy.scrollTo(max((showIndex.min() ?? 0) - 1, 0), anchor: direction == .horizontal ? .leading : .top)
                            }
                        }
                    }

                    AKSUScrollView(direction == .horizontal ? .horizontal : .vertical, showsIndicators: false) {
                        AKSULazyStackView(stack: direction == .horizontal ? .hstack : .vstack) {
                            ForEach(Array(0 ..< keys.count), id: \.self) {
                                no in
                                contentBuilder(keys[no])
                                    .id(no)
                                    .onDisappear {
                                        showIndex.removeAll { $0 == no }
                                    }
                                    .onAppear {
                                        showIndex.append(no)
                                    }
                            }
                        }
                        .fixedSize(horizontal: crossShrink, vertical: crossShrink)
                        .background {
                            GeometryReader { contentProxy in
                                Color.clear
                                    .onAppear {
                                        contentSize = contentProxy.size
                                    }
                                    .onChange(of: contentProxy.size) { _ in
                                        contentSize = contentProxy.size
                                    }
                            }
                        }
                    }
                    .monitor { info in
                        if direction == .horizontal {
                            showPreBtn = !info.lead
                            showNextBtn = !info.tail
                        } else {
                            showPreBtn = !info.top
                            showNextBtn = !info.bottom
                        }
                    }
                    .frame(maxWidth: width(), maxHeight: height())

                    if showNextButton() {
                        if let btnBuilder = btnBuilder {
                            btnBuilder(false, crossSize()) {
                                scrollProxy.scrollTo(min((showIndex.max() ?? 0) + 1, keys.count - 1), anchor: direction == .horizontal ? .trailing : .bottom)
                            }
                        } else {
                            ZStack {
                                Image(systemName: direction == .horizontal ? "chevron.compact.right" : "chevron.compact.down")
                                    .foregroundStyle(.aksuWhite)
                            }
                            .frame(width: direction == .horizontal ? 20 : 40, height: direction == .horizontal ? 40 : 20)
                            .background(rightHovering ? .aksuGrayMask : .aksuGrayBackground)
                            .cornerRadius(8)
                            .onHover {
                                rightHovering = $0
                                if $0 {
                                    NSCursor.pointingHand.push()
                                } else {
                                    NSCursor.pop()
                                }
                            }
                            .onTapGesture {
                                scrollProxy.scrollTo(min((showIndex.max() ?? 0) + 1, keys.count - 1), anchor: direction == .horizontal ? .trailing : .bottom)
                            }
                        }
                    }

                    if alignment != .end {
                        Spacer()
                    }
                }

                // 获取宽度
                AKSUStackView(stack: direction == .horizontal ? .hstack : .vstack) {
                    Spacer()
                }
                .background {
                    GeometryReader { contentProxy in
                        Color.clear
                            .onAppear {
                                boardSize = contentProxy.size
                            }
                            .onChange(of: contentProxy.size) { _ in
                                boardSize = contentProxy.size
                            }
                    }
                }
            }
        }
    }

    func width() -> CGFloat? {
        if direction == .horizontal {
            if contentSize.width < boardSize.width {
                return contentSize.width
            }
        }
        return nil
    }

    func height() -> CGFloat? {
        if direction == .vertical {
            if contentSize.height < boardSize.height {
                return contentSize.height
            }
        }
        return nil
    }

    func crossSize() -> CGFloat {
        return direction == .horizontal ? contentSize.height : contentSize.width
    }

    func showPreButton() -> Bool {
        if !showButton() {
            return false
        }

        if showPreBtn {
            return true
        }

        if btnSmartHidden {
            return false
        }
        return true
    }

    func showNextButton() -> Bool {
        if !showButton() {
            return false
        }

        if showNextBtn {
            return true
        }

        if btnSmartHidden {
            return false
        }
        return true
    }

    func showButton() -> Bool {
        if direction == .horizontal {
            if contentSize.width > boardSize.width {
                return true
            }
        } else {
            if contentSize.height > boardSize.height {
                return true
            }
        }
        return false
    }

    public func setBtnViewBuilder<btn: View>(_ builder: @escaping (_ head: Bool, _ direction: AKSUStepScrollviewDirection, _ size: CGFloat, _ click: @escaping () -> Void) -> btn) -> AKSUStepScrollview {
        var rv = self
        rv.btnBuilder = { head, size, click in
            AnyView(builder(head, rv.direction, size, click))
        }
        return rv
    }
}

struct AKSUStepScrollview_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AKSUStepScrollviewPreviewsView()
        }
        .frame(width: 600, height: 600)
    }
}

struct AKSUStepScrollviewPreviewsView: View {
    @State var count: Int = 20
    @State var direction: AKSUStepScrollviewDirection = .horizontal
    @State var alignment: AKSUStepScrollviewAlignment = .center

    var body: some View {
        VStack {
            HStack {
                AKSUButton("-") {
                    count -= 1
                }

                Text("\(count)")
                    .padding(.horizontal)

                AKSUButton("+") {
                    count += 1
                }
            }

            AKSUSegment(selected: $direction) {
                Text("垂直").AKSUSegmentTag(index: .vertical)
                Text("水平").AKSUSegmentTag(index: .horizontal)
            }

            AKSUSegment(selected: $alignment) {
                Text("head").AKSUSegmentTag(index: .head)
                Text("center").AKSUSegmentTag(index: .center)
                Text("end").AKSUSegmentTag(index: .end)
            }
            .padding(.bottom, direction == .vertical ? 10 : 100)

            AKSUStepScrollview(keys: Array(0 ... count), direction: direction, alignment: alignment) { key in
                Text("\(key)")
                    .frame(width: 100)
                    .padding()
                    .foregroundStyle(.white)
                    .background(.green)
                    .cornerRadius(4)
            }

            AKSUStepScrollview(keys: Array(0 ... count), direction: direction, alignment: alignment, btnSmartHidden: true) { key in
                Text("\(key)")
                    .frame(width: 100)
                    .padding()
                    .foregroundStyle(.white)
                    .background(.green)
                    .cornerRadius(4)
            }

            AKSUStepScrollview(keys: Array(0 ... count), direction: direction, alignment: alignment, btnSmartHidden: true) { key in
                Text("\(key)")
                    .frame(width: 100)
                    .padding()
                    .foregroundStyle(.white)
                    .background(.green)
                    .cornerRadius(4)
            }
            .setBtnViewBuilder(ClickBtn)
        }
    }

    @State var leftHovering: Bool = false
    @State var rightHovering: Bool = false

    @ViewBuilder
    func ClickBtn(head: Bool, direction: AKSUStepScrollviewDirection, size: CGFloat, click: @escaping () -> Void) -> some View {
        ZStack {
            if head {
                Image(systemName: direction == .horizontal ? "chevron.compact.left" : "chevron.compact.up")

            } else {
                Image(systemName: direction == .horizontal ? "chevron.compact.right" : "chevron.compact.down")
            }
        }
        .frame(width: direction == .horizontal ? 10 : size, height: direction == .vertical ? 10 : size)
        .background(.white.opacity(0.01))
        .onHover {
            if head {
                leftHovering = $0
            } else {
                rightHovering = $0
            }
        }
        .opacity(head ? (leftHovering ? 0.5 : 1) : (rightHovering ? 0.5 : 1))
        .onTapGesture {
            click()
        }
    }
}
