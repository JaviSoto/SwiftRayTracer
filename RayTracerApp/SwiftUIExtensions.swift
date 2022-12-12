//
//  SwiftUIExtensions.swift
//  RayTracerApp
//
//  Created by Javier Soto on 12/11/22.
//

import SwiftUI

private struct ViewSizePreferenceKey: PreferenceKey {
    typealias Value = CGSize

    static var defaultValue: Value = .init(width: 10, height: 10)

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = nextValue()
    }
}

extension View {
    func onSizeChange(_ f: @escaping (CGSize) -> Void) -> some View {
        GeometryReader { geometry in
            self
                .preference(
                    key: ViewSizePreferenceKey.self,
                    value: geometry.size
                )
        }
        .onPreferenceChange(ViewSizePreferenceKey.self, perform: f)
    }
}
