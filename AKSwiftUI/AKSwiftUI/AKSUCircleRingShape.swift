//
//  AKSUCircleRingShape.swift
//  AKSwiftUI
//
//  Created by alwaysking on 2024/9/2.
//

import SwiftUI

struct AKSUCircleRingShape: Shape, Animatable {
    var progress: Double = 0.0
    var lineWidth: CGFloat = 8

    // 所有动画的中间值都会通过这个变量的set传递进来
    var animatableData: Double {
        get {
            return progress
        }
        set {
            progress = newValue
        }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        // 设置图形
        path.addArc(center: CGPoint(x: rect.width / 2.0, y: rect.height / 2.0), radius: min(rect.width, rect.height) / 2.0, startAngle: .degrees(-90.0), endAngle: .degrees(360 * progress - 90.0), clockwise: false)

        // 设置画笔
        return path.strokedPath(.init(lineWidth: lineWidth, lineCap: .round))
    }
}

struct AKSUCircleRingShape_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AKSUCircleRingShapePreviewsView()
        }
        .frame(width: 600, height: 600)
    }
}

struct AKSUCircleRingShapePreviewsView: View {
    @State var progress: CGFloat = 0
    @State var range: CGFloat = 0

    var body: some View {
        VStack {
            Text("\(range)")
            Text("\(progress)")
            ZStack {
                AKSUCircleRingShape(progress: progress)
                    .fill(AKSUColor.primary)
            }.frame(width: 100, height: 100).padding()
            ZStack {
                AKSUCircleRingShape(progress: progress, lineWidth: 20)
                    .fill(AKSUColor.primary)
            }.frame(width: 100, height: 100).padding()

            AKSURange(progress: $range)
                .onChange(of: range) { _ in
                    progress = range / 100
                }
        }
    }
}
