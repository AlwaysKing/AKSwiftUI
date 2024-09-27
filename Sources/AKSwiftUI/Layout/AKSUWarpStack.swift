//
//  AKSUWarpStack.swift
//  AKSwiftUI
//
//  Created by AlwaysKing on 2024/9/14.
//

import SwiftUI

public class AKSUWarpStackReader: ObservableObject {
    @Published public var local: CGRect? = nil
    @Published public var global: CGRect? = nil
    @Published public var window: NSWindow? = nil
}

public struct AKSUWarpStack<view: View>: View {
    @ViewBuilder public let content: (_ reader: AKSUWarpStackReader) -> view
    @State var reader: AKSUWarpStackReader = AKSUWarpStackReader()

    public init(content: @escaping (_: AKSUWarpStackReader) -> view) {
        self.content = content
    }

    public var body: some View {
        ZStack {
            content(reader)
        }.background {
            GeometryReader {
                g in
                ZStack {
                    AKSUWindowAccessor {
                        window in
                        reader.window = window
                    }
                    Color.clear.onAppear {
                        reader.global = g.frame(in: .global)
                        reader.local = g.frame(in: .local)
                    }.onChange(of: g.frame(in: .global)) { _ in
                        reader.global = g.frame(in: .global)
                    }.onChange(of: g.frame(in: .local)) { _ in
                        reader.local = g.frame(in: .local)
                    }
                }
            }
        }
    }
}

#Preview {
    AKSUWarpStack { reader in
        VStack {
        }
    }
}
