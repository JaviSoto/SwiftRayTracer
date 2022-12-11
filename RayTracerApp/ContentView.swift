//
//  ContentView.swift
//  RayTracerApp
//
//  Created by Javier Soto on 12/11/22.
//

import SwiftUI
import RayTracer

private func gradient(width: Int, height: Int) -> RayTracer.Image {
    print("Creating \(width)x\(height) gradient")

    return Image(
        pixels:
            (0..<height).reversed().flatMap { y in
                (0..<width).map { x in
                    Vec3(
                        Double(x) / (Double(width - 1)),
                        Double(y) / (Double(height - 1)),
                        0.25
                    )
                }
            }
        , width: width)
}

struct ContentView: View {
    var body: some View {
        EmptyView()
            .overlay(GeometryReader { proxy in
                let width = Int(proxy.size.width)
                let height = Int(proxy.size.height)
                measure("\(width)x\(height) gradient") {
                    gradient(width: width, height: height)
                        .render()
                }
            })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
