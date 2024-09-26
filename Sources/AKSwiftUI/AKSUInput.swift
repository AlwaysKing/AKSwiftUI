//
//  AKSUInput.swift
//  AKSwiftUI
//
//  Created by alwaysking on 2024/8/30.
//

import SwiftUI

enum AKSUInputStyle {
    case line
    case box
}

struct AKSUInput: View {
    @Environment(\.isEnabled) private var isEnabled

    // 输入框样式
    var style: AKSUInputStyle = .box
    // 需要显示的 label
    var label: String
    // 禁止 action leable
    var disableActionLabel: Bool = false
    // 主要颜色
    let actionColor: Color = AKSUColor.primary
    // 是否显示清空按钮
    var clearButton: Bool = true
    // 密码模式
    var password: Bool = false
    // 接收输入的内容
    @Binding var text: String
    // 回车事件触发
    var submit: (() -> Void)? = nil
    // 是否获得焦点
    @FocusState private var focused: Bool
    // 是否激活 action label
    @State private var labelActionActivate: Bool = false
    // action label 的宽度
    @State private var actionLabelSize: CGFloat = 0.0
    // clear 按钮 hover 状态
    @State private var clearHovering: Bool = false

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                if !disableActionLabel {
                    Text(label)
                        .foregroundStyle(focused ? actionColor : AKSUColor.gray.opacity(0.6))
                        .background(
                            GeometryReader { geometry in
                                Color.clear
                                    .onAppear {
                                        // 因为有缩放，所以这里要将缩放取消
                                        actionLabelSize = geometry.size.width / 1.2
                                    }
                            }
                        )
                        .font(.title2)
                        .scaleEffect(labelActionActivate ? 0.8 : 1.0, anchor: .leading)
                        .offset(y: labelActionActivate ? 0 : 20)
                        .padding(0)
                        .padding(.leading, style == .line ? 4 : 15)
                        .frame(height: 15)
                        .allowsHitTesting(false)
                } else {
                    VStack {}
                        .frame(height: 15)
                }

                HStack(spacing: 0) {
                    ZStack {
                        if password {
                            SecureField(disableActionLabel ? label : "", text: $text)
                        } else {
                            TextField(disableActionLabel ? label : "", text: $text)
                        }
                    }
                    .textFieldStyle(.plain)
                    .font(.title2)
                    .padding([.top, .bottom], 8)
                    .padding(.leading, style == .line ? 4 : 16)
                    .padding(.trailing, text.isEmpty || !focused || !clearButton ? (style == .line ? 4 : 16) : 0)
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

                    if !text.isEmpty && focused && clearButton {
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
                }
                .background(
                    ZStack {
                        VStack {
                            RoundedRectangle(cornerRadius: 10)
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
                            RoundedRectangle(cornerRadius: 10)
                                .fill(AKSUColor.dyGrayMask)
                        }
                    }
                )
                .padding(.top, -6)
                if style == .line && isEnabled {
                    VStack {}
                        .frame(maxWidth: .infinity)
                        .frame(height: 2)
                        .background(focused ? actionColor : AKSUColor.gray.opacity(0.5))
                        .cornerRadius(2)
                        .padding(0)
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
    var body: some View {
        VStack {
            HStack {
                AKSUInput(style: .box, label: "请输入用户名1", text: $input)
                    .frame(width: 150)
                AKSUInput(style: .box, label: "请输入用户名1", clearButton: false, text: $input)
                    .frame(width: 150)
            }

            HStack {
                AKSUInput(style: .box, label: "请输入用户名2", disableActionLabel: true, text: $input)
                    .frame(width: 150)
                AKSUInput(style: .box, label: "请输入用户名2", disableActionLabel: true, clearButton: false, text: $input)
                    .frame(width: 150)
            }

            HStack {
                AKSUInput(style: .line, label: "密码3", password: true, text: $input)
                    .frame(width: 150)

                AKSUInput(style: .line, label: "密码3", clearButton: false, password: true, text: $input)
                    .frame(width: 150)
            }
        }
    }
}
