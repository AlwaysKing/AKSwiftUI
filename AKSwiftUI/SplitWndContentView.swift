//
//  SplitWndContentView.swift
//  AKSwiftUI
//
//  Created by alwaysking on 2024/8/29.
//

import SwiftUI

@available(macOS 14.0, *)
struct SplitWndContentView: View {
    @Binding var light: Bool

    @State var showLeftView: Bool = true
    @State var showRightView: Bool = true
    @State var disable: Bool = false

    @State var refresh: Int = 0
    @State var bg: Bool = false
    @State var r: CGFloat = 0.0
    @State var g: CGFloat = 0.0
    @State var b: CGFloat = 0.0

    @State var selected: String = "Color"

    let menu: [String: [String]] = [
        "主题": ["Color", "Font"],
        "布局": ["Flex", "Grid", "Split"],
        "组件": ["Button", "Click", "Group", "Input", "InputGroup", "PinInput", "Dropdown", "PopWnd", "Popover", "Toast", "CheckBox", "ContainBox", "Radio", "Range", "Progress", "step", "CircleProgress", "Collapse", "SetpScrollView", "Segment", "Table"]
    ]

    var body: some View {
        ZStack {
            AKSUSplitWnd(leftToolBar: true, showLeft: $showLeftView, showRight: $showRightView) {
                VStack {
                    switch selected {
                    case "Color": AKSUColorPreviewsView()
                    case "Font": AKSUFontPreviewsView()
                    case "Flex": AKSUFlexPreviewsView()
                    case "Grid": AKSUGridPreviewsView()
                    case "Split": AKSUSplitStackPreviewsView()
                    case "Button": AKSUButtonPreviewsView()
                    case "Click": AKSUClickPreviewsView()
                    case "Group": AKSUGroupPreviewsView()
                    case "Input": AKSUInputPreviewsView()
                    case "InputGroup": AKSUInputGroupPreviewsView()
                    case "PinInput": AKSUInputPinPreviewsView()
                    case "Dropdown": AKSUDropdownPreviewsView()
                    case "PopWnd": AKSUPopWndPreviewsView()
                    case "Popover": AKSUPopoverPreviewsView()
                    case "Toast": AKSUToastPreviewsView()
                    case "CheckBox": AKSUCheckBoxPreviewsView()
                    case "ContainBox": AKSUContainBoxPreviewsView()
                    case "Radio": AKSURadioPreviewsView()
                    case "Range": AKSURangePreviewsView()
                    case "Progress": AKSUProgressPreviewsView()
                    case "step": AKSUStepPreviewsView()
                    case "CircleProgress": AKSUCircleProgressPreviewsView()
                    case "Collapse": AKSUCollapsePreviewsView()
                    case "SetpScrollView": AKSUStepScrollviewPreviewsView()
                    case "Segment": AKSUSegmentPreviewsView()
                    case "Table": AKSUTablePreviewsView()
                    default: VStack {}
                    }
                }
                .disabled(disable)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
                .background {
                    if bg {
                        Color(red: r / 255, green: g / 255, blue: b / 255)
                    } else {
                        Color.clear
                    }
                }
                .environment(<#T##keyPath: WritableKeyPath<EnvironmentValues, V>##WritableKeyPath<EnvironmentValues, V>#>, <#T##value: V##V#>)
            } leftView: {
                List {
                    ForEach(["主题", "布局", "组件"], id: \.self) {
                        key in
                        let list = menu[key]!
                        Section(header: Text(key)) {
                            ForEach(list, id: \.self) {
                                title in
                                AKSUButton {
                                    Text(title)
                                        .foregroundColor(.white)
                                        .font(.title)
                                        .frame(maxWidth: .infinity)
                                } action: {
                                    selected = title
                                }
                            }
                        }
                    }
                }
            } rightView: {
                VStack {
                    HStack {
                        AKSUClick {
                            Image(systemName: light ? "sun.max" : "moon.fill")
                                .font(.title)
                        } action: {
                            light.toggle()
                        }

                        AKSUClick {
                            Image(systemName: disable ? "cursorarrow.slash.square" : "cursorarrow.square")
                                .font(.title)
                        } action: {
                            disable.toggle()
                        }
                    }.padding()

                    AKSUCheckBox(checked: $bg, label: "启用背景")

                    VStack {
                        HStack {
                            Text("R:\(Int(r)):")
                                .frame(width: 50)
                            AKSURange(step: 1, min: 0, max: 255, progress: $r, actionColor: .red)
                                .frame(width: 100)
                        }

                        HStack {
                            Text("G:\(Int(g)):")
                                .frame(width: 50)
                            AKSURange(step: 1, min: 0, max: 255, progress: $g, actionColor: .green)
                                .frame(width: 100)
                        }
                        HStack {
                            Text("B:\(Int(b)):")
                                .frame(width: 50)
                            AKSURange(step: 1, min: 0, max: 255, progress: $b, actionColor: .blue)
                                .frame(width: 100)
                        }
                    }
                    VStack {
                        Text("切换主体颜色")
                            .font(.aksuTitle4).padding()

                        AKSUButton("", bgColor: .red) {
                            AKSUColor.primary = .red
                        }
                        AKSUButton("", bgColor: .green) {
                            AKSUColor.primary = .green
                        }
                        AKSUButton("", bgColor: .blue) {
                            AKSUColor.primary = .blue
                        }
                        AKSUButton("", bgColor: .aksuLightBlue) {
                            AKSUColor.primary = .aksuLightBlue
                        }
                    }
                    Spacer()
                }
            }
            .leftWndSize(min: 200, ideal: 350, max: 350)
            .rightWndSize(min: 200, ideal: 200, max: 200)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

@available(macOS 14.0, *)
#Preview {
    SplitWndContentView(light: .constant(true))
}
