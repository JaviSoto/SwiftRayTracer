//
//  Scene.swift
//  RayTracerApp
//
//  Created by Javier Soto on 12/11/22.
//

import Foundation

public struct Scene: Equatable {
    public init() {}

    public static let aspectRatio: Double = 16/9

    public var width: Int = 300
    public var height: Int {
        Int(Double(width) / Self.aspectRatio)
    }

    public var samplesPerPixel = 20

    public var maxBounces = 20

    public var camera: Camera = .init(viewportWidth: 2 * Self.aspectRatio, viewportHeight: 2)

    public var world: World = .init(objects: [
        Sphere(center: .init(x: 0, y: 0, z: -1), radius: 0.5),
        Sphere(center: .init(x: 0, y: -100.5, z: -1), radius: 100),
    ])

    private func rayColor(_ ray: Ray, bouncesLeft: Int) -> Color3 {
        guard bouncesLeft > 0 else { return Color3(0) }

        if let worldHit = world.hitTest(with: ray, validTRange: 0.001...(.greatestFiniteMagnitude)) {
            let target = worldHit.point + .randomInHemisphere(normal: worldHit.normal)
            return 0.5 * rayColor(Ray(origin: worldHit.point, direction: target - worldHit.point), bouncesLeft: bouncesLeft - 1)
        }

        let normalizedDirection = ray.direction
        let t = 0.5 * (normalizedDirection.y + 1.0)
        return .init(1.0 - t) * Color3(1) + .init(t) * Color3(0.5, 0.7, 1.0)
    }

    public func render() -> RayTracer.Image {
        assert(width > 0)
        assert(height > 0)

        return Image(
            pixels:
                (0..<height).reversed().flatMap { y in
                    (0..<width).parallelMap { x in
                        var pixelColor = Color3()
                        for _ in 0..<samplesPerPixel {
                            let normalizedX = (Double(x) + .random(in: 0...1)) / Double(width - 1)
                            let normalizedY = (Double(y) + .random(in: 0...1)) / Double(height - 1)
                            let ray = camera.ray(atNormalizedX: normalizedX, normalizedY: normalizedY)
                            pixelColor += rayColor(ray, bouncesLeft: maxBounces)
                        }

                        // Divide the color by the number of samples and gamma-correct for gamma=2.0.
                        let scale = 1 / Double(samplesPerPixel)
                        pixelColor.red = (pixelColor.red * scale).squareRoot()
                        pixelColor.green = (pixelColor.green * scale).squareRoot()
                        pixelColor.blue = (pixelColor.blue * scale).squareRoot()

                        return pixelColor
                    }
                }
            , width: width)
    }
}

extension RandomAccessCollection where Index == Int {
    func parallelMap<U>(_ f: @escaping (Element) -> U) -> [U] {
        return Array(unsafeUninitializedCapacity: count) { buffer, initializedCount in
            DispatchQueue.concurrentPerform(iterations: count) { i in
                buffer[i] = f(self[i])
            }

            initializedCount = count
        }
    }
}
