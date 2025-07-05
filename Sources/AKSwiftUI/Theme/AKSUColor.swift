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
    public static var blue = Color(red: 6 / 255, green: 82 / 255, blue: 237 / 255)
    public static var lightBlue = Color(red: 76 / 255, green: 172 / 255, blue: 248 / 255)

    public static var black = Color.black
    public static var white = Color.white
    public static var gray = Color.gray

    public static var textBackground = Color(NSColor.textBackgroundColor)
    public static var textForeground = Color.primary

    public static var title = Color(nsColor: NSColor(name: nil) { appearance in
        switch appearance.bestMatch(from: [.aqua, .darkAqua]) {
        case NSAppearance.Name.darkAqua:
            return NSColor(red: 240 / 255, green: 240 / 255, blue: 240 / 255, alpha: 1.0)
        default:
            return NSColor(red: 24 / 255, green: 42 / 255, blue: 56 / 255, alpha: 1.0)
        }
    })

    public static var text = Color(nsColor: NSColor(name: nil) { appearance in
        switch appearance.bestMatch(from: [.aqua, .darkAqua]) {
        case NSAppearance.Name.darkAqua:
            return NSColor(red: 220 / 255, green: 220 / 255, blue: 220 / 255, alpha: 1.0)
        default:
            return NSColor(red: 80 / 255, green: 80 / 255, blue: 80 / 255, alpha: 1.0)
        }
    })

    public static var secondaryText = Color(nsColor: NSColor(name: nil) { appearance in
        switch appearance.bestMatch(from: [.aqua, .darkAqua]) {
        case NSAppearance.Name.darkAqua:
            return NSColor(red: 160 / 255, green: 160 / 255, blue: 160 / 255, alpha: 1.0)
        default:
            return NSColor(red: 120 / 255, green: 120 / 255, blue: 120 / 255, alpha: 1.0)
        }
    })

    public static var lessText = Color(nsColor: NSColor(name: nil) { appearance in
        switch appearance.bestMatch(from: [.aqua, .darkAqua]) {
        case NSAppearance.Name.darkAqua:
            return NSColor(red: 130 / 255, green: 130 / 255, blue: 130 / 255, alpha: 1.0)
        default:
            return NSColor(red: 180 / 255, green: 180 / 255, blue: 180 / 255, alpha: 1.0)
        }
    })

    public static var board = Color(nsColor: NSColor(name: nil) { appearance in
        switch appearance.bestMatch(from: [.aqua, .darkAqua]) {
        case NSAppearance.Name.darkAqua:
            return NSColor(red: 251 / 255, green: 251 / 255, blue: 251 / 255, alpha: 1.0)
        default:
            return NSColor(red: 189 / 255, green: 189 / 255, blue: 189 / 255, alpha: 1.0)
        }
    })

    public static var placeholder = Color(nsColor: NSColor(name: nil) { appearance in
        switch appearance.bestMatch(from: [.aqua, .darkAqua]) {
        case NSAppearance.Name.darkAqua:
            return NSColor(red: 251 / 255, green: 251 / 255, blue: 251 / 255, alpha: 1.0)
        default:
            return NSColor(red: 113 / 255, green: 113 / 255, blue: 113 / 255, alpha: 1.0)
        }
    })

    public static var grayBackground = Color(nsColor: NSColor(name: nil) { appearance in
        switch appearance.bestMatch(from: [.aqua, .darkAqua]) {
        case NSAppearance.Name.darkAqua:
            return NSColor(red: 63 / 255, green: 63 / 255, blue: 63 / 255, alpha: 1.0)
        default:
            return NSColor(red: 220 / 255, green: 220 / 255, blue: 220 / 255, alpha: 1.0)
        }
    })

    public static var grayLessBackground = Color(nsColor: NSColor(name: nil) { appearance in
        switch appearance.bestMatch(from: [.aqua, .darkAqua]) {
        case NSAppearance.Name.darkAqua:
            return NSColor(red: 44 / 255, green: 44 / 255, blue: 44 / 255, alpha: 1.0)
        default:
            return NSColor(red: 230 / 255, green: 230 / 255, blue: 230 / 255, alpha: 1.0)
        }
    })

    public static var divider = Color(nsColor: NSColor(name: nil) { appearance in
        switch appearance.bestMatch(from: [.aqua, .darkAqua]) {
        case NSAppearance.Name.darkAqua:
            return NSColor(red: 0 / 255, green: 0 / 255, blue: 0 / 255, alpha: 1.0)
        default:
            return NSColor(red: 216 / 255, green: 216 / 255, blue: 216 / 255, alpha: 1.0)
        }
    })

    public static var grayLightMask = Color(red: 220 / 255, green: 220 / 255, blue: 220 / 255).opacity(0.4)

    public static var grayDarkMask = Color(red: 63 / 255, green: 63 / 255, blue: 63 / 255).opacity(0.4)

    public static var grayMask = Color(nsColor: NSColor(name: nil) { appearance in
        switch appearance.bestMatch(from: [.aqua, .darkAqua]) {
        case NSAppearance.Name.darkAqua:
            return NSColor(red: 63 / 255, green: 63 / 255, blue: 63 / 255, alpha: 1.0)
        default:
            return NSColor(red: 220 / 255, green: 220 / 255, blue: 220 / 255, alpha: 1.0)
        }
    }).opacity(0.4)

    public static var primary = Color(red: 59 / 255, green: 113 / 255, blue: 202 / 255)
    public static var success = Color(red: 20 / 255, green: 164 / 255, blue: 77 / 255)
    public static var warning = Color(red: 228 / 255, green: 161 / 255, blue: 28 / 255)
    public static var danger = Color(red: 249 / 255, green: 49 / 255, blue: 84 / 255)
}

public extension Color {
    static var aksuBlue: Color { return AKSUColor.blue }
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

    static var aksuBoard: Color { return AKSUColor.board }
    static var aksuPlaceholder: Color { return AKSUColor.placeholder }
    static var aksuGrayBackground: Color { return AKSUColor.grayBackground }
    static var aksuGrayLessBackground: Color { return AKSUColor.grayLessBackground }
    static var aksuDivider: Color { return AKSUColor.divider }
    static var aksuGrayLightMask :Color { return AKSUColor.grayLightMask }
    static var aksuGrayDarkMask :Color { return AKSUColor.grayDarkMask }
    static var aksuGrayMask: Color { return AKSUColor.grayMask }

    static var aksuPrimary: Color { return AKSUColor.primary }
    static var aksuSuccess: Color { return AKSUColor.success }
    static var aksuWarning: Color { return AKSUColor.warning }
    static var aksuDanger: Color { return AKSUColor.danger }
}

public extension ShapeStyle where Self == Color {
    static var aksuBlue: Color { return AKSUColor.blue }
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

    static var aksuBoard: Color { return AKSUColor.board }
    static var aksuPlaceholder: Color { return AKSUColor.placeholder }
    static var aksuGrayBackground: Color { return AKSUColor.grayBackground }
    static var aksuGrayLessBackground: Color { return AKSUColor.grayLessBackground }
    static var aksuDivider: Color { return AKSUColor.divider }
    static var aksuGrayLightMask :Color { return AKSUColor.grayLightMask }
    static var aksuGrayDarkMask :Color { return AKSUColor.grayDarkMask }
    static var aksuGrayMask: Color { return AKSUColor.grayMask }

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
            if let components = NSColor(self).cgColor.components, components.count >= 3 {
                let red = components[0]
                let green = components[1]
                let blue = components[2]
                let opacity = components.count > 3 ? components[3] : 1.0
                return (red, green, blue, opacity)
            }
            return (0, 0, 0, 0)
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
        "board": AKSUColor.board,
        "placeholder": AKSUColor.placeholder,
        "grayBackground": AKSUColor.grayBackground,
        "grayLessBackground": AKSUColor.grayLessBackground,
        "divider": AKSUColor.divider,
        "grayMask": AKSUColor.grayMask,
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
                "board",
                "placeholder",
                "grayBackground",
                "grayLessBackground",
                "divider",
                "grayMask",
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
                        RoundedRectangle(cornerRadius: AKSUAppearance.cornerRadius)
                            .fill(color[key]!)
                    }
                    .frame(height: 40)
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
