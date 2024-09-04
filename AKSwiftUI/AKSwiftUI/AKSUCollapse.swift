//
//  AKSUCollapse.swift
//  AKSwiftUI
//
//  Created by alwaysking on 2024/9/2.
//

import SwiftUI

struct AKSUCollapse<K: Equatable, V: View>: View {
    @Binding var index: K
    let key: K

    @ViewBuilder var content: () -> V

    private var horizontal: Bool

    @State private var size: CGSize = CGSize(width: 0, height: 0)
    @State private var realSize: CGSize = CGSize(width: 0, height: 0)

    init(index: Binding<K>, key: K, horizontal: Bool = false, @ViewBuilder content: @escaping () -> V) {
        self._index = index
        self.key = key
        self.content = content
        self.horizontal = horizontal
    }

    var body: some View {
        ZStack {
            content()
                .overlay {
                    GeometryReader { geometry in
                        Color.clear.onAppear {
                            realSize = geometry.size
                        }
                    }
                }
        }
        .frame(width: size.width, height: size.height)
        .contentShape(Rectangle())
        .clipped()
        .onChange(of: realSize) { _ in
            let isExpaned = index == key
            size.width = !horizontal || isExpaned ? realSize.width : 0
            size.height = horizontal || isExpaned ? realSize.height : 0
        }
        .onChange(of: index) { _ in
            let isExpaned = index == key
            withAnimation {
                size.width = !horizontal || isExpaned ? realSize.width : 0
                size.height = horizontal || isExpaned ? realSize.height : 0
            }
        }
    }
}

extension AKSUCollapse where K == Bool {
    init(isExpaned: Binding<Bool>, horizontal: Bool = false, @ViewBuilder content: @escaping () -> V) {
        self._index = isExpaned
        self.key = true
        self.content = content
        self.horizontal = horizontal
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

                AKSUButton("D") {
                    isExpand.toggle()
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

                AKSUCollapse(isExpaned: $isExpand) {
                    VStack {
                    }
                    .frame(width: 100, height: 100).background(AKSUColor.danger)
                }
            }

            HStack {
                AKSUCollapse(index: $index, key: "A", horizontal: true) {
                    VStack {
                    }
                    .frame(width: 100, height: 100).background(AKSUColor.primary)
                }

                AKSUCollapse(index: $index, key: "B", horizontal: true) {
                    VStack {
                    }
                    .frame(width: 100, height: 100).background(AKSUColor.success)
                }

                AKSUCollapse(index: $index, key: "C", horizontal: true) {
                    VStack {
                    }
                    .frame(width: 100, height: 100).background(AKSUColor.warning)
                }

                AKSUCollapse(isExpaned: $isExpand, horizontal: true) {
                    VStack {
                    }
                    .frame(width: 100, height: 100).background(AKSUColor.danger)
                }
            }
        }
    }
}
