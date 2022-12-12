//
//  Camera.swift
//  RayTracer
//
//  Created by Javier Soto on 12/11/22.
//

import Foundation
import SwiftUI

public struct Camera: Equatable {
    public struct Parameters: Equatable {
        public var aspectRatio: Double
        public var verticalFoV: Angle
        public var focalLength: Double
        public var origin: Point3
        public var target: Point3
        public var upDirection: Vec3

        public init(aspectRatio: Double, verticalFoV: Angle, focalLength: Double = 1, origin: Point3, target: Point3, upDirection: Vec3) {
            self.aspectRatio = aspectRatio
            self.verticalFoV = verticalFoV
            self.focalLength = focalLength
            self.origin = origin
            self.target = target
            self.upDirection = upDirection
        }
    }

    public var parameters: Parameters {
        didSet {
            updateParameters()
        }
    }

    public init(aspectRatio: Double, verticalFoV: Angle = .degrees(90), origin: Point3, target: Point3, upDirection: Vec3 = .init(0, 1, 0)) {
        self.parameters = .init(aspectRatio: aspectRatio, verticalFoV: verticalFoV, origin: origin, target: target, upDirection: upDirection)

        updateParameters()
    }

    public func ray(atNormalizedX x: Double, normalizedY y: Double) -> Ray {
        return Ray(
            origin: parameters.origin,
            direction: lowerLeftCorner + Vec3(x) * horizontal + Vec3(y) * vertical - parameters.origin
        )
    }

    // MARK: - Private

    private var horizontal: Vec3 = 0
    private var vertical: Vec3 = 0
    private var lowerLeftCorner: Vec3 = 0

    private mutating func updateParameters() {
        let theta = parameters.verticalFoV.radians
        let h = tan(theta / 2)
        let viewportHeight = 2 * h
        let viewportWidth = parameters.aspectRatio * viewportHeight
        let w = (parameters.origin - parameters.target).normalized
        let u = (parameters.upDirection ⨯ w).normalized
        let v = w ⨯ u

        self.horizontal = Vec3(viewportWidth) * u
        self.vertical = Vec3(viewportHeight) * v
        self.lowerLeftCorner = parameters.origin - horizontal / 2 - vertical / 2 - w
    }
}
