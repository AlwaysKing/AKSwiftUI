//
//  AKSwiftUIApp.swift
//  AKSwiftUI
//
//  Created by alwaysking on 2024/8/29.
//

import SwiftUI

@main
struct AKSwiftUIApp: App {
    @State var ligth: Bool = true

    var body: some Scene {
        WindowGroup {
            ContentView(ligth: $ligth)
                .preferredColorScheme(ligth ? .light : .dark)
        }
    }
}
