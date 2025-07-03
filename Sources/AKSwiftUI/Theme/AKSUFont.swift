//
//  AKSUFont.swift
//  AKSwiftUI
//
//  Created by AlwaysKing on 2024/9/6.
//

import SwiftUI

// MARK: - 字体的定义
public class AKSUFont {
    public static let titleInt = 36.0
    public static let title2Int = 30.0
    public static let title3Int = 24.0
    public static let title4Int = 20.0
    public static let textInt = 16.0
    public static let secondaryTextInt = 12.0
    public static let lessTextInt = 10.0
    // 大小的定义
    public static let title = Font.system(size: titleInt)
    public static let title2 = Font.system(size: title2Int)
    public static let title3 = Font.system(size: title3Int)
    public  static let title4 = Font.system(size: title4Int)
    public static let text = Font.system(size: textInt)
    public static let secondaryText = Font.system(size: secondaryTextInt)
    public static let lessText = Font.system(size: lessTextInt)

    // 字重的定义 - 宽度
    public static let ultraLight = Font.Weight.ultraLight
    public static let thin = Font.Weight.thin
    public static let light = Font.Weight.light
    public static let regular = Font.Weight.regular
    public static let medium = Font.Weight.medium
    public static let semibold = Font.Weight.semibold
    public static let bold = Font.Weight.bold
    public static let heavy = Font.Weight.heavy
    public static let black = Font.Weight.black

//    static func register() -> Bool {
//        guard let robotoURL = Bundle.main.url(forResource: "Roboto", withExtension: "bundle") else { return false }
//        guard let roboto = Bundle(url: robotoURL) else { return false }
//
//        let fontURLs = [
//            roboto.url(forResource: "Roboto-Regular", withExtension: "ttf"),
//            roboto.url(forResource: "Roboto-Bold", withExtension: "ttf"),
//            roboto.url(forResource: "Roboto-Light", withExtension: "ttf")
//        ].compactMap { $0 }
//
//        for fontURL in fontURLs {
//            CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, nil)
//        }
//
//        return true
//    }
}

public extension Font {
    static let aksuTitle = AKSUFont.title
    static let aksuTitle2 = AKSUFont.title2
    static let aksuTitle3 = AKSUFont.title3
    static let aksuTitle4 = AKSUFont.title4
    static let aksuText = AKSUFont.text
    static let aksuSecondaryText = AKSUFont.secondaryText
    static let aksuLessText = AKSUFont.lessText
}

public extension Font.Weight {
    static let aksuUltraLight = Font.Weight.ultraLight
    static let aksuThin = Font.Weight.thin
    static let aksuLight = Font.Weight.light
    static let aksuRegular = Font.Weight.regular
    static let aksuMedium = Font.Weight.medium
    static let aksuSemibold = Font.Weight.semibold
    static let aksuBold = Font.Weight.bold
    static let aksuHeavy = Font.Weight.heavy
    static let aksuBlack = Font.Weight.black
}

struct AKSUFont_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AKSUFontPreviewsView()
        }
        .frame(width: 600, height: 600)
    }
}

struct AKSUFontPreviewsView: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("标题字体").font(AKSUFont.title).foregroundStyle(AKSUColor.title)
                Text("标题字体2").font(AKSUFont.title2).foregroundStyle(AKSUColor.title)
                Text("标题字体3").font(AKSUFont.title3).foregroundStyle(AKSUColor.title)
                Text("标题字体4").font(AKSUFont.title4).foregroundStyle(AKSUColor.title)

                Divider().frame(width: 200)

                VStack {
                    Text("这是ultraLight字体和字体颜色的演示").fontWeight(AKSUFont.ultraLight)
                    Text("这是thin字体和字体颜色的演示").fontWeight(AKSUFont.thin)
                    Text("这是light字体和字体颜色的演示").fontWeight(AKSUFont.light)
                    Text("这是regular字体和字体颜色的演示").fontWeight(AKSUFont.regular)
                    Text("这是medium字体和字体颜色的演示").fontWeight(AKSUFont.medium)
                    Text("这是semibold字体和字体颜色的演示").fontWeight(AKSUFont.semibold)
                    Text("这是bold字体和字体颜色的演示").fontWeight(AKSUFont.bold)
                    Text("这是heavy字体和字体颜色的演示").fontWeight(AKSUFont.heavy)
                    Text("这是black字体和字体颜色的演示").fontWeight(AKSUFont.black)
                }

                .font(AKSUFont.text)
                .foregroundStyle(AKSUColor.text)

                Text("这是secondaryText字体和字体颜色的演示").font(AKSUFont.secondaryText)
                    .foregroundStyle(AKSUColor.secondaryText)
                    .padding(.vertical)

                Text("这是lessText字体和字体颜色的演示")
                    .font(AKSUFont.lessText)
                    .foregroundStyle(AKSUColor.lessText)
                    .padding(.vertical)
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("系统字体 largeTitle").font(.largeTitle)
                Text("系统字体 title").font(.title)
                Text("系统字体 title2").font(.title2)
                Text("系统字体 title3").font(.title3)
                Text("系统字体 body").font(.body)
                Text("系统字体 headline").font(.headline)
                Text("系统字体 subheadline").font(.subheadline)
                Text("系统字体 callout").font(.callout)
                Text("系统字体 footnote").font(.footnote)
                Text("系统字体 caption").font(.caption)
                Text("系统字体 caption2").font(.caption2)

            }.padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
