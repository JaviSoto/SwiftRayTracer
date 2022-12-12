//
//  SwiftUIExtensions.swift
//  RayTracerApp
//
//  Created by Javier Soto on 12/11/22.
//

import SwiftUI
import RayTracer

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

struct ValueSlider: View {
    var name: String
    @Binding
    var value: Double
    var range: ClosedRange<Double>
    var step: Double
    var decimalPoints = 1
    var unit: String = ""

    var body: some View {
        Slider(value: $value, in: range, step: step) {
            Text("\(name): \(value, specifier: "%.\(decimalPoints)f")\(unit)")
                .lineLimit(1)
        }
    }
}

struct Vec3Sliders: View {
    var name: String
    @Binding
    var vector: Vec3
    var range: ClosedRange<Double>
    var step: Double

    var body: some View {
        Text("\(name):")

        Slider(value: $vector.x, in: range, step: step) {
            Text("x: \(vector.x, specifier: "%.1f")")
        }
        Slider(value: $vector.y, in: range, step: step) {
            Text("y: \(vector.y, specifier: "%.1f")")
        }
        Slider(value: $vector.z, in: range, step: step) {
            Text("z: \(vector.z, specifier: "%.1f")")
        }
    }
}
