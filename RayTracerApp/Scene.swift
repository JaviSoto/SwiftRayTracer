//
//  Scene.swift
//  RayTracerApp
//
//  Created by Javier Soto on 12/11/22.
//

import Foundation
import RayTracer

struct Scene: Equatable {
    static let aspectRatio: Double = 16/9

    var width: Int = 256
    var height: Int {
        Int(Double(width) / Self.aspectRatio)
    }

    var samplesPerPixel = 100

    var camera: Camera = .init(viewportWidth: 2 * Self.aspectRatio, viewportHeight: 2)

    var world: World = .init(objects: [
        Sphere(center: .init(x: 0, y: 0, z: -1), radius: 0.5),
        Sphere(center: .init(x: 0, y: -100.5, z: -1), radius: 100),
    ])

    private func rayColor(_ ray: Ray) -> Color3 {
        if let worldHit = world.hitTest(with: ray, validTRange: 0.0...(.greatestFiniteMagnitude)) {
            return 0.5 * (worldHit.normal + Color3(1))
        }

        let normalizedDirection = ray.direction
        let t = 0.5 * (normalizedDirection.y + 1.0)
        return .init(1.0 - t) * Color3(1) + .init(t) * Color3(0.5, 0.7, 1.0)
    }

    func render() -> RayTracer.Image {
        assert(width > 0)
        assert(height > 0)

        return Image(
            pixels:
                (0..<height).reversed().flatMap { y in
                    (0..<width).map { x in
                        var pixelColor = Color3()
                        for _ in 0..<samplesPerPixel {
                            let normalizedX = (Double(x) + Double.random(in: 0...1)) / Double(width - 1)
                            let normalizedY = (Double(y) + Double.random(in: 0...1)) / Double(height - 1)
                            let ray = camera.ray(atNormalizedX: normalizedX, normalizedY: normalizedY)
                            pixelColor += rayColor(ray)
                        }

                        pixelColor /= .init(Double(samplesPerPixel))

                        return pixelColor
                    }
                }
            , width: width)
    }
}
