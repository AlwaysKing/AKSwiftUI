//
//  AKSUStepAnimationView.swift
//  demo
//
//  Created by AlwaysKing on 2024/9/5.
//

import SwiftUI

public struct AKSUStepAnimationView<V: View, K: VectorArithmetic>: View {
    var from: K
    var to: K
    @Binding var play: Bool
    @ViewBuilder let content: (K) -> V
    @State var playing: Bool = false
    @State var continuePlaying: Bool = false

    public init(play: Binding<Bool>, from: K, to: K, content: @escaping (K) -> V) {
        self.from = from
        self.to = to
        self.content = content
        self._play = play
    }

    public var body: some View {
        VStack {
            AKSUStepAnimation(playing ? to : from, content: content) {
                DispatchQueue.main.async {
                    playing = continuePlaying
                }
            }
            .animation(playing ? .linear(duration: 1).repeatForever(autoreverses: false) : .default, value: playing)
            .onChange(of: play) { _ in
                if play {
                    playing = true
                    continuePlaying = true
                } else {
                    continuePlaying = false
                }
            }
        }
    }
}

public struct AKSUStepAnimation<V: View, K: VectorArithmetic>: Animatable, View {
    var value: K

    @ViewBuilder let content: (K) -> V
    let finish: () -> Void

    public init(_ value: K, content: @escaping (K) -> V, finish: @escaping () -> Void) {
        self.value = value
        self.content = content
        self.finish = finish
    }

    public var animatableData: K {
        get {
            return value
        }
        set {
            if newValue == value {
                finish()
            }
            value = newValue
        }
    }

    public var body: some View {
        content(value)
    }
}
