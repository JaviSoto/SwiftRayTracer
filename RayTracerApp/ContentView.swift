//
//  ContentView.swift
//  RayTracerApp
//
//  Created by Javier Soto on 12/11/22.
//

import SwiftUI
import RayTracer

struct ContentView: View {
    @State private var width: Int = 10
    @State private var height: Int = 10

    @State private var scene: Scene = Scene()

    private var sphereConfigurationView: some View {
        ForEach(Array(scene.world.spheres.enumerated()), id: \.0) { index, sphere in
            VStack {
                Text("Position: (\(sphere.center.x, specifier: "%.1f"), \(sphere.center.y, specifier: "%.1f"), \(sphere.center.z, specifier: "%.1f"))")
                    .lineLimit(1)
                Slider(value: $scene.world.spheres[index].center.x, in: -100...100, step: 1) {
                    Text("x: \(sphere.center.x)")
                }
                Slider(value: $scene.world.spheres[index].center.y, in: -100...100, step: 1) {
                    Text("y: \(sphere.center.y)")
                }
                Slider(value: $scene.world.spheres[index].center.z, in: -100...100, step: 1) {
                    Text("z: \(sphere.center.z)")
                }
                VStack {
                    Slider(value: $scene.world.spheres[index].radius, in: 0...100, step: 0.5) {
                        Text("Radius: \(sphere.radius, specifier: "%.1f")")
                            .lineLimit(1)
                    }
                }

                Button("Remove") {
                    scene.world.spheres.remove(at: index)
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
                        Slider(value: $scene.camera.viewportHeight, in: -5...5, step: 0.1) {
                            Text("Height: \(scene.camera.viewportHeight, specifier: "%.1f")")
                                .lineLimit(1)
                        }

                        Slider(value: $scene.camera.focalLength, in: -5...5, step: 0.1) {
                            Text("Focal Length: \(scene.camera.focalLength, specifier: "%.1f")")
                                .lineLimit(1)
                        }
                    }

                    Divider()

                    Section(header: Text("Spheres:").fontWeight(.bold)) {
                        TabView {
                            sphereConfigurationView
                        }

                        Button("New Sphere") {
                            scene.world.objects.append(Sphere(center: .init(0, 0, -1), radius: 0.3))
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
            measure("\(width)x\(height) scene") {
                scene.render(width: width, height: height).asSwiftUIImage()
            }
            .onSizeChange { size in
                width = Int(size.width)
                height = Int(size.height)
                scene.camera.viewportWidth = (size.width / size.height) * scene.camera.viewportHeight
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
