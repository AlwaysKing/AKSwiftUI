//
//  AKSUProgress.swift
//  AKSwiftUI
//
//  Created by alwaysking on 2024/9/2.
//

import SwiftUI

public struct AKSUProgress: View {
    @Environment(\.self) var environment
    @Environment(\.isEnabled) private var isEnabled

    public var progress: CGFloat

    public let color: Color
    public let actionColor: Color

    public var hiddenLabel: Bool
    public var height: CGFloat

    @State private var width: CGFloat = 0.0
    @State private var titleWidth: CGFloat = 0.0

    public init(progress: CGFloat, color: Color = .aksuWhite, actionColor: Color = .aksuPrimary, hiddenLabel: Bool = false, height: CGFloat = 20.0) {
        self.progress = progress
        self.color = color
        self.actionColor = actionColor
        self.hiddenLabel = hiddenLabel
        self.height = height
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                HStack {
                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(actionColor)
                        .frame(width: computerOffset())
                    Spacer()
                }
                .frame(alignment: .leading)

                if !hiddenLabel {
                    HStack(spacing: 0) {
                        HStack {
                            Text(progressString()).foregroundColor(.aksuWhite)
                                .overlay {
                                    GeometryReader { geometry in
                                        Color.clear.task {
                                            titleWidth = geometry.size.width
                                        }
                                        .onChange(of: progress) { _ in
                                            titleWidth = geometry.size.width
                                        }
                                    }
                                }
                                .padding(.leading, titlePadding())
                        }
                        .frame(width: computerOffset(), alignment: .leading)
                        Spacer()
                    }
                }
            }
            .overlay {
                if !isEnabled {
                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(.aksuGrayMask)
                }
            }
            .onAppear {
                width = geometry.size.width
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .background {
            RoundedRectangle(cornerRadius: height / 2)
                .fill(.aksuGrayBackground)
        }
    }

    func computerOffset() -> CGFloat {
        return max(height, progress * width)
    }

    func titlePadding() -> CGFloat {
        let halfPadding = (computerOffset() - titleWidth) / 2
        if halfPadding < height / 2 {
            return halfPadding
        } else {
            return computerOffset() - titleWidth - height / 2
        }
    }

    func progressString() -> String {
        return "\(Int(progress * 100))"
    }
}

struct AKSUProgress_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AKSUProgressPreviewsView()
        }
        .frame(width: 600, height: 600)
    }
}

struct AKSUProgressPreviewsView: View {
    @State var progress: CGFloat = 0
    @State var range: CGFloat = 0

    var body: some View {
        VStack {
            Text("\(range)")
            Text("\(progress)")

            AKSUProgress(progress: progress, hiddenLabel: true, height: 5)
                .frame(width: 300)
                .padding()

            AKSUProgress(progress: progress)
                .frame(width: 300)
                .padding()

            AKSUProgress(progress: progress, height: 60)
                .frame(width: 300)
                .padding()

            AKSURange(progress: $range)
                .onChange(of: range) { _ in
                    progress = range / 100
                }
        }
    }
}
