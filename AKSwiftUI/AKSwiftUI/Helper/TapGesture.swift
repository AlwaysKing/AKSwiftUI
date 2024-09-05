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
            return gesture(
                AKSUClickGesture()
                    .onEnded { location in
                        click(location)
                    }
            )
        }
    }
}

struct AKSUClickGesture: Gesture {
    let count: Int
    let coordinateSpace: CoordinateSpace

    typealias Value = SimultaneousGesture<TapGesture, DragGesture>.Value

    init(count: Int = 1, coordinateSpace: CoordinateSpace = .local) {
        precondition(count > 0, "Count must be greater than or equal to 1.")
        self.count = count
        self.coordinateSpace = coordinateSpace
    }

    var body: SimultaneousGesture<TapGesture, DragGesture> {
        SimultaneousGesture(
            TapGesture(count: count),
            DragGesture(minimumDistance: 0, coordinateSpace: coordinateSpace)
        )
    }

    func onEnded(perform action: @escaping (CGPoint) -> Void) -> _EndedGesture<AKSUClickGesture> {
        onEnded { (value: Value) in
            guard value.first != nil else { return }
            guard let location = value.second?.startLocation else { return }
            guard let endLocation = value.second?.location else { return }
            guard ((location.x-1)...(location.x+1)).contains(endLocation.x),
                  ((location.y-1)...(location.y+1)).contains(endLocation.y)
            else {
                return
            }
            action(location)
        }
    }
}
