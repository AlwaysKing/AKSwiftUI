//
//  OutsideClickCheckView.swift
//  AKSwiftUI
//
//  Created by AlwaysKing on 2024/9/5.
//

import SwiftUI

struct AKSUOutsideClickCheckView<V: View>: View {
    @State var rect: CGRect = CGRect.zero

    @ViewBuilder let content: () -> V
    let outsideClick: (_ inside: Bool) -> Void
    @State var uuid: UUID = UUID()

    var body: some View {
        VStack {
            content()
        }
        .onAppear {
            MouseEventMonitor.start(uuid: uuid, filter: [.leftMouseDown, .rightMouseDown]) { location, _ in
                outsideClick(rect.contains(location))
                return false
            }
        }.onDisappear {
            MouseEventMonitor.stop(uuid: uuid)
        }
        .overlay {
            GeometryReader {
                g in
                Color.clear.onAppear {
                    rect = g.frame(in: .global)
                }
                .onChange(of: g.frame(in: .global)) { _ in
                    rect = g.frame(in: .global)
                }
            }
        }
    }
}

extension View {
    func onOutsideClick(click: @escaping (Bool) -> Void) -> some View {
        return AKSUOutsideClickCheckView(content: { self }, outsideClick: click)
    }
}
