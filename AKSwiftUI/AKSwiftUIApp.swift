//
//  AKSwiftUIApp.swift
//  AKSwiftUI
//
//  Created by alwaysking on 2024/8/29.
//

import SwiftUI

@main
struct AKSwiftUIApp: App {
    @State var light: Bool = true

    var body: some Scene {
        WindowGroup {
            if #available(macOS 14, *) {
                SplitWndContentView(light: $light)
                    .preferredColorScheme(light ? .light : .dark)
                    .onAppear {
                        AKSUToast.setColorScheme(light ? .light : .dark)
                    }
                    .onChange(of: light) { _ in
                        AKSUToast.setColorScheme(light ? .light : .dark)
                        AKSUToast.changeColorScheme(light ? .light : .dark)
                    }
            } else {
                SpliteContentView(light: $light)
                    .preferredColorScheme(light ? .light : .dark)
                    .onAppear {
                        AKSUToast.setColorScheme(light ? .light : .dark)
                    }
                    .onChange(of: light) { _ in
                        AKSUToast.setColorScheme(light ? .light : .dark)
                        AKSUToast.changeColorScheme(light ? .light : .dark)
                    }
            }
        }
    }
}
