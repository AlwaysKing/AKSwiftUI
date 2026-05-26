//
//  AKSUCheckBox.swift
//  AKSwiftUI
//
//  Created by alwaysking on 2024/9/1.
//

import SwiftUI

public enum AKSUToggleStyle {
    case checkbox
    case `switch`
}

public enum AKSUToggleAlignment {
    case top
    case center
    case bottom

    var verticalAlignment: VerticalAlignment {
        switch self {
        case .top: return .top
        case .center: return .center
        case .bottom: return .bottom
        }
    }
}

public struct AKSUToggle: View {
    @Environment(\.self) var environment
    @Environment(\.isEnabled) private var isEnabled
    @Binding var toggle: Bool
    var label: String = ""
    var style: AKSUToggleStyle
    var slimSwitch: Bool
    var controlSize: CGFloat
    var font: Font
    var alignment: AKSUToggleAlignment
    var color: Color
    var actionColor: Color
    var boardColor: Color
    var bgColor: Color
    var change: ((Bool) -> Void)?

    @State var realToggle: Bool

    public init(style: AKSUToggleStyle = .checkbox, slimSwitch: Bool = false, controlSize: CGFloat = 20, font: Font = .title2, alignment: AKSUToggleAlignment = .center, label: String, color: Color = .aksuText, actionColor: Color = .aksuPrimary, boardColor: Color = .aksuBoard, bgColor: Color = .clear, change: ((Bool) -> Void)? = nil) {
        self.style = style
        self.label = label
        self.color = color
        self.actionColor = actionColor
        self._toggle = .constant(false)
        self.change = change
        self.realToggle = false
        self.slimSwitch = slimSwitch
        self.controlSize = controlSize
        self.font = font
        self.alignment = alignment
        self.boardColor = boardColor
        self.bgColor = bgColor
    }

    public init(style: AKSUToggleStyle = .checkbox, slimSwitch: Bool = false, controlSize: CGFloat = 20, font: Font = .title2, alignment: AKSUToggleAlignment = .center, toggle: Bool, label: String, color: Color = .aksuText, actionColor: Color = .aksuPrimary, boardColor: Color = .aksuBoard, bgColor: Color = .clear, change: ((Bool) -> Void)? = nil) {
        self.style = style
        self.slimSwitch = slimSwitch
        self.controlSize = controlSize
        self.font = font
        self.alignment = alignment
        self._toggle = .constant(false)
        self.label = label
        self.color = color
        self.actionColor = actionColor
        self.change = change
        self.realToggle = toggle
        self.boardColor = boardColor
        self.bgColor = bgColor
    }

    public init(style: AKSUToggleStyle = .checkbox, slimSwitch: Bool = false, controlSize: CGFloat = 20, font: Font = .title2, alignment: AKSUToggleAlignment = .center, toggle: Binding<Bool>, label: String, color: Color = .aksuText, actionColor: Color = .aksuPrimary, boardColor: Color = .aksuBoard, bgColor: Color = .clear, change: ((Bool) -> Void)? = nil) {
        self.style = style
        self.slimSwitch = slimSwitch
        self.controlSize = controlSize
        self.font = font
        self.alignment = alignment
        self._toggle = toggle
        self.label = label
        self.color = color
        self.actionColor = actionColor
        self.change = change
        self.realToggle = toggle.wrappedValue
        self.boardColor = boardColor
        self.bgColor = bgColor
    }

    public var body: some View {
        HStack(alignment: alignment.verticalAlignment) {
            if style == .checkbox {
                ZStack {
                    if realToggle {
                        Image(systemName: "checkmark")
                            .foregroundColor(.aksuWhite)
                            .font(.system(size: controlSize * 0.6, weight: .semibold))
                    }
                }
                .frame(width: controlSize, height: controlSize)
                .background(realToggle ? actionColor : bgColor)
                .cornerRadius(controlSize * 0.2)
                .overlay {
                    RoundedRectangle(cornerRadius: AKSUAppearance.cornerRadius)
                        .stroke(realToggle ? actionColor : boardColor)
                }
                .overlay {
                    if !isEnabled {
                        RoundedRectangle(cornerRadius: AKSUAppearance.cornerRadius)
                            .fill(.aksuGrayMask)
                    }
                }
            } else if style == .switch {
                ZStack {
                    RoundedRectangle(cornerRadius: controlSize * 0.5)
                        .fill(realToggle ? actionColor : bgColor)
                        .overlay {
                            if !isEnabled {
                                RoundedRectangle(cornerRadius: AKSUAppearance.cornerRadius)
                                    .fill(.aksuGrayMask)
                            }
                        }
                        .padding(.vertical, slimSwitch ? controlSize * 0.25 : 0)
                        .padding(.horizontal, slimSwitch ? controlSize * 0.1 : 0)

                    RoundedRectangle(cornerRadius: controlSize * 0.5)
                        .stroke(realToggle ? actionColor : boardColor)
                        .overlay {
                            if !isEnabled {
                                RoundedRectangle(cornerRadius: AKSUAppearance.cornerRadius)
                                    .fill(.aksuGrayMask)
                            }
                        }
                        .padding(.vertical, slimSwitch ? controlSize * 0.25 : 0)
                        .padding(.horizontal, slimSwitch ? controlSize * 0.1 : 0)

                    Circle()
                        .foregroundStyle(.white)
                        .overlay {
                            if !isEnabled {
                                Circle()
                                    .fill(.aksuGrayMask)
                            }
                        }
                        .padding(controlSize * 0.05)
                        .offset(x: realToggle ? controlSize * 0.5 : -(controlSize * 0.5))
                        .shadow(radius: 2)
                }
                .frame(width: controlSize * 2, height: controlSize)
            }

            Text(label)
                .foregroundStyle(.aksuText)
                .font(font)
                .foregroundColor(isEnabled ? color : color.merge(up: .aksuGrayMask, mode: environment))
                .padding(.trailing)
        }
        .background(.white.opacity(0.01))
        .onChange(of: toggle) { _ in
            realToggle = toggle
        }
        .onTapGesture {
            withAnimation {
                realToggle.toggle()
            }
            toggle = realToggle
            if let change = change {
                change(realToggle)
            }
        }
    }
}

struct AKSUCheckBox_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AKSUTogglePreviewsView()
        }
        .frame(width: 600, height: 600)
    }
}

struct AKSUTogglePreviewsView: View {
    @State var checked: Bool = true
    @State var list: [String] = ["E"]

    var body: some View {
        VStack(spacing: 20) {
            // 原始默认效果
            Text("默认 (controlSize: 20, font: .title2, center)")
            HStack {
                AKSUToggle(label: "A", boardColor: .yellow, bgColor: .green) {
                    checked in
                    print("check1 = \(checked)")
                }
                AKSUToggle(toggle: checked, label: "B") {
                    checked in
                    print("check2 = \(checked)")
                }
                AKSUToggle(toggle: $checked, label: "C") {
                    checked in
                    print("check3 = \(checked)")
                }
                .disabled(true)
            }

            // 大尺寸效果
            Text("大尺寸 (controlSize: 30, font: .largeTitle)")
            HStack {
                AKSUToggle(controlSize: 30, font: .largeTitle, label: "Large") {
                    checked in
                    print("large = \(checked)")
                }
                AKSUToggle(style: .switch, controlSize: 30, font: .largeTitle, label: "Large") {
                    checked in
                    print("large switch = \(checked)")
                }
            }

            // 小尺寸效果
            Text("小尺寸 (controlSize: 14, font: .caption)")
            HStack {
                AKSUToggle(controlSize: 14, font: .caption, label: "Small") {
                    checked in
                    print("small = \(checked)")
                }
                AKSUToggle(style: .switch, controlSize: 14, font: .caption, label: "Small") {
                    checked in
                    print("small switch = \(checked)")
                }
            }

            // 不同对齐方式
            Text("对齐方式 (top / center / bottom)")
            HStack(alignment: .top) {
                AKSUToggle(controlSize: 30, font: .title, alignment: .top, label: "Top") {
                    checked in
                    print("top = \(checked)")
                }
                AKSUToggle(controlSize: 30, font: .title, alignment: .center, label: "Center") {
                    checked in
                    print("center = \(checked)")
                }
                AKSUToggle(controlSize: 30, font: .title, alignment: .bottom, label: "Bottom") {
                    checked in
                    print("bottom = \(checked)")
                }
            }

            // 原有的 Switch 预览
            Text("Switch 样式")
            HStack {
                AKSUToggle(style: .switch, label: "A", boardColor: .yellow, bgColor: .green) {
                    checked in
                    print("check1 = \(checked)")
                }
                AKSUToggle(style: .switch, toggle: checked, label: "B") {
                    checked in
                    print("check2 = \(checked)")
                }
                AKSUToggle(style: .switch, toggle: $checked, label: "C") {
                    checked in
                    print("check3 = \(checked)")
                }
                .disabled(true)
            }

            // Slim Switch
            Text("Slim Switch")
            HStack {
                AKSUToggle(style: .switch, slimSwitch: true, label: "A", boardColor: .yellow, bgColor: .green) {
                    checked in
                    print("check1 = \(checked)")
                }
                AKSUToggle(style: .switch, slimSwitch: true, toggle: checked, label: "B") {
                    checked in
                    print("check2 = \(checked)")
                }
                AKSUToggle(style: .switch, slimSwitch: true, toggle: $checked, label: "C") {
                    checked in
                    print("check3 = \(checked)")
                }
                .disabled(true)
            }
        }
        .padding()
    }
}
