//
//  AKSUTheme.swift
//  AKSwiftUI
//
//  Created by alwaysking on 2024/8/29.
//

import Foundation
import SwiftUI

// MARK: - 颜色定义
public class AKSUColor {
    public static let blue = Color(red: 6 / 255, green: 82 / 255, blue: 237 / 255)
    public static let lightBlue = Color(red: 76 / 255, green: 172 / 255, blue: 248 / 255)

    public static let black = Color.black
    public static let white = Color.white
    public static let gray = Color.gray

    public static let textBackground = Color(NSColor.textBackgroundColor)
    public static let textForeground = Color.primary

    public static let title = Color(nsColor: NSColor(name: nil) { appearance in
        switch appearance.bestMatch(from: [.aqua, .darkAqua]) {
        case .darkAqua:
            return NSColor(red: 240 / 255, green: 240 / 255, blue: 240 / 255, alpha: 1.0)
        default:
            return NSColor(red: 24 / 255, green: 42 / 255, blue: 56 / 255, alpha: 1.0)
        }
    })

    public static let text = Color(nsColor: NSColor(name: nil) { appearance in
        switch appearance.bestMatch(from: [.aqua, .darkAqua]) {
        case .darkAqua:
            return NSColor(red: 220 / 255, green: 220 / 255, blue: 220 / 255, alpha: 1.0)
        default:
            return NSColor(red: 80 / 255, green: 80 / 255, blue: 80 / 255, alpha: 1.0)
        }
    })

    public static let secondaryText = Color(nsColor: NSColor(name: nil) { appearance in
        switch appearance.bestMatch(from: [.aqua, .darkAqua]) {
        case .darkAqua:
            return NSColor(red: 160 / 255, green: 160 / 255, blue: 160 / 255, alpha: 1.0)
        default:
            return NSColor(red: 120 / 255, green: 120 / 255, blue: 120 / 255, alpha: 1.0)
        }
    })

    public static let lessText = Color(nsColor: NSColor(name: nil) { appearance in
        switch appearance.bestMatch(from: [.aqua, .darkAqua]) {
        case .darkAqua:
            return NSColor(red: 130 / 255, green: 130 / 255, blue: 130 / 255, alpha: 1.0)
        default:
            return NSColor(red: 180 / 255, green: 180 / 255, blue: 180 / 255, alpha: 1.0)
        }
    })

    public static let dyGrayBG = Color(nsColor: NSColor(name: nil) { appearance in
        switch appearance.bestMatch(from: [.aqua, .darkAqua]) {
        case .darkAqua:
            return NSColor(red: 63 / 255, green: 63 / 255, blue: 63 / 255, alpha: 1.0)
        default:
            return NSColor(red: 220 / 255, green: 220 / 255, blue: 220 / 255, alpha: 1.0)
        }
    })

    public static let dyGrayMask = dyGrayBG.opacity(0.4)

    public static let primary = Color(red: 59 / 255, green: 113 / 255, blue: 202 / 255)
    public static let success = Color(red: 20 / 255, green: 164 / 255, blue: 77 / 255)
    public static let warning = Color(red: 228 / 255, green: 161 / 255, blue: 28 / 255)
    public static let danger = Color(red: 249 / 255, green: 49 / 255, blue: 84 / 255)
}

public extension Color {
    static let aksuBlue = AKSUColor.blue
    static let aksuLightBlue = AKSUColor.lightBlue

    static let aksuBlack = AKSUColor.black
    static let aksuWhite = AKSUColor.white
    static let aksuGray = AKSUColor.gray

    static let aksuTextBackground = AKSUColor.textBackground
    static let aksuTextForeground = AKSUColor.textForeground

    static let aksuTitle = AKSUColor.title
    static let aksuText = AKSUColor.text
    static let aksuSecondaryText = AKSUColor.secondaryText
    static let aksuLessText = AKSUColor.lessText

    static let aksuDYGrayBG = AKSUColor.dyGrayBG
    static let aksuDYGrayMask = AKSUColor.dyGrayMask

    static let aksuPrimary = AKSUColor.primary
    static let aksuSuccess = AKSUColor.success
    static let aksuWarning = AKSUColor.warning
    static let aksuDanger = AKSUColor.danger
}

public extension ShapeStyle where Self == Color {
    static var aksublue: Color { return AKSUColor.blue }
    static var aksuLightBlue: Color { return AKSUColor.lightBlue }

    static var aksuBlack: Color { return AKSUColor.black }
    static var aksuWhite: Color { return AKSUColor.white }
    static var aksuGray: Color { return AKSUColor.gray }

    static var aksuTextBackground: Color { return AKSUColor.textBackground }
    static var aksuTextForeground: Color { return AKSUColor.textForeground }

    static var aksuTitle: Color { return AKSUColor.title }
    static var aksuText: Color { return AKSUColor.text }
    static var aksuSecondaryText: Color { return AKSUColor.secondaryText }
    static var aksuLessText: Color { return AKSUColor.lessText }

    static var aksuDYGrayBG: Color { return AKSUColor.dyGrayBG }
    static var aksuDYGrayMask: Color { return AKSUColor.dyGrayMask }

    static var aksuPrimary: Color { return AKSUColor.primary }
    static var aksuSuccess: Color { return AKSUColor.success }
    static var aksuWarning: Color { return AKSUColor.warning }
    static var aksuDanger: Color { return AKSUColor.danger }
}

public extension AKSUColor {
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

public extension Color {
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

// MARK: - Previews
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
        "lightBlue": AKSUColor.lightBlue,
        "black": AKSUColor.black,
        "white": AKSUColor.white,
        "gray": AKSUColor.gray,
        "textBackground": AKSUColor.textBackground,
        "textForeground": AKSUColor.textForeground,
        "title": AKSUColor.title,
        "text": AKSUColor.text,
        "secondaryText": AKSUColor.secondaryText,
        "lessText": AKSUColor.lessText,
        "dyGrayBG": AKSUColor.dyGrayBG,
        "dyGrayMask": AKSUColor.dyGrayMask,
        "primary": AKSUColor.primary,
        "success": AKSUColor.success,
        "warning": AKSUColor.warning,
        "danger": AKSUColor.danger,
    ]

    let list = ["blue",
                "lightBlue",
                "black",
                "white",
                "gray",
                "textBackground",
                "textForeground",
                "title",
                "text",
                "secondaryText",
                "lessText",
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
