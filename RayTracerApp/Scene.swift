//
//  Scene.swift
//  RayTracerApp
//
//  Created by Javier Soto on 12/11/22.
//

import Foundation
import RayTracer

struct Scene {
    var camera: Camera = .init(viewportWidth: 2 * 16/9, viewportHeight: 2)

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

    func render(width: Int, height: Int) -> RayTracer.Image {
        guard width > 0, height > 0 else {
            return RayTracer.Image(pixels: [], width: 0)
        }

        return Image(
            pixels:
                (0..<height).reversed().flatMap { y in
                    (0..<width).map { x in
                        let normalizedX = Double(x) / Double(width - 1)
                        let normalizedY = Double(y) / Double(height - 1)
                        let ray = camera.ray(atNormalizedX: normalizedX, normalizedY: normalizedY)

                        return rayColor(ray)
                    }
                }
            , width: width)
    }
}