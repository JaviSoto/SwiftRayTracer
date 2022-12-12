//
//  World.swift
//  RayTracer
//
//  Created by Javier Soto on 12/11/22.
//

import Foundation

public struct World: Hittable, Equatable {
    public var objects: [Sphere]

    public init(objects: [Sphere]) {
        self.objects = objects
    }

    public func hitTest(with ray: Ray, validTRange: ClosedRange<Double>) -> HitResult? {
        var hitResult: HitResult?
        var closestSoFar: Double = validTRange.upperBound

        for object in objects {
            if let result = object.hitTest(with: ray, validTRange: validTRange.lowerBound...closestSoFar) {
                closestSoFar = result.t
                hitResult = result
            }
        }

        return hitResult
    }

    public static func == (lhs: World, rhs: World) -> Bool {
        guard lhs.objects.count == rhs.objects.count else { return false }

        for (l, r) in zip(lhs.objects, rhs.objects) {
            let casted = l as any Equatable
            guard equals(casted, r) else { return false }
        }

        return true
    }
}

private func equals<T: Equatable>(_ lhs: T, _ rhs: Any) -> Bool {
    guard let casted = rhs as? T else { return false }
    return lhs == casted
}
