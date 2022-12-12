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

extension Slider where ValueLabel == EmptyView {
    init(javivalue value: Binding<Int>, in bounds: ClosedRange<Int>, step: Int, label: () -> Label) {
        self.init(
            value: Binding(get: { Double(value.wrappedValue) }, set: { value.wrappedValue = Int($0) }),
            in: Double(bounds.lowerBound)...Double(bounds.upperBound),
            step: Double(step),
            label: label
        )
    }
}
