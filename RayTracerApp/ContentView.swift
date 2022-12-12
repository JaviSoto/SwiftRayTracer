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
        ForEach(Array(scene.world.objects.enumerated()), id: \.0) { index, sphere in
            VStack {
                Vec3Sliders(name: "Position", vector: $scene.world.objects[index].center, range: -100...100, step: 1)
                ValueSlider(name: "Radius", value: $scene.world.objects[index].radius, range: 0...100, step: 0.5, decimalPoints: 1)

                HStack {
                    Button("Remove") {
                        scene.world.objects.remove(at: index)
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
                            ValueSlider(name: "Width", value: $scene.width.double, range: 100...1024, step: 10, decimalPoints: 0, unit: "px")
                            ValueSlider(name: "Samples per pixel", value: $scene.samplesPerPixel.double, range: 1...100, step: 1, decimalPoints: 0)
                            ValueSlider(name: "Max bounces", value: $scene.maxBounces.double, range: 1...100, step: 1, decimalPoints: 0)
                        }

                        Section(header: Text("Camera").fontWeight(.bold)) {
                            ValueSlider(name: "Vertical FoV", value: $scene.camera.parameters.verticalFoV.degrees, range: 5...180, step: 10, decimalPoints: 0, unit: "º")
                            ValueSlider(name: "Aperture", value: $scene.camera.parameters.aperture, range: 1...2, step: 0.1, decimalPoints: 1)
                            ValueSlider(name: "Focus Distance", value: $scene.camera.parameters.focusDistance, range: 0...100, step: 1, decimalPoints: 0)
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
            Group {
                if renderer.rendering {
                    ProgressView()
                        .progressViewStyle(.linear)
                } else {
                    Button("Render") {
                        renderer.render(scene)
                    }
                }
            }
            .padding()
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
