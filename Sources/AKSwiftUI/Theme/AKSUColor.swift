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
    // 动态颜色定义
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

    public static var black = Color.black
    public static var white = Color.white
    public static var gray = Color.gray

    public static var textBackground = Color(NSColor.textBackgroundColor)
    public static var textForeground = Color.primary
    public static var primary = Color(red: 59 / 255, green: 113 / 255, blue: 202 / 255) // #3b71ca
    public static var success = Color(red: 20 / 255, green: 164 / 255, blue: 77 / 255) // #14a44d
    public static var warning = Color(red: 228 / 255, green: 161 / 255, blue: 28 / 255) // #e4a11c
    public static var danger = Color(red: 249 / 255, green: 49 / 255, blue: 84 / 255) // #f93154

    // Red Colors
    public static var brightRed = Color(red: 255 / 255, green: 59 / 255, blue: 48 / 255)  // #FF3B30
    public static var red = Color(red: 240 / 255, green: 62 / 255, blue: 62 / 255)        // #F03E3E
    public static var lightRed = Color(red: 255 / 255, green: 135 / 255, blue: 135 / 255)  // #FF8787

    // Cyan Colors
    public static var brightCyan = Color(red: 82 / 255, green: 237 / 255, blue: 6 / 255)   // #52ED06
    public static var cyan = Color(red: 82 / 255, green: 237 / 255, blue: 6 / 255)         // #52ED06
    public static var lightCyan = Color(red: 145 / 255, green: 241 / 255, blue: 112 / 255) // #91F170

    // Green Colors
    public static var brightGreen = Color(red: 40 / 255, green: 205 / 255, blue: 65 / 255) // #28CD41
    public static var green = Color(red: 40 / 255, green: 205 / 255, blue: 65 / 255)        // #28CD41
    public static var lightGreen = Color(red: 140 / 255, green: 233 / 255, blue: 154 / 255) // #8CE99A

    // Lime Colors
    public static var deepLime = Color(red: 130 / 255, green: 201 / 255, blue: 30 / 255)   // #82C91E
    public static var lime = Color(red: 148 / 255, green: 216 / 255, blue: 45 / 255)        // #94D82D
    public static var lightLime = Color(red: 192 / 255, green: 235 / 255, blue: 117 / 255) // #C0EB75

    // Blue Colors
    public static var brightBlue = Color(red: 0 / 255, green: 122 / 255, blue: 255 / 255)   // #007AFF
    public static var blue = Color(red: 6 / 255, green: 82 / 255, blue: 237 / 255)         // #0652ED
    public static var lightBlue = Color(red: 77 / 255, green: 171 / 255, blue: 247 / 255)  // #4DABF7

    // Yellow Colors
    public static var brightYellow = Color(red: 255 / 255, green: 204 / 255, blue: 0 / 255) // #FFCC00
    public static var yellow = Color(red: 252 / 255, green: 196 / 255, blue: 25 / 255)      // #FCC419
    public static var lightYellow = Color(red: 255 / 255, green: 236 / 255, blue: 153 / 255) // #FFEC99

    // Pink Colors
    public static var brightPink = Color(red: 255 / 255, green: 45 / 255, blue: 85 / 255)  // #FF2D55
    public static var pink = Color(red: 248 / 255, green: 76 / 255, blue: 172 / 255)        // #F84CAC
    public static var lightPink = Color(red: 250 / 255, green: 162 / 255, blue: 193 / 255)  // #FAA2C1

    // Purple Colors
    public static var brightPurple = Color(red: 190 / 255, green: 75 / 255, blue: 219 / 255) // #BE4BDB
    public static var purple = Color(red: 175 / 255, green: 82 / 255, blue: 222 / 255)       // #AF52DE
    public static var lightPurple = Color(red: 229 / 255, green: 153 / 255, blue: 247 / 255) // #E599F7
}

public extension Color {
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
    static var aksuGrayLightMask: Color { return AKSUColor.grayLightMask }
    static var aksuGrayDarkMask: Color { return AKSUColor.grayDarkMask }
    static var aksuGrayMask: Color { return AKSUColor.grayMask }

    static var aksuPrimary: Color { return AKSUColor.primary }
    static var aksuSuccess: Color { return AKSUColor.success }
    static var aksuWarning: Color { return AKSUColor.warning }
    static var aksuDanger: Color { return AKSUColor.danger }

    // MARK: - Red Colors
    static var aksuBrightRed: Color { return AKSUColor.brightRed }
    static var aksuRed: Color { return AKSUColor.red }
    static var aksuLightRed: Color { return AKSUColor.lightRed }
    
    // MARK: - Cyan Colors
    static var aksuBrightCyan: Color { return AKSUColor.brightCyan }
    static var aksuCyan: Color { return AKSUColor.cyan }
    static var aksuLightCyan: Color { return AKSUColor.lightCyan }
    
    // MARK: - Green Colors
    static var aksuBrightGreen: Color { return AKSUColor.brightGreen }
    static var aksuGreen: Color { return AKSUColor.green }
    static var aksuLightGreen: Color { return AKSUColor.lightGreen }
    
    // MARK: - Lime Colors
    static var aksuDeepLime: Color { return AKSUColor.deepLime }
    static var aksuLime: Color { return AKSUColor.lime }
    static var aksuLightLime: Color { return AKSUColor.lightLime }
    
    // MARK: - Blue Colors
    static var aksuBrightBlue: Color { return AKSUColor.brightBlue }
    static var aksuBlue: Color { return AKSUColor.blue }
    static var aksuLightBlue: Color { return AKSUColor.lightBlue }
    
    // MARK: - Yellow Colors
    static var aksuBrightYellow: Color { return AKSUColor.brightYellow }
    static var aksuYellow: Color { return AKSUColor.yellow }
    static var aksuLightYellow: Color { return AKSUColor.lightYellow }
    
    // MARK: - Pink Colors
    static var aksuBrightPink: Color { return AKSUColor.brightPink }
    static var aksuPink: Color { return AKSUColor.pink }
    static var aksuLightPink: Color { return AKSUColor.lightPink }
    
    // MARK: - Purple Colors
    static var aksuBrightPurple: Color { return AKSUColor.brightPurple }
    static var aksuPurple: Color { return AKSUColor.purple }
    static var aksuLightPurple: Color { return AKSUColor.lightPurple }
}

public extension ShapeStyle where Self == Color {
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
    static var aksuGrayLightMask: Color { return AKSUColor.grayLightMask }
    static var aksuGrayDarkMask: Color { return AKSUColor.grayDarkMask }
    static var aksuGrayMask: Color { return AKSUColor.grayMask }

    static var aksuPrimary: Color { return AKSUColor.primary }
    static var aksuSuccess: Color { return AKSUColor.success }
    static var aksuWarning: Color { return AKSUColor.warning }
    static var aksuDanger: Color { return AKSUColor.danger }

    // MARK: - Red Colors
    static var aksuBrightRed: Color { return AKSUColor.brightRed }
    static var aksuRed: Color { return AKSUColor.red }
    static var aksuLightRed: Color { return AKSUColor.lightRed }
    
    // MARK: - Cyan Colors
    static var aksuBrightCyan: Color { return AKSUColor.brightCyan }
    static var aksuCyan: Color { return AKSUColor.cyan }
    static var aksuLightCyan: Color { return AKSUColor.lightCyan }
    
    // MARK: - Green Colors
    static var aksuBrightGreen: Color { return AKSUColor.brightGreen }
    static var aksuGreen: Color { return AKSUColor.green }
    static var aksuLightGreen: Color { return AKSUColor.lightGreen }
    
    // MARK: - Lime Colors
    static var aksuDeepLime: Color { return AKSUColor.deepLime }
    static var aksuLime: Color { return AKSUColor.lime }
    static var aksuLightLime: Color { return AKSUColor.lightLime }
    
    // MARK: - Blue Colors
    static var aksuBrightBlue: Color { return AKSUColor.brightBlue }
    static var aksuBlue: Color { return AKSUColor.blue }
    static var aksuLightBlue: Color { return AKSUColor.lightBlue }
    
    // MARK: - Yellow Colors
    static var aksuBrightYellow: Color { return AKSUColor.brightYellow }
    static var aksuYellow: Color { return AKSUColor.yellow }
    static var aksuLightYellow: Color { return AKSUColor.lightYellow }
    
    // MARK: - Pink Colors
    static var aksuBrightPink: Color { return AKSUColor.brightPink }
    static var aksuPink: Color { return AKSUColor.pink }
    static var aksuLightPink: Color { return AKSUColor.lightPink }
    
    // MARK: - Purple Colors
    static var aksuBrightPurple: Color { return AKSUColor.brightPurple }
    static var aksuPurple: Color { return AKSUColor.purple }
    static var aksuLightPurple: Color { return AKSUColor.lightPurple }
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
    /// 通过 Hex 字符串初始化颜色（支持 #RGB、#RGBA、#RRGGBB、#RRGGBBAA 格式）
    /// - Parameters:
    ///   - hex: Hex 字符串（如 "#0652ed" 或 "0652ed"）
    ///   - opacity: 透明度（0.0 ~ 1.0），优先级高于 Hex 中的 Alpha 通道
    init(hex: String, opacity: Double = 1.0) {
        var sanitizedHex = hex.trimmingCharacters(in: .whitespacesAndNewlines)

        // 去除前缀 # 或 0x
        if sanitizedHex.hasPrefix("#") {
            sanitizedHex.removeFirst()
        } else if sanitizedHex.lowercased().hasPrefix("0x") {
            sanitizedHex = String(sanitizedHex.dropFirst(2))
        }

        // 根据 Hex 长度解析颜色
        var rgbValue: UInt64 = 0
        Scanner(string: sanitizedHex).scanHexInt64(&rgbValue)

        var alpha = opacity
        let red, green, blue: Double

        switch sanitizedHex.count {
        case 3: // RGB (12-bit)
            red = Double((rgbValue >> 8) & 0xF) / 15.0
            green = Double((rgbValue >> 4) & 0xF) / 15.0
            blue = Double(rgbValue & 0xF) / 15.0
        case 4: // RGBA (16-bit)
            red = Double((rgbValue >> 12) & 0xF) / 15.0
            green = Double((rgbValue >> 8) & 0xF) / 15.0
            blue = Double((rgbValue >> 4) & 0xF) / 15.0
            alpha = Double(rgbValue & 0xF) / 15.0
        case 6: // RRGGBB (24-bit)
            red = Double((rgbValue >> 16) & 0xFF) / 255.0
            green = Double((rgbValue >> 8) & 0xFF) / 255.0
            blue = Double(rgbValue & 0xFF) / 255.0
        case 8: // RRGGBBAA (32-bit)
            red = Double((rgbValue >> 24) & 0xFF) / 255.0
            green = Double((rgbValue >> 16) & 0xFF) / 255.0
            blue = Double((rgbValue >> 8) & 0xFF) / 255.0
            alpha = Double(rgbValue & 0xFF) / 255.0
        default: // 无效格式，返回透明色（或自定义默认值）
            self.init(.sRGB, red: 0, green: 0, blue: 0, opacity: 0)
            return
        }

        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }

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

        "brightRed": AKSUColor.brightRed,
        "red": AKSUColor.red,
        "lightRed": AKSUColor.lightRed,

        "brightCyan": AKSUColor.brightCyan,
        "cyan": AKSUColor.cyan,
        "lightCyan": AKSUColor.lightCyan,

        "brightGreen": AKSUColor.brightGreen,
        "green": AKSUColor.green,
        "lightGreen": AKSUColor.lightGreen,

        "deeplime": AKSUColor.deepLime,
        "lime": AKSUColor.lime,
        "lightLime": AKSUColor.lightLime,

        "brightBlue": AKSUColor.brightBlue,
        "blue": AKSUColor.blue,
        "lightBlue": AKSUColor.lightBlue,

        "brightYellow": AKSUColor.brightYellow,
        "yellow": AKSUColor.yellow,
        "lightYellow": AKSUColor.lightYellow,

        "brightPink": AKSUColor.brightPink,
        "pink": AKSUColor.pink,
        "lightPink": AKSUColor.lightPink,

        "brightPurple": AKSUColor.brightPurple,
        "purple": AKSUColor.purple,
        "lightPurple": AKSUColor.lightPurple,
    ]

    let list = [
        "brightRed",
        "red",
        "lightRed",

        "brightCyan",
        "cyan",
        "lightCyan",

        "brightGreen",
        "green",
        "lightGreen",

        "deeplime",
        "lime",
        "lightLime",

        "brightBlue",
        "blue",
        "lightBlue",

        "brightYellow",
        "yellow",
        "lightYellow",

        "brightPink",
        "pink",
        "lightPink",

        "brightPurple",
        "purple",
        "lightPurple",

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
        "white",
        "gray",
        "black",
        "primary",
        "success",
        "warning",
        "danger",
    ]

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
