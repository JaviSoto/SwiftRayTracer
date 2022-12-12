//
//  Scene.swift
//  RayTracerApp
//
//  Created by Javier Soto on 12/11/22.
//

import Foundation

private let centerMaterial = Lambertian(albedo: Color3(0.1, 0.2, 0.5))
private let leftMaterial = Dielectric(refractionIndex: 1.5)
private let rightMaterial = Metal(albedo: Color3(0.8, 0.6, 0.2), fuzz: 0)

public struct Scene: Equatable {
    public init() {}

    public static let aspectRatio: Double = 16/9

    public var width: Int = 400
    public var height: Int {
        Int(Double(width) / Self.aspectRatio)
    }

    public var samplesPerPixel = 50

    public var maxBounces = 20

    private static let defaultCameraOrigin = Vec3(13, 2, 3)
    private static let defaultCameraTarget = Vec3(0, 0, 0)

    public var camera = Camera(
        aspectRatio: Self.aspectRatio,
        verticalFoV: .degrees(20),
        aperture: 0.1,
        focusDistance: 10,
        origin: Self.defaultCameraOrigin,
        target: Self.defaultCameraTarget
    )

    public var world: World = {
        var objects: [Sphere] = []

        let groundMaterial = Lambertian(albedo: Color3(0.5, 0.5, 0.5))
        objects.append(Sphere(center: Vec3(0, -1000, 0), radius: 1000, material: groundMaterial))

        for a in -11..<11 {
            for b in -1..<11 {
                let materialOption = Double.random(in: 0...1)
                let center = Point3(Double(a) + 0.9 * Double.random(in: 0...1), 0.2, Double(b) + 0.9 * Double.random(in: 0...1))

                if (center - Point3(4, 0.2, 0)).length > 0.9 {
                    let sphereMaterial: any Material

                    if materialOption < 0.8 {
                        // diffuse
                        let albedo = Color3.random(in: 0...1) * Color3.random(in: 0...1)
                        sphereMaterial = Lambertian(albedo: albedo)
                    } else if materialOption < 0.95 {
                        // metal
                        let albedo = Color3.random(in: 0.5...1)
                        let fuzz = Double.random(in: 0...0.5)
                        sphereMaterial = Metal(albedo: albedo, fuzz: fuzz)
                    } else {
                        // glass
                        sphereMaterial = Dielectric(refractionIndex: 1.5)
                    }

                    objects.append(Sphere(center: center, radius: 0.2, material: sphereMaterial))
                }
            }
        }

        let material1 = Dielectric(refractionIndex: 1.5)
        objects.append(Sphere(center: Point3(0, 1, 0), radius: 1, material: material1))

        let material2 = Lambertian(albedo: Color3(0.4, 0.2, 0.1))
        objects.append(Sphere(center: Point3(-4, 1, 0), radius: 1, material: material2))

        let material3 = Metal(albedo: Color3(0.7, 0.6, 0.5), fuzz: 0)
        objects.append(Sphere(center: Point3(4, 1, 0), radius: 1, material: material3))

        return World(objects: objects)
    }()

    private func rayColor(_ ray: Ray, bouncesLeft: Int) -> Color3 {
        guard bouncesLeft > 0 else { return Color3(0) }

        if let worldHit = world.hitTest(with: ray, validTRange: 0.001...(.greatestFiniteMagnitude)) {
            if let scatter = worldHit.material.scatter(rayIn: ray, hitResult: worldHit) {
                return scatter.attenuation * rayColor(scatter.scatteredRay, bouncesLeft: bouncesLeft - 1)
            }
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
