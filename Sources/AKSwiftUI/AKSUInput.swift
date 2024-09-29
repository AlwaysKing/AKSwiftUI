//
//  AKSUInput.swift
//  AKSwiftUI
//
//  Created by alwaysking on 2024/8/30.
//

import SwiftUI

public enum AKSUInputStyle {
    case line
    case box
    case plain
}

public enum AKSUInputButtonShowMode {
    case none
    case auto
    case show
}

public struct AKSUInput: View {
    @Environment(\.isEnabled) private var isEnabled

    // 输入框样式
    var style: AKSUInputStyle
    // 需要显示的 label
    var label: String
    // 禁止 action leable
    var disableActionLabel: Bool
    // 主要颜色
    let actionColor: Color = AKSUColor.primary
    // 是否显示清空按钮
    var clearButton: AKSUInputButtonShowMode
    // 密码模式
    var password: Bool
    // 是否显示清空按钮
    var passwordButton: AKSUInputButtonShowMode
    // 文本对齐方式
    var textAlignment: TextAlignment
    // 接收输入的内容
    @Binding public var text: String
    // 回车事件触发
    var submit: (() -> Void)? = nil
    // 是否获得焦点
    @FocusState private var focused: Bool
    // 显示秘密啊
    @State var showPassword: Bool = false
    // 是否激活 action label
    @State private var labelActionActivate: Bool = false
    // action label 的宽度
    @State private var actionLabelSize: CGFloat = 0.0
    @State private var actionOriginalLabelSize: CGFloat = 0.0
    // clear 按钮 hover 状态
    @State private var clearHovering: Bool = false
    // 鼠标
    @State private var hovering: Bool = false
    // 大小
    @State private var size: CGSize = CGSize.zero

    public init(style: AKSUInputStyle = .box, label: String, alignment: TextAlignment = .leading, disableActionLabel: Bool = false, clearButton: AKSUInputButtonShowMode = .auto, password: Bool = false, passwordButton: AKSUInputButtonShowMode = .auto, text: Binding<String>, submit: (() -> Void)? = nil) {
        self.style = style
        self.label = label
        self.disableActionLabel = disableActionLabel
        self.clearButton = clearButton
        self.password = password
        self.passwordButton = passwordButton
        self._text = text
        self.submit = submit
        self.textAlignment = alignment
        self.focused = focused
        self.labelActionActivate = labelActionActivate
        self.clearHovering = clearHovering
    }

    public var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                if !disableActionLabel && style != .plain {
                    Text(label)
                        .foregroundStyle(focused ? actionColor : AKSUColor.gray.opacity(0.6))
                        .background(
                            GeometryReader { geometry in
                                Color.clear
                                    .onAppear {
                                        // 因为有缩放，所以这里要将缩放取消
                                        actionLabelSize = geometry.size.width / 1.2
                                        actionOriginalLabelSize = geometry.size.width
                                    }
                            }
                        )
                        .font(.title2)
                        .scaleEffect(labelActionActivate ? 0.8 : 1.0, anchor: .leading)
                        .offset(y: labelActionActivate ? 0 : 20)
                        .offset(x: labelActionActivate ? 0 : actionLabelXOffset())
                        .padding(0)
                        .padding(.leading, style != .box ? 4 : 15)
                        .frame(height: 15)
                        .allowsHitTesting(false)

                } else {
                    if style != .plain && disableActionLabel == false {
                        VStack {}
                            .frame(height: 15)
                    }
                }

                ZStack {
                    ZStack {
                        if password && !showPassword {
                            SecureField((disableActionLabel || style == .plain) ? label : "", text: $text)
                                .padding(.top, 0.3)
                                .padding(.bottom, 1.2)
                                .offset(y: focused ? 1.5 : 0) // .plain 模式下会有偏移
                        } else {
                            TextField((disableActionLabel || style == .plain) ? label : "", text: $text)
                        }
                    }
                    .multilineTextAlignment(textAlignment)
                    .textFieldStyle(.plain)
                    .font(.title2)
                    .padding([.top, .bottom], 8)
                    .padding(.leading, (style == .line || style == .plain) ? 4 : 16)
                    .padding(.trailing, inputTraillingPadding())
                    .focused($focused)
                    .onChange(of: focused) { _ in
                        withAnimation {
                            labelActionActivate = !text.isEmpty || focused
                        }
                    }
                    .onChange(of: text) { _ in
                        withAnimation {
                            labelActionActivate = !text.isEmpty || focused
                        }
                    }
                    .onSubmit {
                        if let submit = submit {
                            submit()
                        }
                    }

                    HStack {
                        Spacer()
                        if showClearButton() {
                            ZStack {
                                Image(systemName: "x.circle").foregroundColor(AKSUColor.gray)
                            }
                            .frame(width: 20, height: 20)
                            .padding(.leading, 5)
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

                        if showPasswordButton() {
                            ZStack {
                                Image(systemName: showPassword ? "eye" : "eye.slash").foregroundColor(AKSUColor.gray)
                            }
                            .frame(width: 20, height: 20)
                            .padding(.trailing, 5)
                            .padding(.leading, showClearButton() ? 0 : 5)
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
                    }
                }
                .background(
                    ZStack {
                        VStack {
                            RoundedRectangle(cornerRadius: AKSUAppearance.cornerRadius)
                                .stroke(style == .box ? (focused ? actionColor : AKSUColor.gray) : .clear, lineWidth: focused ? 2 : 1)
                                .padding(1)
                        }
                        .mask {
                            GeometryReader { geometry in
                                HStack(alignment: .bottom, spacing: 0) {
                                    Color.black.frame(width: 10)
                                    Color.black.frame(width: actionLabelSize + 6, height: (focused || labelActionActivate) && !disableActionLabel ? 20 : nil)
                                    Color.black.frame(width: geometry.size.width - 6 - actionLabelSize)
                                }
                            }
                        }

                        if !isEnabled {
                            RoundedRectangle(cornerRadius: AKSUAppearance.cornerRadius)
                                .fill(AKSUColor.dyGrayMask)
                        }
                    }
                )
                .padding(.top, style == .plain || disableActionLabel == true ? 0 : -6)

                if style == .line && isEnabled {
                    VStack {}
                        .frame(maxWidth: .infinity)
                        .frame(height: 2)
                        .background(focused ? actionColor : AKSUColor.gray.opacity(0.5))
                        .cornerRadius(4)
                        .padding(0)
                }
            }
        }
        .onHover { hovering = $0 }
        .background {
            GeometryReader {
                g in
                Color.clear
                    .onAppear {
                        size = g.size
                    }
                    .onChange(of: g.size) { _ in
                        size = g.size
                    }
            }
        }
        .onOutsideClick { inside in
            DispatchQueue.main.async {
                if inside == false {
                    focused = false
                }
            }
        }
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

    func inputTraillingPadding() -> CGFloat {
        if textAlignment == .center {
            return style == .box ? 16 : 4
        }

        var padding = 0.0
        if showClearButton() && showPasswordButton() {
            padding = 57
        } else if showClearButton() || showPasswordButton() {
            padding = 32
        }

        if padding == 0 {
            padding = style == .box ? 16 : 4
        }

        return padding
    }

    func actionLabelXOffset() -> CGFloat {
        if textAlignment == .leading {
            return 0
        } else if textAlignment == .center {
            return (size.width - actionOriginalLabelSize) / 2 - (style != .box ? 4 : 15)
        } else {
            return (size.width - actionOriginalLabelSize)  - (style != .box ? 4 : 15) * 2
        }
    }
}

struct AKSUInput_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AKSUInputPreviewsView()
        }
        .frame(width: 600, height: 600)
    }
}

struct AKSUInputPreviewsView: View {
    @State var input: String = ""
    @State var style: AKSUInputStyle = .box
    @State var disableActionLabel: Bool = false
    @State var password: Bool = false
    @State var clearButton: AKSUInputButtonShowMode = .none
    @State var passwordButton: AKSUInputButtonShowMode = .none

    @State var alignment: TextAlignment = .leading

    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                HStack {
                    Text("显示样式:")
                    AKSUSegment(selected: $style) {
                        Text("box").AKSUSegmentTag(index: .box)
                        Text("line").AKSUSegmentTag(index: .line)
                        Text("plain").AKSUSegmentTag(index: .plain)
                    }.frame(width: 200)
                }

                HStack {
                    Text("对齐方式:")
                    AKSUSegment(selected: $alignment) {
                        Text("左").AKSUSegmentTag(index: .leading)
                        Text("中").AKSUSegmentTag(index: .center)
                        Text("右").AKSUSegmentTag(index: .trailing)
                    }.frame(width: 200)
                }

                HStack {
                    Text("动态标签:")
                    AKSUSegment(selected: $disableActionLabel) {
                        Text("禁用").AKSUSegmentTag(index: true)
                        Text("启用").AKSUSegmentTag(index: false)
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

            HStack {
                AKSUInput(style: style, label: "请 输 入 用 户 名", alignment: alignment, disableActionLabel: disableActionLabel, clearButton: clearButton, password: password, passwordButton: passwordButton, text: $input)
                    .frame(width: 250)
            }
        }
    }
}
