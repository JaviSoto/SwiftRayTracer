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
                    Color3(
                        Double(x) / (Double(width - 1)),
                        Double(y) / (Double(height - 1)),
                        0.25
                    )
                }
            }
        , width: width)
}

private struct Scene {
    struct Parameters {
        var viewportHeight: Double = 2
        var focalLength: Double = 1
    }

    var parameters: Parameters = .init()

    private func rayColor(_ ray: Ray) -> Color3 {
        let normalizedDirection = ray.direction
        let t = 0.5 * (normalizedDirection.y + 1.0)
        return .init(1.0 - t) * Color3(1) + .init(t) * Color3(0.5, 0.7, 1.0)
    }

    func render(width: Int, height: Int) -> RayTracer.Image {
        // Camera
        let aspectRatio = Double(width) / Double(height)
        let viewportHeight = parameters.viewportHeight
        let viewportWidth = aspectRatio * viewportHeight
        let focalLength = parameters.focalLength

        let origin = Point3(0)
        let horizontal = Vec3(viewportWidth, 0, 0)
        let vertical = Vec3(0, viewportHeight, 0)
        let lowerLeftCorner = origin - horizontal / 2 - vertical / 2 - Vec3(0, 0, focalLength)

        // Render
        return Image(
            pixels:
                (0..<height).reversed().flatMap { y in
                    (0..<width).map { x in
                        let u = Vec3(Double(x) / Double(width - 1))
                        let v = Vec3(Double(y) / Double(height - 1))
                        let ray = Ray(origin: origin, direction: lowerLeftCorner + u * horizontal + v * vertical - origin)

                        return rayColor(ray)
                    }
                }
            , width: width)
    }
}

struct ContentView: View {
    @State
    private var scene: Scene = Scene()

    private var configurationView: some View {
        VStack {
            Form {
                VStack {
                    Text("Viewport Height: \(scene.parameters.viewportHeight, specifier: "%.1f")")
                        .lineLimit(1)
                    Slider(value: $scene.parameters.viewportHeight, in: -5...5, step: 0.1)
                }

                VStack {
                    Text("Focal Length: \(scene.parameters.focalLength, specifier: "%.1f")")
                        .lineLimit(1)
                    Slider(value: $scene.parameters.focalLength, in: -5...5, step: 0.1)
                }
            }
        }
    }

    var body: some View {
        HStack {
            GeometryReader { proxy in
                let width = Int(proxy.size.width)
                let height = Int(proxy.size.height)
                measure("\(width)x\(height) gradient") {
                    scene.render(width: width, height: height)
                        .render()
                }
            }

            configurationView
                .frame(width: 150)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
