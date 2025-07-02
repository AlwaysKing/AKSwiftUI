//
//  MainThread.swift
//  AKSwiftUI
//
//  Created by cnsinda on 2025/7/2.
//

import Foundation

func mainThreadSync<T>(action: () -> T) -> T {
    if Thread.isMainThread {
        return action()
    } else {
        return DispatchQueue.main.sync {
            action()
        }
    }
}
