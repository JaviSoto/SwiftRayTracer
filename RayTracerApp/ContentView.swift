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
                Vec3Sliders(name: "Position", vector: $scene.world.spheres[index].center, range: -100...100, step: 1)

                VStack {
                    Slider(value: $scene.world.spheres[index].radius, in: 0...100, step: 0.5) {
                        Text("Radius: \(sphere.radius, specifier: "%.1f")")
                            .lineLimit(1)
                    }
                }

                HStack {
                    Button("Remove") {
                        scene.world.spheres.remove(at: index)
                    }

                    Button("New Sphere") {
                        scene.world.objects.append(Sphere(center: .init(0, 0, -1), radius: 0.3, material: Lambertian(albedo: Color3(1, 0, 0))))
                    }
                }

                Spacer()
            }
            .tabItem {
                Text("\(index + 1)")
            }
        }
    }

    private var configurationView: some View {
        VStack {
            ScrollView {
                Form {
                    VStack {
                        Text("Parameters")
                            .font(.largeTitle)

                        Section(header: Text("Render").fontWeight(.bold)) {
                            Slider(value: $scene.width, in: 100...1024, step: 10) {
                                Text("Width: \(scene.width)")
                                    .lineLimit(1)
                            }

                            Slider(value: $scene.samplesPerPixel, in: 1...100, step: 1) {
                                Text("Samples per pixel: \(scene.samplesPerPixel)")
                                    .lineLimit(1)
                            }

                            Slider(value: $scene.maxBounces, in: 1...100, step: 1) {
                                Text("Max bounces: \(scene.maxBounces)")
                                    .lineLimit(1)
                            }
                        }

                        Section(header: Text("Camera").fontWeight(.bold)) {
                            Slider(value: $scene.camera.parameters.verticalFoV.degrees, in: 5...180, step: 10) {
                                Text("Vertical FoV: \(scene.camera.parameters.verticalFoV.degrees, specifier: "%.0f")º")
                                    .lineLimit(1)
                            }

                            Slider(value: $scene.camera.parameters.focalLength, in: -5...5, step: 0.1) {
                                Text("Focal Length: \(scene.camera.parameters.focalLength, specifier: "%.1f")")
                                    .lineLimit(1)
                            }

                            Vec3Sliders(name: "Origin", vector: $scene.camera.parameters.origin, range: -10...10, step: 1)
                            Vec3Sliders(name: "Target", vector: $scene.camera.parameters.target, range: -10...10, step: 1)
                            Vec3Sliders(name: "Up direction", vector: $scene.camera.parameters.upDirection, range: -1...1, step: 0.1)
                        }

                        Divider()

                        Section(header: Text("Spheres:").fontWeight(.bold)) {
                            TabView {
                                sphereConfigurationView
                            }
                        }

                        Spacer()
                    }
                    .font(.callout)
                }
            }

            Divider()
            Button("Render") {
                renderer.render(scene)
            }
            .disabled(renderer.rendering)
        }
        .padding(.vertical)
    }

    var body: some View {
        HStack {
            ZStack {
                if let renderedImage = renderer.renderedImage {
                    renderedImage
                        .resizable()
                        .aspectRatio(RayTracer.Scene.aspectRatio, contentMode: .fit)
                } else {
                    Spacer()
                        .frame(maxWidth: .infinity)
                }

                if renderer.rendering {
                    ProgressView()
                        .progressViewStyle(.circular)
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

private struct Vec3Sliders: View {
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

@MainActor
final class Renderer: ObservableObject {
    @Published
    var renderedImage: SwiftUI.Image?

    @Published
    private(set) var rendering: Bool = false

    private var lastTask: DispatchWorkItem? {
        didSet {
            oldValue?.cancel()
        }
    }

    func render(_ scene: RayTracer.Scene) {
        var task: DispatchWorkItem!
        task = DispatchWorkItem {
            // Delay to collaesce scene changes
            guard !task.isCancelled else { return }

            DispatchQueue.main.async {
                self.rendering = true
            }
            let image = measure("\(scene.width)x\(scene.height) (\(scene.samplesPerPixel) samples per pixel, \(scene.maxBounces) max bounces) scene") {
                return scene
                    .render()
                    .asSwiftUIImage()
            }

            DispatchQueue.main.async {
                guard !task.isCancelled else { return }

                self.rendering = false
                self.renderedImage = image
            }
        }

        lastTask = task

        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + .milliseconds(100), execute: task)
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
