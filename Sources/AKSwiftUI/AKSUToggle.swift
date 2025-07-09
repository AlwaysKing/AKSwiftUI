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

public struct AKSUToggle: View {
    @Environment(\.self) var environment
    @Environment(\.isEnabled) private var isEnabled
    @Binding var toggle: Bool
    var label: String = ""
    var style: AKSUToggleStyle
    var slimSwitch: Bool
    var color: Color
    var actionColor: Color
    var change: ((Bool) -> Void)?

    @State var realToggle: Bool

    public init(style: AKSUToggleStyle = .checkbox, slimSwitch: Bool = false, label: String, color: Color = .aksuText, actionColor: Color = .aksuPrimary, change: ((Bool) -> Void)? = nil) {
        self.style = style
        self.label = label
        self.color = color
        self.actionColor = actionColor
        self._toggle = .constant(false)
        self.change = change
        self.realToggle = false
        self.slimSwitch = slimSwitch
    }

    public init(style: AKSUToggleStyle = .checkbox, slimSwitch: Bool = false, toggle: Bool, label: String, color: Color = .aksuText, actionColor: Color = .aksuPrimary, change: ((Bool) -> Void)? = nil) {
        self.style = style
        self.slimSwitch = slimSwitch
        self._toggle = .constant(false)
        self.label = label
        self.color = color
        self.actionColor = actionColor
        self.change = change
        self.realToggle = toggle
    }

    public init(style: AKSUToggleStyle = .checkbox, slimSwitch: Bool = false, toggle: Binding<Bool>, label: String, color: Color = .aksuText, actionColor: Color = .aksuPrimary, change: ((Bool) -> Void)? = nil) {
        self.style = style
        self.slimSwitch = slimSwitch
        self._toggle = toggle
        self.label = label
        self.color = color
        self.actionColor = actionColor
        self.change = change
        self.realToggle = toggle.wrappedValue
    }

    public var body: some View {
        HStack {
            if style == .checkbox {
                ZStack {
                    if realToggle {
                        Image(systemName: "checkmark")
                            .foregroundColor(.aksuWhite)
                    }
                }
                .frame(width: 20, height: 20)
                .background(realToggle ? actionColor : nil)
                .cornerRadius(4.0)
                .overlay {
                    RoundedRectangle(cornerRadius: AKSUAppearance.cornerRadius)
                        .stroke(realToggle ? actionColor : .aksuBoard)
                }
                .overlay {
                    if !isEnabled {
                        RoundedRectangle(cornerRadius: AKSUAppearance.cornerRadius)
                            .fill(.aksuGrayMask)
                    }
                }
            } else if style == .switch {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(realToggle ? actionColor : .aksuGrayLessBackground)
                        .overlay {
                            if !isEnabled {
                                RoundedRectangle(cornerRadius: AKSUAppearance.cornerRadius)
                                    .fill(.aksuGrayMask)
                            }
                        }
                        .padding(.vertical, slimSwitch ? 5 : 0)
                        .padding(.horizontal, slimSwitch ? 2 : 0)

                    RoundedRectangle(cornerRadius: 10)
                        .stroke(realToggle ? actionColor : .aksuBoard)
                        .overlay {
                            if !isEnabled {
                                RoundedRectangle(cornerRadius: AKSUAppearance.cornerRadius)
                                    .fill(.aksuGrayMask)
                            }
                        }
                        .padding(.vertical, slimSwitch ? 5 : 0)
                        .padding(.horizontal, slimSwitch ? 2 : 0)

                    Circle()
                        .foregroundStyle(.white)
                        .overlay {
                            if !isEnabled {
                                Circle()
                                    .fill(.aksuGrayMask)
                            }
                        }
                        .padding(1)
                        .offset(x: realToggle ? 10 : -10)
                        .shadow(radius: 2)
                }
                .frame(width: 40, height: 20)
            }

            Text(label)
                .foregroundStyle(.aksuText)
                .font(.title2)
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
        VStack {
            HStack {
                AKSUToggle(label: "A") {
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

            HStack {
                AKSUToggle(style: .switch, label: "A") {
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
            HStack {
                AKSUToggle(style: .switch, slimSwitch: true, label: "A") {
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
    }
}
