//
//  TapGesture.swift
//  AKSwiftUI
//
//  Created by AlwaysKing on 2024/9/4.
//

import SwiftUI

extension View {
    func onTapGestureLocation(click: @escaping (CGPoint) -> Void) -> some View {
        if #available(macOS 13, *) {
            return self.onTapGesture(count: 1) { location in
                click(location)
            }
        } else {
            return gesture(DragGesture().onEnded { location in
                click(location.location)
            })
        }
    }
}
