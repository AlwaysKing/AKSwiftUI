//
//  AKSUGrid.swift
//  AKSwiftUI
//
//  Created by alwaysking on 2024/9/2.
//

import SwiftUI

public struct AKSUGrid<V: View>: View {
    let columns: [GridItem]
    let alignment: HorizontalAlignment
    let spacing: CGFloat?
    let pinnedViews: PinnedScrollableViews

    @ViewBuilder let content: () -> V

    public init(count: Int? = nil, fixed: CGFloat? = nil, min: CGFloat = 10, max: CGFloat = .infinity, itemSpacing: CGFloat? = nil, itemAligment: Alignment? = nil, alignment: HorizontalAlignment = .center, spacing: CGFloat? = nil, pinnedViews: PinnedScrollableViews = .init(), @ViewBuilder content: @escaping () -> V)
    {
        self.alignment = alignment
        self.spacing = spacing
        self.pinnedViews = pinnedViews
        self.content = content

        if let count = count {
            if let fixed = fixed {
                columns = Array(repeating: GridItem(.fixed(fixed), spacing: itemSpacing, alignment: itemAligment), count: count)
            } else {
                columns = Array(repeating: GridItem(.flexible(minimum: min, maximum: max), spacing: itemSpacing, alignment: itemAligment), count: count)
            }
        } else {
            columns = [GridItem(.adaptive(minimum: CGFloat(min), maximum: max), spacing: itemSpacing, alignment: itemAligment)]
        }
    }

    public var body: some View {
        LazyVGrid(columns: columns, alignment: alignment, spacing: spacing, pinnedViews: pinnedViews) {
            content()
        }
    }
}

struct AKSUGrid_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AKSUGridPreviewsView()
        }
        .frame(width: 600, height: 600)
    }
}

struct AKSUGridPreviewsView: View {
    @State var count: CGFloat = 5

    @State var item: CGFloat = 30

    @State var width: CGFloat = 200

    var body: some View {
        VStack {
            HStack {
                Text("数量: \(Int(count))")
                AKSURange(step: 1, min: 1, max: 20, progress: $count)
            }
            .padding()

            HStack {
                Text("Item: \(Int(item))")
                AKSURange(step: 1, min: 20, max: 60, progress: $item)
            }
            .padding()

            HStack {
                Text("Width: \(Int(width))")
                AKSURange(step: 1, min: 100, max: 400, progress: $width)
            }
            .padding()

            VStack {
                Text("fixed")
                AKSUGrid(count: 4, fixed: 40) {
                    ForEach(Array(0 ... Int(count)), id: \.self) {
                        index in
                        VStack {
                        }
                        .frame(width: item, height: 10)
                        .background(.aksuPrimary)
                    }
                }

                Divider()

                Text("flexible")
                AKSUGrid(count: 4, min: 40) {
                    ForEach(Array(0 ... Int(count)), id: \.self) {
                        index in
                        VStack {
                        }
                        .frame(width: item, height: 10)
                        .background(.aksuPrimary)
                    }
                }

                Divider()
                Text("adaptive")
                AKSUGrid(min: 40) {
                    ForEach(Array(0 ... Int(count)), id: \.self) {
                        index in
                        VStack {
                        }
                        .frame(width: item, height: 10)
                        .background(.aksuSuccess)
                    }
                }

                Divider()

            }.frame(width: width)
        }
    }
}
