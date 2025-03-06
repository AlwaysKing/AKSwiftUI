//
//  AKSUStackView.swift
//  AKSwiftUI
//
//  Created by alwaysking on 2024/12/21.
//

import SwiftUI

enum AKSUStackStyle {
    case hstack
    case vstack
    case zstack
}

struct AKSUStackView<view: View>: View {
    var stack: AKSUStackStyle = .zstack
    var vAlignment: HorizontalAlignment = .center
    var hAlignment: VerticalAlignment = .center
    var zAlignment: Alignment = .center
    var spacing: CGFloat? = nil

    @ViewBuilder
    var content: () -> view

    var body: some View {
        if stack == .vstack {
            VStack(alignment: vAlignment, spacing: spacing) {
                content()
            }
        } else if stack == .hstack {
            HStack(alignment: hAlignment, spacing: spacing) {
                content()
            }
        } else if stack == .zstack {
            ZStack(alignment: zAlignment) {
                content()
            }
        }
    }
}

struct AKSULazyStackView<view: View>: View {
    var stack: AKSUStackStyle = .zstack
    var vAlignment: HorizontalAlignment = .center
    var hAlignment: VerticalAlignment = .center
    var zAlignment: Alignment = .center
    var spacing: CGFloat? = nil

    @ViewBuilder
    var content: () -> view

    var body: some View {
        if stack == .vstack {
            LazyVStack(alignment: vAlignment, spacing: spacing) {
                content()
            }
        } else if stack == .hstack {
            LazyHStack(alignment: hAlignment, spacing: spacing) {
                content()
            }
        } else if stack == .zstack {
            ZStack(alignment: zAlignment) {
                content()
            }
        }
    }
}

struct AKSUStack_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AKSUStackPreviewsView()
        }
        .frame(width: 1000, height: 600)
    }
}

struct AKSUStackPreviewsView: View {
    @State var stack: AKSUStackStyle = .hstack

    var body: some View {
        VStack {
            AKSUSegment(selected: $stack) {
                Text("VStack").AKSUSegmentTag(index: .vstack)
                Text("HStack").AKSUSegmentTag(index: .hstack)
                Text("ZStack").AKSUSegmentTag(index: .zstack)
            }
            .frame(width: 200)
            .padding()

            ZStack {
                AKSUStackView(stack: stack, spacing: 0) {
                    Text("1111").frame(width: 100, height: 100).background(.red)
                    Text("2222").frame(width: 100, height: 100).background(.green)
                    Text("3333").frame(width: 100, height: 100).background(.blue)
                }
            }.frame(width: 300, height: 300)
        }
    }
}
