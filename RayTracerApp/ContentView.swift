//
//  ContentView.swift
//  RayTracerApp
//
//  Created by Javier Soto on 12/11/22.
//

import SwiftUI
import RayTracer

struct ContentView: View {
    @State private var scene = RayTracer.Scene()

    @ObservedObject
    private var renderer = Renderer()

    private var sphereConfigurationView: some View {
        ForEach(Array(scene.world.spheres.enumerated()), id: \.0) { index, sphere in
            VStack {
                Text("Position:")
                Slider(value: $scene.world.spheres[index].center.x, in: -100...100, step: 1) {
                    Text("x: \(sphere.center.x, specifier: "%.1f")")
                }
                Slider(value: $scene.world.spheres[index].center.y, in: -100...100, step: 1) {
                    Text("y: \(sphere.center.y, specifier: "%.1f")")
                }
                Slider(value: $scene.world.spheres[index].center.z, in: -100...100, step: 1) {
                    Text("z: \(sphere.center.z, specifier: "%.1f")")
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

                    Section(header: Text("Render").fontWeight(.bold)) {
                        Slider(javivalue: $scene.width, in: 100...1024, step: 10) {
                            Text("Width: \(scene.width)")
                                .lineLimit(1)
                        }

                        Slider(javivalue: $scene.samplesPerPixel, in: 1...100, step: 1) {
                            Text("Samples per pixel: \(scene.samplesPerPixel)")
                                .lineLimit(1)
                        }

                        Slider(javivalue: $scene.maxBounces, in: 1...100, step: 1) {
                            Text("Max bounces: \(scene.maxBounces)")
                                .lineLimit(1)
                        }
                    }

                    Section(header: Text("Camera").fontWeight(.bold)) {
                        Slider(value: $scene.camera.viewportHeight, in: -5...5, step: 0.1) {
                            Text("Viewport Height: \(scene.camera.viewportHeight, specifier: "%.1f")")
                                .lineLimit(1)
                        }
                        .onChange(of: scene.camera.viewportHeight) { viewportHeight in
                            scene.camera.viewportWidth = (RayTracer.Scene.aspectRatio) * viewportHeight
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
            renderer.renderedImage
                .resizable()
                .aspectRatio(RayTracer.Scene.aspectRatio, contentMode: .fit)

            ZStack {
                #if DEBUG
                Text("Warning: Building without optimizations!")
                #endif

                configurationView
                    .frame(width: 200)
            }
        }
        .onAppear {
            renderer.render(scene)
        }
        .onChange(of: scene) { scene in
            renderer.render(scene)
        }
    }
}

@MainActor
final class Renderer: ObservableObject {
    @Published
    var renderedImage: SwiftUI.Image = SwiftUI.Image(systemName: "arrow.triangle.2.circlepath.circle.fill")

    private var lastTask: DispatchWorkItem?

    func render(_ scene: RayTracer.Scene) {
        var task: DispatchWorkItem!
        task = DispatchWorkItem {
            guard !task.isCancelled else { return }

            let image = measure("\(scene.width)x\(scene.height) (\(scene.samplesPerPixel) samples per pixel, \(scene.maxBounces) max bounces) scene") {
                return scene
                    .render()
                    .asSwiftUIImage()
            }

            DispatchQueue.main.async {
                guard !task.isCancelled else { return }

                self.renderedImage = image
            }
        }

        lastTask = task

        DispatchQueue.global(qos: .userInitiated).async(execute: task)
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
