//
//  AKSUPinView.swift
//  AKSwiftUI
//
//  Created by AlwaysKing on 2024/9/30.
//

import SwiftUI

public struct AKSUInputPin: View {
    @Environment(\.isEnabled) private var isEnabled
    let count: Int
    let width: CGFloat
    let height: CGFloat
    let spacing: CGFloat?
    let fontSize: CGFloat
    let onlyNumber: Bool
    let finish: (_ pin: String) -> Void
    let color: Color
    let bgColor: Color?
    let boardColor: Color?
    let actionColor: Color

    let filter: ((Character) -> Character?)?

    @State private var code: [String]

    @FocusState private var focusedField: Int?

    @Namespace var pinAnimation

    @State var selected: Int

    public init(count: Int, onlyNumber: Bool = false, color: Color = .aksuText, actionColor: Color = .aksuPrimary, bgColor: Color? = .aksuGrayLessBackground, boardColor: Color? = .aksuBoard, width: CGFloat = 40, height: CGFloat = 40, spacing: CGFloat? = nil, fontSize: CGFloat = 28, filter: ((Character) -> Character?)? = nil, finish: @escaping (_ pin: String) -> Void) {
        self.count = count
        self.code = [String](repeating: "", count: count)
        self.width = width
        self.height = height
        self.spacing = spacing
        self.fontSize = fontSize
        self.onlyNumber = onlyNumber
        self.finish = finish
        self.selected = 0
        self.color = color
        self.actionColor = actionColor
        self.bgColor = bgColor
        self.boardColor = boardColor
        self.filter = filter
        self.focusedField = 0
    }

    public var body: some View {
        HStack(spacing: spacing) {
            ForEach(0 ..< count, id: \.self) { index in

                ZStack {
                    Text(code[index])
                        .font(.system(size: fontSize)) // Set font size
                        .foregroundColor(color)

                    AKSUKeyPressMonitor { event in
                        if !isEnabled {
                            return
                        }
                        if let input = inputVaild(event) {
                            code[index] = input
                            focusedField = index + 1
                            for item in code {
                                if item == "" {
                                    return
                                }
                            }
                            finish(code.joined())
                        } else {
                            switch event.keyCode {
                            case 126:
                                if index != 0 {
                                    focusedField = index - 1
                                }
                            case 125:
                                if index != count - 1 {
                                    focusedField = index + 1
                                }
                            case 123:
                                if index != 0 {
                                    focusedField = index - 1
                                }
                            case 124:
                                if index != count - 1 {
                                    focusedField = index + 1
                                }
                            case 51:
                                code[index] = ""
                                if index != 0 {
                                    focusedField = index - 1
                                }
                            case 117:
                                code[index] = ""
                            default: break
                            }
                        }
                    }
                    .focusable()
                    .focused($focusedField, equals: index)
                }
                .frame(width: width, height: height)
                .background(bgColor)
                .cornerRadius(AKSUAppearance.cornerRadius)
                .overlay {
                    if let boardColor = boardColor {
                        RoundedRectangle(cornerRadius: AKSUAppearance.cornerRadius)
                            .stroke(boardColor, lineWidth: 1)
                    }
                }
                .overlay {
                    if selected == index {
                        RoundedRectangle(cornerRadius: AKSUAppearance.cornerRadius)
                            .stroke(actionColor, lineWidth: 2)
                            .matchedGeometryEffect(id: "AKSUInputPin", in: self.pinAnimation)
                    }
                }

                .onTapGesture {
                    focusedField = index
                }
            }
        }
        .onChange(of: focusedField) { _ in
            withAnimation(.linear(duration: 0.2)) {
                selected = focusedField ?? 0
            }
        }
        .onAppear {
            focusedField = 0
        }
    }

    func inputVaild(_ event: NSEvent) -> String? {
        if let character = event.characters?.first {
            if let filter = filter {
                if let result = filter(character) {
                    return String(result)
                }
            } else {
                if character.isNumber {
                    return String(character)
                } else if character.isLetter {
                    if onlyNumber {
                        return nil
                    }
                    return String(character)
                } else {
                    return nil
                }
            }
        }

        return nil
    }
}

struct AKSUInputPin_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AKSUInputPinPreviewsView()
        }
        .frame(width: 600, height: 600)
    }
}

struct AKSUInputPinPreviewsView: View {
    @State var finish: String = ""

    var body: some View {
        VStack {
            Text("pin: \(finish)")
            AKSUInputPin(count: 4) { pin in
                finish = pin
            }

            Text("upper: \(finish)")
            AKSUInputPin(count: 4) { input in
                if input.isLetter {
                    return input.uppercased().first
                }
                return nil
            } finish: { pin in
                finish = pin
            }
        }
    }
}
