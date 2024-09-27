//
//  AKSUCollapse.swift
//  AKSwiftUI
//
//  Created by alwaysking on 2024/9/2.
//

import SwiftUI

public struct AKSUCollapse<K: Equatable, V: View>: View {
    @Binding var index: K
    let key: K

    @ViewBuilder var content: () -> V

    private var maxWidth: Bool = false
    private var maxHeight: Bool = false
    private var horizontal: Bool
    private var vertical: Bool

    @State var isExpaned: Bool = false
    @State private var size: CGSize = CGSize(width: 0, height: 0)

    public init(index: Binding<K>, key: K, vertical: Bool = true, horizontal: Bool = false, maxWidth: Bool = false, maxHeight: Bool = false, @ViewBuilder content: @escaping () -> V) {
        self._index = index
        self.key = key
        self.content = content
        self.horizontal = horizontal
        self.vertical = vertical
        self.maxWidth = maxWidth
        self.maxHeight = maxHeight
    }

    public var body: some View {
        ZStack {
            content()
                .overlay {
                    GeometryReader { geometry in
                        Color.clear.task {
                            size = geometry.size
                        }
                    }
                }
        }
        .frame(width: maxWidth ? nil : (size.width == 0 ? nil : (isExpaned || !horizontal ? size.width : 0)), height: maxHeight ? nil : (size.height == 0 ? nil : (isExpaned || !vertical ? size.height : 0)))
        .frame(maxWidth: maxWidth ? (isExpaned || !horizontal ? .infinity : 0) : nil, maxHeight: maxHeight ? (isExpaned || !vertical ? .infinity : 0) : nil)
        .contentShape(Rectangle())
        .clipped()
        .onChange(of: size) { _ in
            isExpaned = index == key
        }
        .onChange(of: index) { _ in
            withAnimation {
                isExpaned = index == key
            }
        }
    }
}

public extension AKSUCollapse where K == Bool {
    init(isExpaned: Binding<Bool>, vertical: Bool = true, horizontal: Bool = false, maxWidth: Bool = false, maxHeight: Bool = false, @ViewBuilder content: @escaping () -> V) {
        self._index = isExpaned
        self.key = true
        self.content = content
        self.horizontal = horizontal
        self.vertical = vertical
        self.maxWidth = maxWidth
        self.maxHeight = maxHeight
    }
}

struct AKSUCollapse_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AKSUCollapsePreviewsView()
        }
        .frame(width: 600, height: 600)
    }
}

struct AKSUCollapsePreviewsView: View {
    @State var isExpand: Bool = false

    @State var index: String = "A"

    var body: some View {
        HStack {
            VStack {
                HStack {
                    AKSUButton("A") {
                        index = "A"
                    }.padding(.top)
                    AKSUButton("B") {
                        index = "B"
                    }.padding(.top)
                    AKSUButton("C") {
                        index = "C"
                    }.padding(.top)
                }

                VStack {
                    AKSUCollapse(index: $index, key: "A") {
                        VStack {
                        }
                        .frame(width: 100, height: 100).background(AKSUColor.primary)
                    }

                    AKSUCollapse(index: $index, key: "B") {
                        VStack {
                        }
                        .frame(width: 100, height: 100).background(AKSUColor.success)
                    }

                    AKSUCollapse(index: $index, key: "C") {
                        VStack {
                        }
                        .frame(width: 100, height: 100).background(AKSUColor.warning)
                    }
                }

                HStack {
                    AKSUCollapse(index: $index, key: "A", vertical: false, horizontal: true) {
                        VStack {
                        }
                        .frame(width: 100, height: 100).background(AKSUColor.primary)
                    }

                    AKSUCollapse(index: $index, key: "B", vertical: false, horizontal: true) {
                        VStack {
                        }
                        .frame(width: 100, height: 100).background(AKSUColor.success)
                    }

                    AKSUCollapse(index: $index, key: "C", vertical: false, horizontal: true) {
                        VStack {
                        }
                        .frame(width: 100, height: 100).background(AKSUColor.warning)
                    }
                }

                HStack {
                    AKSUCollapse(index: $index, key: "A", vertical: true, horizontal: true) {
                        VStack {
                        }
                        .frame(width: 100, height: 100).background(AKSUColor.primary)
                    }

                    AKSUCollapse(index: $index, key: "B", vertical: true, horizontal: true) {
                        VStack {
                        }
                        .frame(width: 100, height: 100).background(AKSUColor.success)
                    }

                    AKSUCollapse(index: $index, key: "C", vertical: true, horizontal: true) {
                        VStack {
                        }
                        .frame(width: 100, height: 100).background(AKSUColor.warning)
                    }
                }
            }

            VStack {
                AKSUButton("MAX") {
                    isExpand.toggle()
                }.padding(.top)

                ZStack {
                    AKSUCollapse(isExpaned: $isExpand, maxHeight: true) {
                        VStack {
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(AKSUColor.primary)
                    }
                }.frame(maxWidth: 200)
                Spacer()
            }
        }
    }
}
