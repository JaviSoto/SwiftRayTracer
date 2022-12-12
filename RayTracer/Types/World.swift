//
//  World.swift
//  RayTracer
//
//  Created by Javier Soto on 12/11/22.
//

import Foundation

public struct World: Hittable {
    public var objects: [any Hittable]

    public init(objects: [any Hittable]) {
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
}
