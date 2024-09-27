//
//  AKSURadio.swift
//  AKSwiftUI
//
//  Created by alwaysking on 2024/9/2.
//

import SwiftUI

public struct AKSURadio<V: Equatable>: View {
    @Environment(\.self) var environment
    @Environment(\.isEnabled) private var isEnabled

    var label: String
    let key: V
    @Binding var checked: V
    var color: Color
    var actionColor: Color

    public init(label: String, key: V, checked: Binding<V>, color: Color = Color.primary, actionColor: Color = AKSUColor.primary) {
        self.label = label
        self.key = key
        self._checked = checked
        self.color = color
        self.actionColor = actionColor
    }

    public var body: some View {
        HStack {
            ZStack {
                if key == checked {
                    Circle()
                        .padding(4)
                        .foregroundColor(actionColor.opacity(isEnabled ? 1 : 0.4))
                }
            }
            .frame(width: 20, height: 20)
            .cornerRadius(4.0)
            .overlay {
                Circle()
                    .stroke(key == checked ? actionColor : AKSUColor.gray)
            }
            .overlay {
                if !isEnabled {
                    Circle()
                        .fill(AKSUColor.dyGrayMask)
                }
            }

            Text(label)
                .font(.title2)
                .foregroundColor(isEnabled ? color : color.merge(up: AKSUColor.dyGrayMask, mode: environment))
                .padding(.trailing)
        }
        .background(.white.opacity(0.01))
        .onTapGesture {
            checked = key
        }
    }
}

struct AKSURadio_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AKSURadioPreviewsView()
        }
        .frame(width: 600, height: 600)
    }
}

struct AKSURadioPreviewsView: View {
    @State var checked: String = "A"
    @State var checked2: String = "A"

    var body: some View {
        VStack {
            HStack {
                AKSURadio(label: "A", key: "A", checked: $checked)
                AKSURadio(label: "B", key: "B", checked: $checked)
                AKSURadio(label: "C", key: "C", checked: $checked)
            }
            HStack {
                AKSURadio(label: "C", key: "C", checked: $checked).disabled(true)
                AKSURadio(label: "D", key: "D", checked: $checked).disabled(true)
            }
        }
    }
}
