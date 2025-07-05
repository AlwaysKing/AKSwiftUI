//
//  AKSUInputGroup.swift
//  AKSwiftUI
//
//  Created by alwaysking on 2024/8/30.
//

import SwiftUI

public struct AKSUInputGroup: View {
    @Environment(\.isEnabled) private var isEnabled

    // 需要显示的 label
    public var label: String
    // 主要颜色
    public let actionColor: Color
    // 接收输入的内容
    @Binding public var text: String
    // 是否显示清空按钮
    var clearButton: AKSUInputButtonShowMode
    // 密码模式
    var password: Bool
    // 是否显示清空按钮
    var passwordButton: AKSUInputButtonShowMode
    // 文本对齐方式
    var alignment: TextAlignment
    // 回车事件触发
    public var submit: (() -> Void)?
    // 是否获得焦点
    @FocusState private var focused: Bool
    // clear 按钮 hover 状态
    @State private var clearHovering: Bool = false
    @State private var realHeight: CGFloat = 2.0
    @State private var leadingWidth: CGFloat = 0.0
    @State private var trailingWidth: CGFloat = 0.0
    @State private var dropHeight: CGFloat = 0.0
    @State private var hovering: Bool = false
    @State var showPassword: Bool = false

    var leadingView: [AnyView] = []
    var trailingView: [AnyView] = []

    public init(label: String, alignment: TextAlignment = .leading, clearButton: AKSUInputButtonShowMode = .auto, password: Bool = false, passwordButton: AKSUInputButtonShowMode = .auto, text: Binding<String>, actionColor: Color = .aksuPrimary, submit: (() -> Void)? = nil) {
        self.label = label
        self._text = text
        self.password = password
        self.actionColor = actionColor
        self.submit = submit
        self.clearButton = clearButton
        self.passwordButton = passwordButton
        self.alignment = alignment
    }

    public var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    if leadingView.count != 0 {
                        HStack(spacing: 0) {
                            ForEach(Array(0 ..< leadingView.count), id: \.self) {
                                index in

                                if index != 0 {
                                    VStack {}
                                        .frame(width: 1, height: realHeight - 6)
                                        .background(.aksuBoard)
                                        .zIndex(2)
                                }

                                leadingView[index]
                                    .frame(minWidth: 40)
                                    .zIndex(2)
                                    .padding(.trailing, -2)
                            }

                            VStack {}
                                .frame(width: 2, height: realHeight)
                                .padding(0)
                                .overlay {
                                    if focused {
                                        actionColor
                                            .frame(width: 2, height: realHeight)
                                    } else {
                                        AKSUColor.board
                                            .frame(width: 1, height: realHeight - 2)
                                    }
                                }
                        }
                        .overlay {
                            GeometryReader { geometry in
                                Color.clear.task {
                                    leadingWidth = geometry.size.width
                                }
                            }
                        }
                        .mask {
                            ZStack {
                                Rectangle().padding(.leading, 8)
                                RoundedRectangle(cornerRadius: AKSUAppearance.cornerRadius)
                            }.overlay {
                                GeometryReader { g in
                                    Rectangle()
                                        .offset(y: g.size.height + 2)
                                        .frame(height: 4096)
                                }
                            }
                        }
                    }

                    // 输入框
                    HStack(spacing: 0) {
                        ZStack {
                            if password {
                                SecureField(label, text: $text)
                            } else {
                                TextField(label, text: $text)
                            }
                        }
                        .multilineTextAlignment(alignment)
                        .textFieldStyle(.plain)
                        .font(.title2)
                        .padding([.top, .bottom], 8)
                        .padding([.leading, .trailing], 16)
                        .focused($focused)
                        .onHover { hovering = $0 }
                        .onSubmit {
                            if let submit = submit {
                                submit()
                            }
                        }

                        if showClearButton() {
                            ZStack {
                                Image(systemName: "x.circle").foregroundColor(.aksuGray)
                            }
                            .frame(width: 20, height: 20)
                            .padding(.trailing, showPasswordButton() ? 0 : 5)
                            .onHover {
                                clearHovering = $0
                                if clearHovering {
                                    NSCursor.pointingHand.push()
                                } else {
                                    NSCursor.pop()
                                }
                            }
                            .onTapGesture {
                                text.removeAll()
                            }
                        }
                    }

                    if showPasswordButton() {
                        ZStack {
                            Image(systemName: showPassword ? "eye" : "eye.slash").foregroundColor(.aksuGray)
                        }
                        .frame(width: 20, height: 20)
                        .padding(.trailing, 5)
                        .onHover {
                            clearHovering = $0
                            if clearHovering {
                                NSCursor.pointingHand.push()
                            } else {
                                NSCursor.pop()
                            }
                        }
                        .onTapGesture {
                            showPassword.toggle()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0001) {
                                focused = true
                            }
                        }
                        .onChange(of: focused) { _ in
                            print(focused)
                        }
                    }

                    if trailingView.count != 0 {
                        HStack(spacing: 0) {
                            VStack {}
                                .frame(width: 2, height: realHeight )
                                .padding(0)
                                .overlay {
                                    if focused {
                                        actionColor
                                            .frame(width: 2, height: realHeight )
                                    } else {
                                        AKSUColor.board
                                            .frame(width: 1, height: realHeight - 2)
                                    }
                                }
                                .padding(.trailing, -2)

                            ForEach(Array(0 ..< trailingView.count), id: \.self) {
                                index in

                                if index != 0 {
                                    VStack {}
                                        .frame(width: 1, height: realHeight - 6)
                                        .background(.aksuBoard)
                                        .zIndex(2)
                                }

                                trailingView[index]
                                    .frame(minWidth: 40)
                                    .padding(.leading, -2)
                            }
                        }
                        .overlay {
                            GeometryReader { geometry in
                                Color.clear.task {
                                    trailingWidth = geometry.size.width
                                }
                            }
                        }
                        .mask {
                            ZStack {
                                Rectangle().padding(.trailing, 8)
                                RoundedRectangle(cornerRadius: AKSUAppearance.cornerRadius)
                            }.overlay {
                                GeometryReader { g in
                                    Rectangle()
                                        .offset(y: g.size.height + 2)
                                        .frame(height: 4096)
                                }
                            }
                        }
                    }
                }
                .background(
                    // 边框
                    ZStack {
                        VStack {
                            RoundedRectangle(cornerRadius: AKSUAppearance.cornerRadius)
                                .stroke(.aksuBoard, lineWidth: 1)
                                .padding(1)
                        }

                        if focused {
                            RoundedRectangle(cornerRadius: AKSUAppearance.cornerRadius)
                                .stroke(actionColor, lineWidth: 2)
                                .padding(1)
                                .mask {
                                    Color.black
                                        .padding(.trailing, trailingWidth)
                                        .padding(.leading, leadingWidth)
                                }
                        }

                        // 禁用时候的背景色
                        if !isEnabled {
                            RoundedRectangle(cornerRadius: AKSUAppearance.cornerRadius)
                                .fill(.aksuGrayMask)
                        }
                    }
                )
                .onTapGesture {
                    focused = true
                }
            }
            .overlay {
                GeometryReader { geometry in
                    Color.clear.task {
                        realHeight = max(2, geometry.size.height)
                    }
                }
            }
        }
    }

    public func addLeading<V: View>(@ViewBuilder builder: () -> V) -> Self {
        var tmp = self
        tmp.leadingView.append(AnyView(builder()))
        return tmp
    }

    public func addTrailling<V: View>(@ViewBuilder builder: () -> V) -> Self {
        var tmp = self
        tmp.trailingView.append(AnyView(builder()))
        return tmp
    }

    func showPasswordButton() -> Bool {
        if !password {
            return false
        }
        if passwordButton == .none {
            return false
        } else if passwordButton == .show {
            return true
        } else if focused || hovering {
            return true
        }
        return false
    }

    func showClearButton() -> Bool {
        if clearButton == .none {
            return false
        } else if clearButton == .show {
            return true
        } else if text.isEmpty == false && (focused || hovering) {
            return true
        }
        return false
    }
}

struct AKSUInputGroup_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AKSUInputGroupPreviewsView()
        }
        .frame(width: 1000, height: 600)
    }
}

struct AKSUInputGroupPreviewsView: View {
    @State var input: String = "asdasdadasdasdasdasdasdasdasdasd"
    let height: CGFloat = 40
    @State var password: Bool = false
    @State var clearButton: AKSUInputButtonShowMode = .none
    @State var passwordButton: AKSUInputButtonShowMode = .none
    @State var alignment: TextAlignment = .leading

    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                HStack {
                    Text("对齐方式:")
                    AKSUSegment(selected: $alignment) {
                        Text("左").AKSUSegmentTag(index: .leading)
                        Text("中").AKSUSegmentTag(index: .center)
                        Text("右").AKSUSegmentTag(index: .trailing)
                    }.frame(width: 200)
                }

                HStack {
                    Text("清除按钮:")
                    AKSUSegment(selected: $clearButton) {
                        Text("禁用").AKSUSegmentTag(index: .none)
                        Text("自动").AKSUSegmentTag(index: .auto)
                        Text("显示").AKSUSegmentTag(index: .show)
                    }.frame(width: 200)
                }

                HStack {
                    Text("文本类型:")
                    AKSUSegment(selected: $password) {
                        Text("明文").AKSUSegmentTag(index: false)
                        Text("密码").AKSUSegmentTag(index: true)
                    }.frame(width: 200)
                }

                HStack {
                    Text("密码按钮:")
                    AKSUSegment(selected: $passwordButton) {
                        Text("禁用").AKSUSegmentTag(index: .none)
                        Text("自动").AKSUSegmentTag(index: .auto)
                        Text("显示").AKSUSegmentTag(index: .show)
                    }.frame(width: 200)
                        .disabled(!password)
                }
            }.padding()

            Text("text")
            HStack {
                VStack {
                    AKSUInputGroup(label: "用户名", alignment: alignment, clearButton: clearButton, password: password, passwordButton: passwordButton, text: $input)
                        .frame(width: 150)
                }

                VStack {
                    AKSUInputGroup(label: "用户名", alignment: alignment, clearButton: clearButton, password: password, passwordButton: passwordButton, text: $input)
                        .addLeading {
                            Text("1")
                        }
                        .frame(width: 150)
                }

                VStack {
                    AKSUInputGroup(label: "用户名", alignment: alignment, clearButton: clearButton, password: password, passwordButton: passwordButton, text: $input)
                        .addLeading {
                            Text("1")
                        }
                        .addTrailling {
                            Text("1")
                        }
                        .frame(width: 150)
                }

                VStack {
                    AKSUInputGroup(label: "用户名", alignment: alignment, clearButton: clearButton, password: password, passwordButton: passwordButton, text: $input)
                        .addTrailling {
                            Text("1")
                        }
                        .frame(width: 150)
                }
            }
            Text("button")
            HStack(alignment: .top) {
                VStack {
                    AKSUInputGroup(label: "用户名", alignment: alignment, clearButton: clearButton, password: password, passwordButton: passwordButton, text: $input)
                        .addTrailling {
                            AKSUButton(style: .plain, height: height) {
                                Text("确定")
                                    .foregroundColor(.white)
                                    .font(.title)
                                    .frame(maxWidth: .infinity)
                            }
                            action: {
                            }
                            .frame(width: 100)
                        }
                        .frame(width: 400)

                    AKSUInputGroup(label: "用户名", alignment: alignment, clearButton: clearButton, password: password, passwordButton: passwordButton, text: $input)
                        .addLeading {
                            AKSUButton(style: .plain, height: height) {
                                Text("确定")
                                    .foregroundColor(.white)
                                    .font(.title)
                                    .frame(maxWidth: .infinity)
                            }
                            action: {
                            }
                            .frame(width: 100)
                        }
                        .frame(width: 400)

                    AKSUInputGroup(label: "用户名", alignment: alignment, clearButton: clearButton, password: password, passwordButton: passwordButton, text: $input)
                        .addLeading {
                            AKSUButton(style: .plain, height: height) {
                                Text("确定")
                                    .foregroundColor(.white)
                                    .font(.title)
                                    .frame(maxWidth: .infinity)
                            }
                            action: {
                            }

                            .frame(width: 100)
                        }
                        .addTrailling {
                            AKSUButton(style: .plain, height: height) {
                                Text("确定")
                                    .foregroundColor(.white)
                                    .font(.title)
                                    .frame(maxWidth: .infinity)
                            }
                            action: {
                            }
                            .frame(width: 100)
                        }
                        .frame(width: 400)
                }

                VStack {
                    AKSUInputGroup(label: "用户名", alignment: alignment, clearButton: clearButton, password: password, passwordButton: passwordButton, text: $input)
                        .addTrailling {
                            AKSUDropdown(selected: $input, plain: true, height: height) {
                                Text("primary")
                                    .AKSUDropdownTag(index: "primary")
                                Text("success")
                                    .AKSUDropdownTag(index: "success")
                                Text("warning")
                                    .AKSUDropdownTag(index: "warning")
                                Text("danger")
                                    .AKSUDropdownTag(index: "danger")
                            }
                            .frame(width: 100)
                        }
                        .frame(width: 400)
                        .zIndex(4)

                    AKSUInputGroup(label: "用户名", alignment: alignment, clearButton: clearButton, password: password, passwordButton: passwordButton, text: $input)
                        .addLeading {
                            AKSUDropdown(selected: $input, plain: true, height: height) {
                                Text("primary")
                                    .AKSUDropdownTag(index: "primary")
                                Text("success")
                                    .AKSUDropdownTag(index: "success")
                                Text("warning")
                                    .AKSUDropdownTag(index: "warning")
                                Text("danger")
                                    .AKSUDropdownTag(index: "danger")
                            }
                            .frame(width: 100)
                        }
                        .frame(width: 400)
                        .zIndex(3)

                    AKSUInputGroup(label: "用户名", alignment: alignment, clearButton: clearButton, password: password, passwordButton: passwordButton, text: $input)
                        .addLeading {
                            AKSUDropdown(selected: $input, plain: true, height: height) {
                                Text("primary")
                                    .AKSUDropdownTag(index: "primary")
                                Text("success")
                                    .AKSUDropdownTag(index: "success")
                                Text("warning")
                                    .AKSUDropdownTag(index: "warning")
                                Text("danger")
                                    .AKSUDropdownTag(index: "danger")
                            }
                            .frame(width: 100)
                        }
                        .addTrailling {
                            AKSUDropdown(selected: $input, plain: true, height: height) {
                                Text("primary")
                                    .AKSUDropdownTag(index: "primary")
                                Text("success")
                                    .AKSUDropdownTag(index: "success")
                                Text("warning")
                                    .AKSUDropdownTag(index: "warning")
                                Text("danger")
                                    .AKSUDropdownTag(index: "danger")
                            }
                            .frame(width: 100)
                        }
                        .frame(width: 400)
                        .zIndex(2)
                }
            }.zIndex(2)

            Text("多个")
            HStack {
                AKSUInputGroup(label: "用户名", alignment: alignment, clearButton: clearButton, password: password, passwordButton: passwordButton, text: $input)
                    .addLeading {
                        AKSUButton(style: .plain, height: height) {
                            Text("确定")
                                .foregroundColor(.white)
                                .font(.title)
                                .frame(maxWidth: .infinity)
                        }
                        action: {
                        }

                        .frame(width: 100)
                    }
                    .addLeading {
                        AKSUButton(style: .plain, height: height) {
                            Text("取消")
                                .foregroundColor(.white)
                                .font(.title)
                                .frame(maxWidth: .infinity)
                        }
                        action: {
                        }
                        .frame(width: 100)
                    }
                    .addTrailling {
                        AKSUButton(style: .plain, height: height) {
                            Text("确定")
                                .foregroundColor(.white)
                                .font(.title)
                                .frame(maxWidth: .infinity)
                        }
                        action: {
                        }

                        .frame(width: 100)
                    }
                    .addTrailling {
                        AKSUButton(style: .plain, height: height) {
                            Text("取消")
                                .foregroundColor(.white)
                                .font(.title)
                                .frame(maxWidth: .infinity)
                        }
                        action: {
                        }
                        .frame(width: 100)
                    }
                    .frame(width: 600)
            }
        }
    }
}
