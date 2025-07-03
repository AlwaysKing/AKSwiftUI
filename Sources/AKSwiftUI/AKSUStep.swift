//
//  AKSUStep.swift
//  AKSwiftUI
//
//  Created by AlwaysKing on 2024/9/30.
//

import SwiftUI

public struct AKSUStep: View {
    let count: Int
    let size: CGFloat
    let label: [String]?
    let color: Color
    let actionColor: Color
    @Binding var step: Int
    @State var width: CGFloat = 0.0
    @State var hovering: Bool = false
    
    @Environment(\.isEnabled) private var isEnabled

    public init(count: Int, label: [String]? = nil, color: Color = .aksuBoard, actionColor: Color = .aksuPrimary, size: CGFloat = 30, step: Binding<Int>) {
        self.count = count
        self._step = step
        self.size = size
        self.label = label
        self.color = color
        self.actionColor = actionColor
    }

    public var body: some View {
        HStack {
            ForEach(0 ..< count, id: \.self) {
                index in

                ZStack {
                    Text("\(index)")
                        .font(.system(size: size / 2))
                        .foregroundColor(getColor(index))
                }
                .frame(width: size, height: size)
                .background {
                    Circle()
                        .stroke(getColor(index), lineWidth: 2)
                }
                .overlay {
                    if let info = label?[index] {
                        Text(info)
                            .font(.system(size: size / 2))
                            .foregroundColor(getColor(index))
                            .frame(width: (width / max(1.0, CGFloat(count))) * 2.0)
                            .offset(y: size / 2 + 20)
                    }
                }
                .background(.white.opacity(0.001))
                .onHover {
                    if $0 {
                        NSCursor.pointingHand.push()
                    } else {
                        NSCursor.pop()
                    }
                }
                .onTapGesture {
                    if !isEnabled {
                        return
                    }
                    step = index
                }

                if index != count - 1 {
                    HStack {
                        Spacer()
                    }
                    .frame(height: 2)
                    .background(getColor(index + 1))
                    .padding(5)
                }
            }
        }
        .background {
            GeometryReader {
                g in
                Color.clear
                    .onAppear {
                        width = g.size.width
                    }
                    .onChange(of: g.size.width) { _ in
                        width = g.size.width
                    }
            }
        }
    }

    func getColor(_ index: Int) -> Color {
        if index <= step {
            return actionColor
        }
        return color
    }
}

struct AKSUStepPin_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AKSUStepPreviewsView().padding()
        }
        .frame(width: 600, height: 600)
    }
}

struct AKSUStepPreviewsView: View {
    @State var step: Int = 0

    var body: some View {
        VStack {
            AKSUStep(count: 6, label: ["第一步", "第二部", "第三部", "第四部", "第五部", "第六部"], step: $step)

            HStack {
                AKSUButton("<") {
                    step = max(0, step - 1)
                }

                AKSUButton(">") {
                    step = min(5, step + 1)
                }
            }.padding(.top, 100)
        }
    }
}
