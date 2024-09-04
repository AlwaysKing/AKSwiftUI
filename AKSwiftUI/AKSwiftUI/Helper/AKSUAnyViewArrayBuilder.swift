//
//  AKSUAnyViewArrayBuilder.swift
//  AKSwiftUI
//
//  Created by alwaysking on 2024/8/30.
// @https://github.com/diegolavalledev/swiftuilib-anyview-array-builder

import SwiftUI

@resultBuilder public enum AKSUAnyViewArrayBuilder {
    public static func buildBlock() -> [AnyView] {
        []
    }

    public static func buildBlock(_ components: AnyView...) -> [AnyView] {
        components
    }

    /// Allows for mixing of individual Views together with `ForEach` loops.
    ///
    /// Example:
    ///
    /// ```swift
    /// SomeView {
    ///   …
    ///   Text("") // Individual view
    ///   …
    ///   ForEach { … } // Multiple views
    ///   …
    /// }
    public static func buildBlock(_ components: [AnyView]...) -> [AnyView] {
        components.flatMap {
            $0
        }
    }

    public static func buildExpression<V: View>(_ expression: V) -> [AnyView] {
        [AnyView(expression)]
    }

    /// Allows for index-based `ForEach` loops.
    ///
    /// Example:
    ///
    /// ```swift
    /// SomeView {
    ///   …
    ///   ForEach(1 ..< 4) { index in
    ///     …
    ///   }
    ///   …
    /// }
    public static func buildExpression<V: View>(_ expression: ForEach<Range<Int>, Int, V>) -> [AnyView] {
        expression.data.map {
            AnyView(expression.content($0))
        }
    }

    public static func buildEither(first: [AnyView]) -> [AnyView] {
        return first
    }

    public static func buildEither(second: [AnyView]) -> [AnyView] {
        return second
    }

    public static func buildIf(_ element: [AnyView]?) -> [AnyView] {
        return element ?? []
    }
}
