//
//  AKSUTheme.swift
//  AKSwiftUI
//
//  Created by alwaysking on 2024/8/29.
//

import Foundation
import SwiftUI

class AKSUColor {
    static let blue = Color(red: 76 / 255, green: 172 / 255, blue: 248 / 255)

    static let black = Color.black
    static let gray = Color.gray
    static let gray1 = Color(red: 89 / 255, green: 90 / 255, blue: 85 / 255)
    static let gray2 = Color(red: 118 / 255, green: 118 / 255, blue: 118 / 255)
    static let gray3 = Color(red: 118 / 255, green: 118 / 255, blue: 118 / 255)

    static let dyGrayBG = Color(nsColor: NSColor(name: nil) { appearance in
        switch appearance.bestMatch(from: [.aqua, .darkAqua]) {
        case .darkAqua:
            return NSColor(red: 61 / 255, green: 63 / 255, blue: 63 / 255, alpha: 1.0) // 在深色模式下使用白色
        default:
            return NSColor(red: 218 / 255, green: 219 / 255, blue: 220 / 255, alpha: 1.0) // 在浅色模式下使用黑色
        }
    })

    static let dyGrayMask = dyGrayBG.opacity(0.4)

    static let primary = Color(red: 59 / 255, green: 113 / 255, blue: 202 / 255)
    static let success = Color(red: 20 / 255, green: 164 / 255, blue: 77 / 255)
    static let warning = Color(red: 228 / 255, green: 161 / 255, blue: 28 / 255)
    static let danger = Color(red: 249 / 255, green: 49 / 255, blue: 84 / 255)

    static func merge(up: Color, down: Color, mode: EnvironmentValues) -> Color {
        let upComponents = up.getRGB(mode)
        let downComponents = down.getRGB(mode)

        let r1 = downComponents.red
        let g1 = downComponents.green
        let b1 = downComponents.blue
        let a1 = downComponents.opacity

        let r2 = upComponents.red
        let g2 = upComponents.green
        let b2 = upComponents.blue
        let a2 = upComponents.opacity

        let outA = a2 + a1 * (1 - a2)

        // 如果 outA 为零，直接返回透明色
        guard outA > 0 else {
            return Color.clear
        }

        let outR = (r2 * a2 + r1 * a1 * (1 - a2)) / outA
        let outG = (g2 * a2 + g1 * a1 * (1 - a2)) / outA
        let outB = (b2 * a2 + b1 * a1 * (1 - a2)) / outA

        return Color(red: Double(outR), green: Double(outG), blue: Double(outB), opacity: Double(outA))
    }
}

extension Color {
    func getRGB(_ mode: EnvironmentValues) -> (red: CGFloat, green: CGFloat, blue: CGFloat, opacity: CGFloat) {
        if #available(macOS 14, *) {
            let components = self.resolve(in: mode)
            return (CGFloat(components.red), CGFloat(components.green), CGFloat(components.blue), CGFloat(components.opacity))
        } else {
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var opacity: CGFloat = 0
            NSColor(self).getRed(&red, green: &green, blue: &blue, alpha: &opacity)
            return (red, green, blue, opacity)
        }
    }

    func merge(up: Color, mode: EnvironmentValues) -> Color {
        return AKSUColor.merge(up: up, down: self, mode: mode)
    }

    func merge(down: Color, mode: EnvironmentValues) -> Color {
        return AKSUColor.merge(up: self, down: down, mode: mode)
    }
}

struct AKSUColor_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AKSUColorPreviewsView()
        }
        .frame(width: 600, height: 600)
    }
}

struct AKSUColorPreviewsView: View {
    @State var progress: CGFloat = 0
    @State var range: CGFloat = 0

    @State var index: String = "1"

    let color: [String: Color] = [
        "blue": AKSUColor.blue,
        "black": AKSUColor.black,
        "gray": AKSUColor.gray,
        "gray1": AKSUColor.gray1,
        "gray2": AKSUColor.gray2,
        "gray3": AKSUColor.gray3,

        "dyGrayBG": AKSUColor.dyGrayBG,

        "dyGrayMask": AKSUColor.dyGrayMask,

        "primary": AKSUColor.primary,
        "success": AKSUColor.success,
        "warning": AKSUColor.warning,
        "danger": AKSUColor.danger,
    ]

    let list = ["blue",
                "black",
                "gray",
                "gray1",
                "gray2",
                "gray3",
                "dyGrayBG",
                "dyGrayMask",
                "primary",
                "success",
                "warning",
                "danger"]

    var body: some View {
        ZStack {
            List {
                ForEach(list, id: \.self) {
                    key in
                    HStack {
                        Text(key).frame(width: 100, alignment: .leading)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(color[key]!)
                    }
                    .frame(height: 40)
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
