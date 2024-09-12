//
//  AKSUDropdown.swift
//  AKSwiftUI
//
//  Created by alwaysking on 2024/8/30.
//

import SwiftUI

enum AKSUDropdownStyle {
    case select
    case selectBtn
}

// AKSUDropdown 本体定义
struct AKSUDropdown<K: Hashable>: View {
    @Environment(\.isEnabled) private var isEnabled

    var style: AKSUDropdownStyle
    var plain: Bool
    @Binding var selected: K
    var color: Color
    var bgColor: Color
    var height: CGFloat?
    var dropMaxHeight: CGFloat?
    var content: [K: AKSUDropdownItem<K>] = [:]
    var sort: [K] = []
    let menu = AKSUMenu()

    @State var contentRealHeight: CGFloat = 0.0
    @State var selectedRealHeight: CGFloat = 0.0
    // 显示内容
    @State private var showDrop: Bool = false
    // hover
    @State var hoveringAll: Bool = false
    @State var hoveringContent: Bool = false
    @State var hoveringToggle: Bool = false

    @State var location: CGRect = CGRect.zero
    @State var mouseEvent: NSEvent? = nil

    init(style: AKSUDropdownStyle = .select, selected: Binding<K>, plain: Bool = false, color: Color = .white, bgColor: Color = AKSUColor.primary, height: CGFloat? = nil, dropHeight: CGFloat? = nil, @AKSUDropdownBuilder<K> content: () -> [AKSUDropdownItem<K>]) {
        self._selected = selected
        for item in content() {
            self.content[item.index] = AKSUDropdownItem(index: item.index, color: bgColor, content: item.content, action: item.action)
            self.sort.append(item.index)
        }
        self.plain = plain
        self.color = color
        self.bgColor = bgColor
        self.height = height
        self.dropMaxHeight = dropHeight
        self.style = style
        self.plain = plain
    }

    var body: some View {
        HStack(spacing: 0) {
            // 文本
            ZStack {
                if let show = content[selected] {
                    show.disableHover(canAction: self.style == .selectBtn) {
                        _, new in
                        self.selectedRealHeight = new
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 18)
            .padding([.top, .bottom], 10)
            .frame(height: self.height)
            .background(self.hoveringContent && self.style == .selectBtn ? .black.opacity(0.1) : .clear)
            .onHover {
                self.hoveringContent = $0
            }
            .simultaneousGesture(
                TapGesture()
                    .onEnded {
                        if style != .selectBtn {
                            if let mouseEvent = mouseEvent {
                                ToggleDropMenu(event: mouseEvent)
                            }
                        }
                    }
            )
//            .onMouseEvent(event: [.leftMouseDown]) { point, event in
//                mouseEvent = event
//            }

            // 分隔符
            if self.style == .selectBtn {
                VStack {}
                    .frame(width: 1, height: self.selectedRealHeight)
                    .padding([.top, .bottom], 10)
                    .padding([.leading, .trailing], 0)
                    .background(AKSUColor.dyGrayMask)
            }

            // 下拉按钮
            VStack(spacing: 0) {
                Image(systemName: "triangleshape.fill")
                    .font(.system(size: 10))
                    .foregroundColor(self.color)
                    .rotationEffect(Angle(degrees: self.showDrop ? -180 : -90))
                    .padding(.trailing, 10)
            }
            .frame(height: self.selectedRealHeight)
            .padding([.leading, .top, .bottom], 10)
            .background(self.hoveringToggle && self.style == .selectBtn ? .black.opacity(0.1) : .clear)
            .onHover {
                self.hoveringToggle = $0
            }
            .onTapGesture {
                if let mouseEvent = mouseEvent {
                    ToggleDropMenu(event: mouseEvent)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(!self.isEnabled ? AKSUColor.dyGrayMask : .clear)
        .background(self.hoveringAll && self.style != .selectBtn ? .black.opacity(0.1) : .clear)
        .background(self.bgColor)
        .cornerRadius(self.plain ? 0 : 4)
        .onHover {
            self.hoveringAll = $0
        }
        .shadow(color: self.bgColor != .white ? self.bgColor : .black, radius: self.plain ? 0 : 2)
        .overlay {
            GeometryReader {
                g in
                Color.clear.onAppear {
                    location = g.frame(in: .global)
                }.onChange(of: g.frame(in: .global)) { _ in
                    location = g.frame(in: .global)
                }
            }
        }
        .onMouseEvent(event: [.leftMouseDown]) { point, event in
            mouseEvent = event
            return false
        }
    }

    func ToggleDropMenu(event: NSEvent) {
        if !showDrop {
            menu.menuContent = AnyView(menuContent())
            menu.hiddenEvent = {
                withAnimation {
                    showDrop = false
                }
            }

            menu.showView(point: CGPoint(x: location.minX, y: location.maxY + 2), width: location.width, height: 300, view: event.window?.contentView)
        }

        withAnimation {
            showDrop.toggle()
        }
    }

    func menuContent() -> some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(self.sort, id: \.self) { index in
                        if self.style == .select || index != self.selected {
                            self.content[index]!
                                .binding(canAction: self.style == .selectBtn, b: { old, new in
                                    self.contentRealHeight -= old
                                    self.contentRealHeight += new
                                })
                                .onMouseEvent(event: [.leftMouseDown]) { _, _ in
                                    if self.style == .select {
                                        self.selected = index
                                    }
                                    self.showDrop = false
                                    menu.close()
                                    return true
                                }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(width: location.width, height: 300, alignment: .top)
        .background(.white)
    }
}

// AKSUDropdown Content Item 定义
public struct AKSUDropdownItem<K: Hashable>: View {
//    @EnvironmentObject var env: AKSUDropdownEnvironment
    var index: K
    var content: [AnyView]
    var action: (() -> Void)?

    var bind: ((CGFloat, CGFloat) -> Void)? = nil

    private var canAction: Bool = false
    private var hoverColor: Color = AKSUColor.primary
    @State private var hovering: Bool = false
    @State private var height: CGFloat = 0.0
    @State private var oldHeight: CGFloat = 0.0
    private var selected: Bool = false

    init(index: K, @AKSUAnyViewArrayBuilder content: () -> [AnyView], action: (() -> Void)? = nil) {
        self.index = index
        self.content = content()
        self.action = action
    }

    init(index: K, color: Color, content: [AnyView], action: (() -> Void)?) {
        self.index = index
        self.hoverColor = color
        self.content = content
        self.action = action
    }

    public var body: some View {
        HStack {
            ForEach(Array(0 ..< self.content.count), id: \.self) { i in
                self.content[i]
            }
        }
        .frame(maxWidth: .infinity)
        .padding([.top, .bottom], self.selected ? 0 : 10)
        .foregroundColor(self.selected || self.hovering ? .white : .black)
        .overlay {
            GeometryReader {
                g in
                Color.clear.task {
                    self.height = g.size.height
                }
            }
        }
        .onChange(of: self.height) { newValue in
            if let bind = bind, oldHeight != newValue {
                bind(self.oldHeight, newValue)
                self.oldHeight = newValue
            }
        }
        .onHover {
            self.hovering = $0
        }
        .background(!self.selected && self.hovering ? self.hoverColor : .clear)
        .onTapGesture {
            if self.canAction {
                if let action = action {
                    action()
                }
            }
        }
    }

    func disableHover(canAction: Bool, b: @escaping (CGFloat, CGFloat) -> Void) -> AKSUDropdownItem<K> {
        var new = self
        new.selected = true
        new.bind = b
        new.canAction = canAction
        return new
    }

    func binding(canAction: Bool, b: @escaping (CGFloat, CGFloat) -> Void) -> AKSUDropdownItem<K> {
        var new = self
        new.selected = false
        new.bind = b
        new.canAction = canAction
        return new
    }
}

// AKSUDropdown Content Item 修饰函数定义
extension View {
    func AKSUDropdownTag<K: Hashable>(index: K, action: (() -> Void)? = nil) -> AKSUDropdownItem<K> {
        AKSUDropdownItem(index: index, content: { self }, action: action)
    }
}

// AKSUDropdownItem 的 AKSUDropdownBuilder 定义
@resultBuilder public enum AKSUDropdownBuilder<K: Hashable> {
    static func buildBlock() -> [AKSUDropdownItem<K>] {
        []
    }

    public static func buildBlock(_ components: AKSUDropdownItem<K>...) -> [AKSUDropdownItem<K>] {
        components
    }

    public static func buildBlock(_ components: [AKSUDropdownItem<K>]...) -> [AKSUDropdownItem<K>] {
        components.flatMap {
            $0
        }
    }

    public static func buildExpression(_ expression: AKSUDropdownItem<K>) -> [AKSUDropdownItem<K>] {
        [expression]
    }

    public static func buildExpression(_ expression: ForEach<Range<Int>, Int, AKSUDropdownItem<K>>) -> [AKSUDropdownItem<K>] {
        expression.data.map {
            expression.content($0)
        }
    }

    public static func buildEither(first: [AKSUDropdownItem<K>]) -> [AKSUDropdownItem<K>] {
        return first
    }

    public static func buildEither(second: [AKSUDropdownItem<K>]) -> [AKSUDropdownItem<K>] {
        return second
    }

    public static func buildIf(_ element: [AKSUDropdownItem<K>]?) -> [AKSUDropdownItem<K>] {
        return element ?? []
    }
}

struct AKSUDropdown_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AKSUDropdownPreviewsView()
        }
        .frame(width: 600, height: 600)
    }
}

struct AKSUDropdownPreviewsView: View {
    @State var text: String = "1"
    @State var color: Color = AKSUColor.primary

    var body: some View {
        VStack {
            AKSUDropdown(style: .selectBtn, selected: .constant("primary")) {
                Text("primary")
                    .AKSUDropdownTag(index: "primary") {
                        print("primary")
                    }

                Text("success")
                    .AKSUDropdownTag(index: "success") {
                        print("success")
                    }

                Text("warning")
                    .AKSUDropdownTag(index: "warning") {
                        print("warning")
                    }

                Text("danger")
                    .AKSUDropdownTag(index: "danger") {
                        print("danger")
                    }
            }
            .frame(width: 200)

            AKSUDropdown(selected: self.$color, bgColor: self.color) {
                Text("primary")
                    .AKSUDropdownTag(index: AKSUColor.primary)

                Text("success")
                    .AKSUDropdownTag(index: AKSUColor.success)

                Text("warning")
                    .AKSUDropdownTag(index: AKSUColor.warning)

                Text("danger")
                    .AKSUDropdownTag(index: AKSUColor.danger)
            }
            .frame(width: 200)

            HStack {
                AKSUDropdown(selected: self.$text, plain: true, height: 40, dropHeight: 72) {
                    HStack {
                        Spacer()
                        Text("primary")
                    }
                    .AKSUDropdownTag(index: "primary")
                    HStack {
                        Text("success")
                        Spacer()
                    }
                    .AKSUDropdownTag(index: "success")
                    Text("warning")
                        .AKSUDropdownTag(index: "warning")
                    Text("danger")
                        .AKSUDropdownTag(index: "danger")
                }
                .frame(width: 200)

                VStack {}.frame(width: 100, height: 40)
                    .background(.green)
            }
        }
    }
}
