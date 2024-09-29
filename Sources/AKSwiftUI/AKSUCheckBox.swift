//
//  AKSUCheckBox.swift
//  AKSwiftUI
//
//  Created by alwaysking on 2024/9/1.
//

import SwiftUI

public struct AKSUCheckBox: View {
    @Environment(\.self) var environment
    @Environment(\.isEnabled) private var isEnabled
    @Binding var checked: Bool
    var label: String = ""
    var color: Color
    var actionColor: Color
    var change: ((Bool) -> Void)?

    @State var realChecked: Bool

    public init(label: String, color: Color = Color.primary, actionColor: Color = AKSUColor.primary, change: ((Bool) -> Void)? = nil) {
        self.label = label
        self.color = color
        self.actionColor = actionColor
        self._checked = .constant(false)
        self.change = change
        self.realChecked = false
    }

    public init(checked: Bool, label: String, color: Color = Color.primary, actionColor: Color = AKSUColor.primary, change: ((Bool) -> Void)? = nil) {
        self._checked = .constant(false)
        self.label = label
        self.color = color
        self.actionColor = actionColor
        self.change = change
        self.realChecked = checked
    }

    public init(checked: Binding<Bool>, label: String, color: Color = Color.primary, actionColor: Color = AKSUColor.primary, change: ((Bool) -> Void)? = nil) {
        self._checked = checked
        self.label = label
        self.color = color
        self.actionColor = actionColor
        self.change = change
        self.realChecked = checked.wrappedValue
    }

    public var body: some View {
        HStack {
            ZStack {
                if realChecked {
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                }
            }
            .frame(width: 20, height: 20)
            .background(realChecked ? actionColor : nil)
            .cornerRadius(4.0)
            .overlay {
                RoundedRectangle(cornerRadius: AKSUAppearance.cornerRadius)
                    .stroke(realChecked ? actionColor : AKSUColor.gray)
            }
            .overlay {
                if !isEnabled {
                    RoundedRectangle(cornerRadius: AKSUAppearance.cornerRadius)
                        .fill(AKSUColor.dyGrayMask)
                }
            }

            Text(label)
                .font(.title2)
                .foregroundColor(isEnabled ? color : color.merge(up: AKSUColor.dyGrayMask, mode: environment))
                .padding(.trailing)
        }
        .background(.white.opacity(0.01))
        .onChange(of: checked) { _ in
            realChecked = checked
        }
        .onTapGesture {
            realChecked.toggle()
            checked = realChecked
            if let change = change {
                change(realChecked)
            }
        }
    }
}

struct AKSUCheckBox_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AKSUCheckBoxPreviewsView()
        }
        .frame(width: 600, height: 600)
    }
}

struct AKSUCheckBoxPreviewsView: View {
    @State var checked: Bool = false
    @State var list: [String] = ["E"]

    var body: some View {
        VStack {
            HStack {
                AKSUCheckBox(label: "A") {
                    checked in
                    print("check1 = \(checked)")
                }

                AKSUCheckBox(checked: checked, label: "B") {
                    checked in
                    print("check2 = \(checked)")
                }
                
                AKSUCheckBox(checked: $checked, label: "c") {
                    checked in
                    print("check3 = \(checked)")
                }
                .disabled(true)
            }
        }
    }
}
