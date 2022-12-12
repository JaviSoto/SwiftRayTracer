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

        var world: World = .init(objects: [
            Sphere(center: .init(x: 0, y: 0, z: -1), radius: 0.5),
            Sphere(center: .init(x: 0, y: -100.5, z: -1), radius: 100),
        ])
    }

    var parameters: Parameters = .init()

    private func rayColor(_ ray: Ray) -> Color3 {
        if let worldHit = parameters.world.hitTest(with: ray, validTRange: 0.0...(.greatestFiniteMagnitude)) {
            return 0.5 * (worldHit.normal + Color3(1))
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

    private var sphereConfigurationView: some View {
        ForEach(Array(scene.parameters.world.spheres.enumerated()), id: \.0) { index, sphere in
            VStack {
                Text("Position: (\(sphere.center.x, specifier: "%.1f"), \(sphere.center.y, specifier: "%.1f"), \(sphere.center.z, specifier: "%.1f"))")
                    .lineLimit(1)
                Slider(value: $scene.parameters.world.spheres[index].center.x, in: -100...100, step: 1) {
                    Text("x: \(sphere.center.x)")
                }
                Slider(value: $scene.parameters.world.spheres[index].center.y, in: -100...100, step: 1) {
                    Text("y: \(sphere.center.y)")
                }
                Slider(value: $scene.parameters.world.spheres[index].center.z, in: -100...100, step: 1) {
                    Text("z: \(sphere.center.z)")
                }
                VStack {
                    Slider(value: $scene.parameters.world.spheres[index].radius, in: 0...100, step: 0.5) {
                        Text("Radius: \(sphere.radius, specifier: "%.1f")")
                            .lineLimit(1)
                    }
                }

                Button("Remove") {
                    scene.parameters.world.spheres.remove(at: index)
                }

                Spacer()
            }
            .tabItem {
                Text("\(index + 1)")
            }
        }
    }

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

                    Section(header: Text("Spheres:").fontWeight(.bold)) {
                        TabView {
                            sphereConfigurationView
                        }

                        Button("New Sphere") {
                            scene.parameters.world.objects.append(Sphere(center: .init(0, 0, -1), radius: 0.3))
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

            ZStack {
                #if DEBUG
                Text("Warning: Building without optimizations!")
                #endif

                configurationView
                    .frame(width: 200)
            }
        }
    }
}

private extension World {
    var spheres: [Sphere] {
        get {
            return objects.compactMap { $0 as? Sphere }
        }
        set {
            objects = newValue // TODO: keep the other objects in their indices too
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
