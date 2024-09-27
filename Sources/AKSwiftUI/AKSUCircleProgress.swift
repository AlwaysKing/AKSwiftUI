//
//  AKSUCircleProgress.swift
//  AKSwiftUI
//
//  Created by alwaysking on 2024/9/2.
//

import SwiftUI

public struct AKSUCircleProgress: View {
    @Environment(\.self) var environment
    @Environment(\.isEnabled) private var isEnabled
    var progress: CGFloat
    let actionColor: Color
    let bgColor: Color
    var size: CGFloat
    var lineWidth: CGFloat

    public init(progress: CGFloat, size: CGFloat = 60.0, lineWidth: CGFloat = 10.0, actionColor: Color = AKSUColor.primary, bgColor: Color = AKSUColor.dyGrayBG) {
        self.progress = progress
        self.size = size
        self.lineWidth = lineWidth
        self.actionColor = actionColor
        self.bgColor = bgColor
    }

    public var body: some View {
        ZStack {
            AKSUCircleRingShape(progress: 1.0, lineWidth: lineWidth)
                .fill(bgColor)
            AKSUCircleRingShape(progress: progress, lineWidth: lineWidth)
                .fill(isEnabled ? actionColor : actionColor.merge(up: AKSUColor.dyGrayMask, mode: environment))
        }.frame(width: size, height: size)
    }
}

struct AKSUCircleProgress_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AKSUCircleProgressPreviewsView()
        }
        .frame(width: 600, height: 600)
    }
}

struct AKSUCircleProgressPreviewsView: View {
    @State var progress: CGFloat = 0
    @State var range: CGFloat = 0

    var body: some View {
        VStack {
            Text("\(range)")
            Text("\(progress)")
            AKSUCircleProgress(progress: progress, size: 200, lineWidth: 20)
                .padding()

            AKSUCircleProgress(progress: progress, size: 100)
                .padding()

            AKSURange(progress: $range)
                .onChange(of: range) { _ in
                    progress = range / 100
                }
        }
    }
}
