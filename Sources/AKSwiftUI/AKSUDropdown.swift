//
//  AKSUDropdown.swift
//  AKSwiftUI
//
//  Created by alwaysking on 2024/8/30.
//

import SwiftUI

public enum AKSUDropdownStyle {
    case select
    case selectBtn
}

// AKSUDropdown 本体定义
public struct AKSUDropdown<K: Hashable>: View {
    @Environment(\.isEnabled) private var isEnabled

    var style: AKSUDropdownStyle
    var plain: Bool
    @Binding var selected: K
    var color: Color
    var bgColor: Color
    var dropBgColor: Color
    var height: CGFloat?
    var dropMaxHeight: CGFloat?
    var hiddenTriangle: Bool
    var content: [K: AKSUDropdownItem<K>] = [:]
    var sort: [K] = []
    let menu = AKSUPopWnd()

    @State var noPadding: Bool = false

    @State var dropHeight: CGFloat = 0.0
    @State var selectedRealHeight: CGFloat = 0.0
    // 显示内容
    @State var showDrop: Bool = false
    // hover
    @State var hoveringAll: Bool = false
    @State var hoveringContent: Bool = false
    @State var hoveringToggle: Bool = false

    @State var location: CGRect = CGRect.zero
    @State var dropBtnSize: CGSize = CGSize.zero
    @State var mouseEvent: NSEvent? = nil

    public init(style: AKSUDropdownStyle = .select, selected: Binding<K>, plain: Bool = false, color: Color = .aksuWhite, bgColor: Color = .aksuPrimary, dropTextColor: Color = .aksuText, dropTextHoverColor: Color = .aksuWhite, dropBgColor:Color = .aksuTextBackground, height: CGFloat? = nil, dropHeight: CGFloat? = nil, noPadding: Bool = false, hiddenTriangle: Bool = false, @AKSUDropdownBuilder<K> content: () -> [AKSUDropdownItem<K>]) {
        self._selected = selected
        for item in content() {
            self.content[item.index] = AKSUDropdownItem(index: item.index, height: item.height, noPadding: item.noPadding ?? noPadding, textColor: dropTextColor, hoverTextColor: dropTextHoverColor, hoverBgColor: bgColor, content: item.content, action: item.action)
            self.sort.append(item.index)
        }
        self.plain = plain
        self.color = color
        self.bgColor = bgColor
        self.height = height
        self.dropMaxHeight = dropHeight
        self.style = style
        self.noPadding = noPadding
        self.hiddenTriangle = hiddenTriangle
        self.dropBgColor = dropBgColor
    }

    public var body: some View {
        HStack(spacing: 0) {
            // 文本
            ZStack {
                if let show = content[selected] {
                    show.disableHover(canAction: self.style == .selectBtn).onAppear {
                        selectedRealHeight = show.height
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 18)
            .padding([.top, .bottom], noPadding ? 0 : 10)
            .frame(height: self.height)
            .background(self.hoveringContent && self.style == .selectBtn ? .black.opacity(0.1) : .clear)
            .onHover {
                self.hoveringContent = $0
            }
            .simultaneousGesture(
                TapGesture()
                    .onEnded {
                        if style != .selectBtn {
                            ToggleDropMenu()
                        }
                    }
            )

            // 分隔符
            if self.style == .selectBtn {
                VStack {}
                    .frame(width: 1, height: self.height ?? self.selectedRealHeight)
                    .padding([.top, .bottom], 10)
                    .padding([.leading, .trailing], 0)
                    .background(.aksuGrayMask)
            }

            // 下拉按钮
            if !hiddenTriangle {
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
                .background {
                    GeometryReader { g in
                        Color.clear
                            .onAppear {
                                dropBtnSize = g.size
                            }
                            .onChange(of: g.size) { _ in
                                dropBtnSize = g.size
                            }
                    }
                }
                .onHover {
                    self.hoveringToggle = $0
                }
                .onTapGesture {
                    ToggleDropMenu()
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(!self.isEnabled ? .aksuGrayMask : .clear)
        .background(self.hoveringAll && self.style != .selectBtn ? .black.opacity(0.1) : .clear)
        .background(self.bgColor)
        .cornerRadius(self.plain ? 0 : AKSUAppearance.cornerRadius)
        .onHover {
            self.hoveringAll = $0
        }
        .shadow(color: self.bgColor != .white && self.bgColor != .aksuWhite ? self.bgColor : .black, radius: self.plain ? 0 : 2)
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
        .onMouseEvent(event: [.leftMouseDown, .rightMouseDown]) { point, event in
            mouseEvent = event
            return false
        }
    }

    func ToggleDropMenu() {
        guard let mouseEvent = mouseEvent else { return }
        if !showDrop {
            var dropHeight = 0.0
            for item in content {
                if style == .selectBtn && selected == item.key {
                    continue
                }

                dropHeight += (item.value.height + (item.value.noPadding == true ? 0 : 20))
            }
            if let dropMaxHeight = dropMaxHeight {
                dropHeight = min(dropMaxHeight, dropHeight)
            }
            self.dropHeight = dropHeight

            var pointRect = location
            if style == .selectBtn {
                // 就是一小部分
                pointRect = CGRect(x: location.maxX - dropBtnSize.width, y: location.origin.y, width: dropBtnSize.width, height: location.size.height)
            }

            menu.menuContent = AnyView(menuContent())
            menu.hiddenEvent = {
                withAnimation {
                    showDrop = false
                }
            }

            menu.show(point: CGPoint(x: location.minX, y: location.maxY + 4), pointRect: pointRect, width: location.width, height: dropHeight, parent: mouseEvent.window!)
        } else {
            menu.close()
        }

        self.mouseEvent = nil
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
                                .binding(canAction: self.style == .selectBtn)
                                .simultaneousGesture(
                                    TapGesture()
                                        .onEnded {
                                            if self.style == .select {
                                                self.selected = index
                                            }
                                            self.showDrop = false
                                            menu.close()
                                        }
                                )
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(width: location.width, height: dropHeight, alignment: .top)
        .background(dropBgColor)
    }
}

// AKSUDropdown Content Item 定义
public struct AKSUDropdownItem<K: Hashable>: View {
//    @EnvironmentObject var env: AKSUDropdownEnvironment
    var index: K
    var height: CGFloat
    var noPadding: Bool?
    var color: Color?
    var content: [AnyView]
    var action: (() -> Void)?

    private var canAction: Bool = false
    private var textColor: Color = .aksuText
    private var hoverTextColor: Color = .aksuWhite
    private var hoverBgColor: Color = .aksuPrimary
    @State private var hovering: Bool = false
    private var selected: Bool = false

    public init(index: K, height: CGFloat = 20, noPadding: Bool? = nil, @AKSUAnyViewArrayBuilder content: () -> [AnyView], action: (() -> Void)? = nil) {
        self.index = index
        self.content = content()
        self.action = action
        self.height = height
        self.noPadding = noPadding
    }

    public init(index: K, height: CGFloat = 20, noPadding: Bool? = nil, textColor: Color, hoverTextColor: Color, hoverBgColor: Color, content: [AnyView], action: (() -> Void)?) {
        self.index = index
        self.hoverBgColor = hoverBgColor
        self.hoverTextColor = hoverTextColor
        self.textColor = textColor
        self.content = content
        self.action = action
        self.height = height
        self.noPadding = noPadding
    }

    public var body: some View {
        HStack {
            ForEach(Array(0 ..< self.content.count), id: \.self) { i in
                self.content[i]
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .padding([.top, .bottom], self.selected || noPadding == true ? 0 : 10)
        .foregroundColor(self.selected || self.hovering ? self.hoverTextColor : self.textColor)
        .onHover {
            self.hovering = $0
        }
        .background(!self.selected && self.hovering ? self.hoverBgColor : .clear)
        .onTapGesture {
            if self.canAction {
                if let action = action {
                    action()
                }
            }
        }
    }

    func disableHover(canAction: Bool) -> AKSUDropdownItem<K> {
        var new = self
        new.selected = true
        new.canAction = canAction
        return new
    }

    func binding(canAction: Bool) -> AKSUDropdownItem<K> {
        var new = self
        new.selected = false
        new.canAction = canAction
        return new
    }
}

// AKSUDropdown Content Item 修饰函数定义
public extension View {
    func AKSUDropdownTag<K: Hashable>(index: K, height: CGFloat = 20, noPadding: Bool? = nil, action: (() -> Void)? = nil) -> AKSUDropdownItem<K> {
        AKSUDropdownItem(index: index, height: height, noPadding: noPadding, content: { self }, action: action)
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
    @State var color: Color = .aksuPrimary

    var body: some View {
        VStack {
            Text("asdasdasdasd").foregroundStyle(.aksuText)

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
                    .AKSUDropdownTag(index: .aksuPrimary)

                Text("success")
                    .AKSUDropdownTag(index: .aksuSuccess)

                Text("warning")
                    .AKSUDropdownTag(index: .aksuWarning)

                Text("danger")
                    .AKSUDropdownTag(index: .aksuDanger)
            }
            .frame(width: 200)

            AKSUDropdown(selected: self.$color, bgColor: self.color, hiddenTriangle: true) {
                Text("primary")
                    .AKSUDropdownTag(index: .aksuPrimary)

                Text("success")
                    .AKSUDropdownTag(index: .aksuSuccess)

                Text("warning")
                    .AKSUDropdownTag(index: .aksuWarning)

                Text("danger")
                    .AKSUDropdownTag(index: .aksuDanger)
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
            }
            
            Divider()
            HStack {
                AKSUDropdown(selected: self.$color, bgColor: self.color, dropTextColor: .green, dropTextHoverColor: .white, dropBgColor: .yellow) {
                    Text("primary")
                        .AKSUDropdownTag(index: .aksuPrimary)

                    Text("success")
                        .AKSUDropdownTag(index: .aksuSuccess)

                    Text("warning")
                        .AKSUDropdownTag(index: .aksuWarning)

                    Text("danger")
                        .AKSUDropdownTag(index: .aksuDanger)
                }
                .frame(width: 200)
            }
        }
    }
}
