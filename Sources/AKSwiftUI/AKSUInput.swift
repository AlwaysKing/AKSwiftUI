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
    let actionColor: Color
    // 是否显示清空按钮
    var clearButton: AKSUInputButtonShowMode
    // 密码模式
    var password: Bool
    // 数字模式
    var onlyNumber: Bool
    // 小数点位数
    var decimalCount: Int?
    // 数字模式是否显示步长
    var numberStep: Float?
    // 数字模式的最大值
    var numberMax: Float?
    // 数字模式的最小值
    var numberMin: Float?
    // 后缀单位
    var unit: String?
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
    // 焦点变化事件
    var focuseNotify: ((_ fouced: Bool) -> Void)? = nil
    // 显示秘密啊
    @State var showPassword: Bool = false
    // 是否激活 action label
    @State private var labelActionActivate: Bool
    // action label 的宽度
    @State private var actionLabelSize: CGFloat = 0.0
    @State private var actionOriginalLabelSize: CGFloat = 0.0
    // clear 按钮 hover 状态
    @State private var clearHovering: Bool = false
    // 鼠标
    @State private var hovering: Bool = false
    // 大小
    @State private var size: CGSize = CGSize.zero

    public init(style: AKSUInputStyle = .box, label: String, actionColor: Color = .aksuPrimary, alignment: TextAlignment = .leading, disableActionLabel: Bool = false, clearButton: AKSUInputButtonShowMode = .auto, password: Bool = false, onlyNumber: Bool = false, decimalCount: Int? = nil, numberStep: Float? = nil, numberMax: Float? = nil, numberMin: Float? = nil, unit: String? = nil, passwordButton: AKSUInputButtonShowMode = .auto, text: Binding<String>, submit: (() -> Void)? = nil)
    {
        self.style = style
        self.label = label
        self.actionColor = actionColor
        self.disableActionLabel = disableActionLabel
        self.clearButton = clearButton
        self.password = password
        self.onlyNumber = onlyNumber
        self.decimalCount = decimalCount
        self.numberStep = numberStep
        self.numberMax = numberMax
        self.numberMin = numberMin
        self.unit = unit
        self.passwordButton = passwordButton
        self._text = text
        self.submit = submit
        self.textAlignment = alignment
        self.labelActionActivate = !text.wrappedValue.isEmpty
        if style == .plain {
            self.disableActionLabel = true
        }
        formatInput()
    }

    public var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Text(label)
                    .fontWeight(AKSUFont.light)
                    .foregroundStyle(focused && !disableActionLabel ? actionColor : .aksuPlaceholder)
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
                    .frame(height: disableActionLabel ? 0 : 15)
                    .padding(.top, disableActionLabel ? -2 : 0)
                    .allowsHitTesting(false)
                    .opacity((disableActionLabel && !text.isEmpty) ? 0 : 1)

                HStack {
                    ZStack {
                        if password && !showPassword {
                            SecureField("", text: $text)
                                .padding(.top, 0.3)
                                .padding(.bottom, 1.2)
                                .offset(y: focused ? 1.5 : 0) // .plain 模式下会有偏移
                        } else {
                            TextField("", text: $text)
                        }
                    }
                    .foregroundStyle(.aksuText)
                    .multilineTextAlignment(textAlignment)
                    .textFieldStyle(.plain)
                    .font(.title2)
                    .padding([.top, .bottom], 8)
                    .padding(.leading, (style == .line || style == .plain) ? 4 : 16)
                    .padding(.trailing, inputTraillingPadding())
                    .focused($focused)
                    .onChange(of: focused) { _ in
                        withAnimation {
                            labelActionActivate = (!text.isEmpty || focused) && !disableActionLabel
                        }
                        // 焦点变化通知
                        focuseNotify?(focused)
                    }
                    // 内容绑定
                    .onChange(of: text) { _ in
                        withAnimation {
                            labelActionActivate = (!text.isEmpty || focused) && !disableActionLabel
                        }
                        formatInput()
                    }
                    .onSubmit {
                        if let submit = submit {
                            submit()
                        }
                    }

                    HStack(spacing: 0) {
                        if onlyNumber, let numberStep = numberStep {
                            VStack(spacing: 2) {
                                Stepper("", onIncrement: { stepperNumber(numberStep) }, onDecrement: { stepperNumber(-numberStep) })
                            }
                            .padding(.trailing, 5)
                        }

                        if showClearButton() {
                            ZStack {
                                Image(systemName: "x.circle").foregroundColor(.aksuGray)
                            }
                            .frame(width: 20, height: 20)
                            .padding(.trailing, showPasswordButton() || showUnit() ? 0 : 5)
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
                                Image(systemName: showPassword ? "eye" : "eye.slash").foregroundColor(.aksuGray)
                            }
                            .frame(width: 20, height: 20)
                            .padding(.trailing, showUnit() ? 0 : 5)
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
                        }

                        if showUnit() {
                            ZStack {
                                Text(unit!).foregroundColor(.aksuGray)
                            }
                            .frame(width: 20, height: 20)
                            .padding(.leading, showClearButton() || showPasswordButton() ? 8 : 0)
                            .padding(.trailing, 5)
                        }
                    }
                }
                .background(
                    ZStack {
                        VStack {
                            RoundedRectangle(cornerRadius: AKSUAppearance.cornerRadius)
                                .stroke(style == .box ? (focused ? actionColor : .aksuBoard) : .clear, lineWidth: focused ? 2 : 1)
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
                                .fill(.aksuGrayMask)
                        }
                    }
                )
                .padding(.top, disableActionLabel ? 0 : -6)

                if style == .line && isEnabled {
                    VStack {}
                        .frame(maxWidth: .infinity)
                        .frame(height: 2)
                        .background(focused ? actionColor : .aksuBoard)
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

    func formatInput() {
        // 如果不是仅允许数字输入，直接返回
        if !onlyNumber || password { return }

        // 定义允许的字符集合：数字、小数点（如果允许）和负号
        var allowedCharacters = "0123456789"
        let decimal = decimalCount != 0
        if decimal {
            allowedCharacters += "."
        }
        allowedCharacters += "-"

        // 过滤掉不允许的字符
        let filtered = text.filter { allowedCharacters.contains($0) }

        // 检查用户是否想输入负数（包含任何位置的负号）
        let isNegative = filtered.contains("-")

        // 移除所有负号（后面会根据需要重新添加）
        let withoutMinus = filtered.replacingOccurrences(of: "-", with: "")

        // 处理小数部分
        let components = withoutMinus.components(separatedBy: ".")
        var result: String

        if components.count > 1 && decimal {
            // 合并整数部分和第一个小数点后的内容
            let integerPart = components[0]
            let decimalPart = components[1...].joined()
            result = "\(integerPart).\(decimalPart)"
        } else {
            result = withoutMinus
        }

        // 处理小数位数限制
        if decimal, let maxPlaces = decimalCount, let dotIndex = result.firstIndex(of: ".") {
            let decimalPart = result[result.index(dotIndex, offsetBy: 1)...]
            if decimalPart.count > maxPlaces {
                // 截断超出限制的小数部分
                let endIndex = result.index(dotIndex, offsetBy: maxPlaces + 1)
                result = String(result[..<endIndex])
            }
        }

        // 特殊情况：当用户刚输入负号但还没输入数字时，保留单独的负号
        if isNegative && result.isEmpty {
            result = "-"
        }
        // 正常情况：如果有内容且需要负号，在开头添加负号
        else if isNegative && !result.isEmpty {
            result = "-" + result
        }

        // 在主线程更新文本
        DispatchQueue.main.async {
            text = result
            stepperNumber(0)
        }
    }

    func stepperNumber(_ increment: Float) {
        if !onlyNumber || password {
            return
        }
        if text == "-" && increment == 0 {
            return
        }
        let number = Decimal(string: text) ?? Decimal(0)
        let stepValue = Decimal(string: String(increment)) ?? 0

        // 2. 根据 increment 决定增减
        var newNumber = number + stepValue

        if let numberMin = numberMin {
            let minDec = Decimal(string: String(numberMin)) ?? 0
            newNumber = max(minDec, newNumber)
        }
        if let numberMax = numberMax {
            let maxDec = Decimal(string: String(numberMax)) ?? 0
            newNumber = min(maxDec, newNumber)
        }
        // 4. 转换为字符串（自动处理末尾的 .0）
        let newText = NSDecimalNumber(decimal: newNumber).stringValue
        if !(newText == "0" && text.isEmpty) {
            text = newText
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

    func showUnit() -> Bool {
        if let unit = unit {
            return !unit.isEmpty
        }
        return false
    }

    func inputTraillingPadding() -> CGFloat {
        if textAlignment == .center {
            return style == .box ? 16 : 4
        }

        if showClearButton() || showPasswordButton() || showUnit() {
            return 0
        }

        return style == .box ? 16 : 4
    }

    func actionLabelXOffset() -> CGFloat {
        if textAlignment == .leading {
            return 0
        } else if textAlignment == .center {
            return (size.width - actionOriginalLabelSize) / 2 - (style != .box ? 4 : 15)
        } else {
            return (size.width - actionOriginalLabelSize) - (style != .box ? 4 : 15) * 2
        }
    }

    func focuesEvent(event: @escaping (_ event: Bool) -> Void) -> Self {
        var tmp = self
        tmp.focuseNotify = event
        return tmp
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
    @State var input: String = "xxxx"
    @State var style: AKSUInputStyle = .box
    @State var disableActionLabel: Bool = false
    @State var password: Bool = false
    @State var clearButton: AKSUInputButtonShowMode = .none
    @State var passwordButton: AKSUInputButtonShowMode = .none
    @State var unit: String? = nil

    @State var alignment: TextAlignment = .leading

    @State var numberMode: Bool = false
    @State var number: Int = 0
    @State var numberFloat: Float = 0
    @State var decimalCount: Int? = nil
    @State var numberStep: Float? = nil

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

                HStack {
                    Text("数字模式:")
                    AKSUSegment(selected: $numberMode) {
                        Text("文本").AKSUSegmentTag(index: false)
                        Text("整数").AKSUSegmentTag(index: true)
                    }.frame(width: 200)
                }

                HStack {
                    Text("末尾单位:")
                    AKSUSegment(selected: $unit) {
                        Text("不使用").AKSUSegmentTag(index: nil)
                        Text("使用").AKSUSegmentTag(index: "GB")
                    }.frame(width: 200)
                }

                HStack {
                    Text("小数位数:")
                    AKSUSegment(selected: $decimalCount) {
                        Text("不限制").AKSUSegmentTag(index: nil)
                        Text("不允许小数").AKSUSegmentTag(index: 0)
                        Text("2位小数").AKSUSegmentTag(index: 2)
                    }.frame(width: 200)
                        .disabled(!numberMode)
                }

                HStack {
                    Text("启用step:")
                    AKSUSegment(selected: $numberStep) {
                        Text("不启用").AKSUSegmentTag(index: nil)
                        Text("启用").AKSUSegmentTag(index: 5)
                    }.frame(width: 200)
                        .disabled(!numberMode)
                }
            }.padding()

            Text("输入内容: \(input)")
            HStack {
                AKSUInput(style: style, label: "请 输 入 文 本", alignment: alignment, disableActionLabel: disableActionLabel, clearButton: clearButton, password: password, onlyNumber: numberMode, decimalCount: decimalCount, numberStep: numberStep, numberMax: numberStep == nil ? nil : 100, numberMin: numberStep == nil ? nil : -100, unit: unit, passwordButton: passwordButton, text: $input)
                    .frame(width: 200)
            }
        }
    }
}
