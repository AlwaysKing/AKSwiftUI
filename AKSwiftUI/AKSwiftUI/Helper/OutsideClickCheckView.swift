//
//  OutsideClickCheckView.swift
//  AKSwiftUI
//
//  Created by AlwaysKing on 2024/9/5.
//

import SwiftUI

struct OutsideClickCheckView<V: View>: View {
    @State var tick: Bool = false
    @State var point: CGPoint = .zero

    @ViewBuilder let content: () -> V
    let outsideClick: (Bool) -> Void
    @State var uuid: UUID = UUID()

    var body: some View {
        VStack {
            content()
        }
        .onAppear {
            MouseEventMonitor.start(uuid: uuid, filter: [.leftMouseDown, .rightMouseDown]) { location, _ in
                point = location
                tick = true
                return false
            }
        }.onDisappear {
            MouseEventMonitor.stop(uuid: uuid)
        }
        .overlay {
            if tick {
                GeometryReader { g in
                    Color.clear.task {
                        if g.frame(in: .global).contains(point) {
                            outsideClick(true)
                        } else {
                            outsideClick(false)
                        }
                        tick = false
                    }
                }
            }
        }
    }
}

extension View {
    func onOutsideClick(click: @escaping (Bool) -> Void) -> some View {
        return OutsideClickCheckView(content: { self }, outsideClick: click)
    }
}

#Preview {
    OutsideClickCheckView {} outsideClick: { _ in }
}
