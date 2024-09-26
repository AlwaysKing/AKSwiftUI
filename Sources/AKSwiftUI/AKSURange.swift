//
//  AKSURange.swift
//  AKSwiftUI
//
//  Created by alwaysking on 2024/9/2.
//

import SwiftUI

enum AKSURangeStyle {
    case fat
    case slim
}

struct AKSURange: View {
    @Environment(\.self) var environment
    @Environment(\.isEnabled) private var isEnabled

    let color: Color
    let actionColor: Color

    var step: CGFloat? = nil
    let minCount: CGFloat
    let maxCount: CGFloat

    let height: CGFloat

    let style: AKSURangeStyle
    @Binding private var progress: CGFloat
    @State private var width: CGFloat = 0.0

    init(style: AKSURangeStyle = .fat, step: CGFloat? = nil, min: CGFloat = 0, max: CGFloat = 100, progress: Binding<CGFloat>, color: Color = .white, actionColor: Color = AKSUColor.primary, height: CGFloat = 20.0) {
        if let step = step {
            if step >= 0 {
                self.step = Swift.min(step, max - min)
            }
        }
        self.minCount = min
        self.maxCount = max
        self.height = height
        self._progress = progress
        self.color = color
        self.actionColor = actionColor
        self.style = style
        DispatchQueue.main.async { [self] in
            if self.progress < minCount {
                self.progress = minCount
            } else if self.progress > maxCount {
                self.progress = maxCount
            }
        }
    }

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerSize: CGSize(width: height, height: height))
                .fill(AKSUColor.dyGrayBG)
                .frame(height: style == .fat ? nil : height / 2)

            RoundedRectangle(cornerSize: CGSize(width: height, height: height))
                .fill(isEnabled ? actionColor : actionColor.merge(up: AKSUColor.dyGrayMask, mode: environment))
                .frame(width: max(height, computerOffset(progress: progress) + height / 2 - 2))
                .frame(height: style == .fat ? nil : height / 2)

            Circle()
                .offset(x: computerOffset(progress: progress) - (width / 2))
                .foregroundColor(isEnabled ? color : color.merge(up: AKSUColor.dyGrayMask, mode: environment))
        }
        .overlay {
            GeometryReader { geometry in
                Color.clear.task {
                    width = geometry.size.width
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: height)
        .background(.white.opacity(0.01))
        .onTapGestureLocation { location in
            computerProgress(x: location.x)
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    computerProgress(x: value.location.x)
                }
        )
    }

    func computerOffset(progress: CGFloat) -> CGFloat {
        let newWidth = width - height
        return ((progress - minCount) / (maxCount - minCount)) * newWidth + height / 2
    }

    func computerProgress(x: CGFloat) {
        let newOffset = x - height / 2
        if newOffset <= 0 {
            progress = minCount
            return
        }
        let newWidth = width - height
        progress = min(newOffset / newWidth * (maxCount - minCount) + minCount, maxCount)
        if let step = step {
            progress = trunc((progress - minCount) / step) * step + minCount
        }
    }

    func computerProgress(progress: CGFloat) {
        self.progress = progress
    }

    func pointSize(width: CGFloat, height: CGFloat) -> CGFloat {
        guard let step = step else { return 0 }
        let spaceCount = Int((maxCount - minCount) / step)
        let maxHeight = width / CGFloat(spaceCount) / 2
        let size = height / 1.4
        return min(maxHeight, size)
    }
}

struct AKSURange_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AKSURangePreviewsView()
        }
        .frame(width: 600, height: 600)
    }
}

struct AKSURangePreviewsView: View {
    @State var progress: CGFloat = 0

    var body: some View {
        VStack {
            Text("\(progress)")
            AKSURange(min: 0, max: 100, progress: $progress)
                .frame(width: 300)
                .padding()

            AKSURange(style: .slim, step: 10, min: 0, max: 100, progress: $progress)
                .frame(width: 300)
                .padding()

            AKSURange(step: 10, min: 0, max: 100, progress: $progress, height: 40)
                .frame(width: 300)
                .padding()

            AKSURange(style: .slim, step: 10, min: 0, max: 100, progress: $progress, height: 40)
                .frame(width: 300)
                .padding()
        }
    }
}
