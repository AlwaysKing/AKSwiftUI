//
//  AKSUContainBox.swift
//  AKSwiftUI
//
//  Created by alwaysking on 2024/9/4.
//

import SwiftUI

public struct AKSUContainBox<T: Equatable>: View {
    var label: String
    var key: T
    @Binding var list: [T]
    var change: ((Bool, T) -> Void)?

    @State private var contain: Bool

    private var color: Color
    private var actionColor: Color

    public init(label: String, key: T, list: Binding<[T]>, color: Color = Color.primary, actionColor: Color = AKSUColor.primary, change: ((Bool, T) -> Void)? = nil) {
        self.key = key
        self._list = list
        self.contain = list.wrappedValue.contains(where: { key == $0 })
        self.label = label
        self.change = change
        self.color = color
        self.actionColor = actionColor
    }

    public var body: some View {
        AKSUCheckBox(checked: contain, label: label, color: color, actionColor: actionColor) {
            checked in
            if checked {
                list.append(key)
                if let change = change {
                    change(true, key)
                }
            } else {
                list.removeAll(where: { key == $0 })
                if let change = change {
                    change(false, key)
                }
            }
        }
    }
}

struct AKSUContainBox_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AKSUContainBoxPreviewsView()
        }
        .frame(width: 600, height: 600)
    }
}

struct AKSUContainBoxPreviewsView: View {
    @State var checked: Bool = false
    @State var list: [String] = ["E"]

    var body: some View {
        VStack {
            HStack {
                AKSUContainBox(label: "C", key: "C", list: $list)
                AKSUContainBox(label: "D", key: "D", list: $list)
            }
        }
    }
}
