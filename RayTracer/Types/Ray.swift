//
//  Ray.swift
//  RayTracer
//
//  Created by Javier Soto on 12/11/22.
//

import Foundation

public struct Ray {
    public let origin: Point3
    public let direction: Vec3

    public init(origin: Point3, direction: Vec3) {
        self.origin = origin
        self.direction = direction
    }

    public func point(at t: Double) -> Point3 {
        return origin + direction * .init(t)
    }
}
