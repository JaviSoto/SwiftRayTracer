//
//  Hittable.swift
//  RayTracer
//
//  Created by Javier Soto on 12/11/22.
//

import Foundation

public struct HitResult {
    public var point: Point3
    public var normal: Vec3
    public var t: Double
    public var frontFace: Bool = true

    mutating func setFaceNormal(with ray: Ray, outwardNormal: Vec3) {
        frontFace = (ray.direction • outwardNormal) < 0
        normal = frontFace ? outwardNormal : -outwardNormal
    }
}

public protocol Hittable: Equatable {
    func hitTest(with ray: Ray, validTRange: ClosedRange<Double>) -> HitResult?
}
