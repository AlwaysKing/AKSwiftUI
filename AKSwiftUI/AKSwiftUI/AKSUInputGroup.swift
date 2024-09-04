//
//  AKSUInputGroup.swift
//  AKSwiftUI
//
//  Created by alwaysking on 2024/8/30.
//

import SwiftUI

// enum AKSUInputGroupStyle {
//    case line
//    case box
// }

struct AKSUInputGroup: View {
    @Environment(\.isEnabled) private var isEnabled

    // 需要显示的 label
    var label: String
    // 主要颜色
    let actionColor: Color = AKSUColor.primary
    // 接收输入的内容
    @Binding var text: String
    // 密码模式
    var password: Bool = false
    // 回车事件触发
    var submit: (() -> Void)? = nil
    // 是否获得焦点
    @FocusState private var focused: Bool
    // clear 按钮 hover 状态
    @State private var clearHovering: Bool = false
    @State private var realHeight: CGFloat = 2.0
    @State private var leadingWidth: CGFloat = 0.0
    @State private var trailingWidth: CGFloat = 0.0
    @State private var dropHeight: CGFloat = 0.0

    var leadingView: [AnyView] = []
    var trailingView: [AnyView] = []

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    if leadingView.count != 0 {
                        HStack(spacing: 0) {
                            ForEach(Array(0 ..< leadingView.count), id: \.self) {
                                index in

                                if index != 0 {
                                    VStack {}
                                        .frame(width: 1, height: realHeight - 2)
                                        .background(.black.opacity(0.6))
                                        .padding([.leading, .trailing], 2)
                                        .zIndex(2)
                                }

                                leadingView[index]
                                    .frame(minWidth: 40)
                                    .zIndex(2)
                                    .padding(.trailing, -2)
                            }

                            VStack {}
                                .frame(width: 2, height: realHeight - 2)
                                .padding(0)
                                .overlay {
                                    if focused {
                                        actionColor
                                            .frame(width: 2, height: realHeight - 2)
                                    } else {
                                        AKSUColor.gray
                                            .frame(width: 1, height: realHeight - 2)
                                    }
                                }
                        }
                        .overlay {
                            GeometryReader { geometry in
                                Color.clear.onAppear {
                                    leadingWidth = geometry.size.width
                                }
                            }
                        }
                        .mask {
                            ZStack {
                                Rectangle().padding(.leading, 8)
                                RoundedRectangle(cornerRadius: 4)
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
                    ZStack {
                        if password {
                            SecureField(label, text: $text)
                        } else {
                            TextField(label, text: $text)
                        }
                    }
                    .textFieldStyle(.plain)
                    .font(.title2)
                    .padding([.top, .bottom], 8)
                    .padding([.leading, .trailing], 16)
                    .focused($focused)
                    .onSubmit {
                        if let submit = submit {
                            submit()
                        }
                    }

                    // 删除按钮
                    if !text.isEmpty && focused {
                        ZStack {
                            Image(systemName: "x.circle").foregroundColor(AKSUColor.gray)
                        }
                        .frame(width: 30, height: 30)
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

                    if trailingView.count != 0 {
                        HStack(spacing: 0) {
                            VStack {}
                                .frame(width: 2, height: realHeight - 2)
                                .padding(0)
                                .overlay {
                                    if focused {
                                        actionColor
                                            .frame(width: 2, height: realHeight - 2)
                                    } else {
                                        AKSUColor.gray
                                            .frame(width: 1, height: realHeight - 2)
                                    }
                                }
                                .padding(.trailing, -2)

                            ForEach(Array(0 ..< trailingView.count), id: \.self) {
                                index in

                                if index != 0 {
                                    VStack {}
                                        .frame(width: 1, height: realHeight - 2)
                                        .background(.black.opacity(0.3))
                                        .padding([.leading, .trailing], 2)
                                        .zIndex(2)
                                }

                                trailingView[index]
                                    .frame(minWidth: 40)
                            }
                        }
                        .overlay {
                            GeometryReader { geometry in
                                Color.clear.onAppear {
                                    trailingWidth = geometry.size.width
                                }
                            }
                        }
                        .mask {
                            ZStack {
                                Rectangle().padding(.trailing, 8)
                                RoundedRectangle(cornerRadius: 4)
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
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(AKSUColor.gray, lineWidth: 1)
                                .padding(1)
                        }

                        if focused {
                            RoundedRectangle(cornerRadius: 4)
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
                            RoundedRectangle(cornerRadius: 4)
                                .fill(AKSUColor.dyGrayMask)
                        }
                    }
                )
                .onTapGesture {
                    focused = true
                }
            }
            .overlay {
                GeometryReader { geometry in
                    Color.clear.onAppear {
                        realHeight = max(2, geometry.size.height)
                    }
                }
            }
        }
    }

    func addLeading<V: View>(@ViewBuilder builder: () -> V) -> Self {
        var tmp = self
        tmp.leadingView.append(AnyView(builder()))
        return tmp
    }

    func addTrailling<V: View>(@ViewBuilder builder: () -> V) -> Self {
        var tmp = self
        tmp.trailingView.append(AnyView(builder()))
        return tmp
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
    @State var input: String = ""
    let height: CGFloat = 40

    var body: some View {
        VStack {
            Text("text")
            HStack {
                VStack {
                    AKSUInputGroup(label: "用户名", text: $input)
                        .frame(width: 150)
                }

                VStack {
                    AKSUInputGroup(label: "用户名", text: $input)
                        .addLeading {
                            Text("1")
                        }
                        .frame(width: 150)
                }

                VStack {
                    AKSUInputGroup(label: "用户名", text: $input)
                        .addLeading {
                            Text("1")
                        }
                        .addTrailling {
                            Text("1")
                        }
                        .frame(width: 150)
                }

                VStack {
                    AKSUInputGroup(label: "用户名", text: $input)
                        .addTrailling {
                            Text("1")
                        }
                        .frame(width: 150)
                }
            }
            Text("button")
            HStack(alignment: .top) {
                VStack {
                    AKSUInputGroup(label: "用户名", text: $input)
                        .addTrailling {
                            AKSUButton(plain: true, height: height) {
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

                    AKSUInputGroup(label: "用户名", text: $input)
                        .addLeading {
                            AKSUButton(plain: true, height: height) {
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

                    AKSUInputGroup(label: "用户名", text: $input)
                        .addLeading {
                            AKSUButton(plain: true, height: height) {
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
                            AKSUButton(plain: true, height: height) {
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
                    AKSUInputGroup(label: "用户名", text: $input)
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

                    AKSUInputGroup(label: "用户名", text: $input)
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

                    AKSUInputGroup(label: "用户名", text: $input)
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
                AKSUInputGroup(label: "用户名", text: $input)
                    .addLeading {
                        AKSUButton(plain: true, height: height) {
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
                        AKSUButton(plain: true, height: height) {
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
                        AKSUButton(plain: true, height: height) {
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
                        AKSUButton(plain: true, height: height) {
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
