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

        var sphereCenter: Point3 = .init(x: 0, y: 0, z: -1)
        var sphereRadius: Double = 0.5
    }

    var parameters: Parameters = .init()

    private func rayColor(_ ray: Ray) -> Color3 {
        let sphere = Sphere(center: parameters.sphereCenter, radius: parameters.sphereRadius)

        if let sphereHit = sphere.hitTest(with: ray, validTRange: 0.0...(.greatestFiniteMagnitude)) {
            if sphereHit.t > 0 {
                let n: Vec3 = (sphereHit.point - Vec3(0, 0, -1)).normalized()
                return 0.5 * Color3(n.x + 1, n.y + 1, n.z + 1)
            }
        }

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
        Form {
            HStack(alignment: .top) {
                VStack {
                    Text("Parameters")
                        .font(.largeTitle)

                    Section(header: Text("Viewport").fontWeight(.bold)) {
                        Slider(value: $scene.parameters.viewportHeight, in: -5...5, step: 0.1) {
                            Text("Height: \(scene.parameters.viewportHeight, specifier: "%.1f")")
                                .lineLimit(1)
                        }

                        Slider(value: $scene.parameters.focalLength, in: -5...5, step: 0.1) {
                            Text("Focal Length: \(scene.parameters.focalLength, specifier: "%.1f")")
                                .lineLimit(1)
                        }
                    }

                    Divider()

                    Section(header: Text("Sphere:").fontWeight(.bold)) {
                        VStack {
                            Text("Position: (\(scene.parameters.sphereCenter.x, specifier: "%.1f"), \(scene.parameters.sphereCenter.y, specifier: "%.1f"), \(scene.parameters.sphereCenter.z, specifier: "%.1f"))")
                                .lineLimit(1)
                            Slider(value: $scene.parameters.sphereCenter.x, in: -10...10, step: 0.1) {
                                Text("x: ")
                            }
                            Slider(value: $scene.parameters.sphereCenter.y, in: -10...10, step: 0.1) {
                                Text("y: ")
                            }
                            Slider(value: $scene.parameters.sphereCenter.z, in: -10...10, step: 0.1) {
                                Text("z: ")
                            }
                        }

                        VStack {
                            Slider(value: $scene.parameters.sphereRadius, in: 0...10, step: 0.1) {
                                Text("Radius: \(scene.parameters.sphereRadius, specifier: "%.1f")")
                                    .lineLimit(1)
                            }
                        }
                    }

                    Spacer()
                }
                .font(.callout)
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
                .frame(width: 200)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
