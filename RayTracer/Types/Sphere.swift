//
//  Sphere.swift
//  RayTracer
//
//  Created by Javier Soto on 12/11/22.
//

import Foundation

public struct Sphere: Hittable {
    public var center: Point3
    public var radius: Double

    public init(center: Point3, radius: Double) {
        self.center = center
        self.radius = radius
    }

    public func hitTest(with ray: Ray, validTRange: ClosedRange<Double>) -> HitResult? {
        let oc = ray.origin - center
        let a = ray.direction.lengthSquared
        let halfB = oc • ray.direction
        let c = oc.lengthSquared - radius * radius
        let discriminant = halfB * halfB - a * c
        guard discriminant >= 0 else { return nil }

        let discriminantSquareRoot = discriminant.squareRoot()

        // Find the nearest root that lies in the acceptable range.
        var root = (-halfB - discriminantSquareRoot) / a
        if !validTRange.contains(root) {
            root = (-halfB + discriminantSquareRoot) / a
            guard validTRange.contains(root) else { return nil }
        }

        let point = ray.point(at: root)
        let outwardNormal = (point - center) / Vec3(radius)

        var hitResult = HitResult(point: point, normal: 0, t: root)
        hitResult.setFaceNormal(with: ray, outwardNormal: outwardNormal)

        return hitResult
    }
}
