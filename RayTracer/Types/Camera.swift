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
        public var aperture: Double
        public var focusDistance: Double
        public var origin: Point3
        public var target: Point3
        public var upDirection: Vec3

        public init(aspectRatio: Double, verticalFoV: Angle, aperture: Double, focusDistance: Double, origin: Point3, target: Point3, upDirection: Vec3) {
            self.aspectRatio = aspectRatio
            self.verticalFoV = verticalFoV
            self.aperture = aperture
            self.focusDistance = focusDistance
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

    public init(aspectRatio: Double, verticalFoV: Angle, aperture: Double, focusDistance: Double, origin: Point3, target: Point3, upDirection: Vec3 = .init(0, 1, 0)) {
        self.parameters = .init(
            aspectRatio: aspectRatio,
            verticalFoV: verticalFoV,
            aperture: aperture,
            focusDistance: focusDistance,
            origin: origin,
            target: target,
            upDirection: upDirection
        )

        updateParameters()
    }

    public func ray(atNormalizedX x: Double, normalizedY y: Double) -> Ray {
        let rd = Vec3(lensRadius) * .randomInUnitDisk()
        let offset = u * Vec3(rd.x) + v * Vec3(rd.y)

        return Ray(
            origin: parameters.origin + offset,
            direction: lowerLeftCorner + Vec3(x) * horizontal + Vec3(y) * vertical - parameters.origin - offset
        )
    }

    // MARK: - Private

    private var horizontal: Vec3 = 0
    private var vertical: Vec3 = 0
    private var lowerLeftCorner: Vec3 = 0
    private var lensRadius: Double = 0
    private var u = Vec3()
    private var v = Vec3()
    private var w = Vec3()

    private mutating func updateParameters() {
        let theta = parameters.verticalFoV.radians
        let h = tan(theta / 2)
        let viewportHeight = 2 * h
        let viewportWidth = parameters.aspectRatio * viewportHeight
        w = (parameters.origin - parameters.target).normalized
        u = (parameters.upDirection ⨯ w).normalized
        v = w ⨯ u

        self.horizontal = Vec3(parameters.focusDistance) * Vec3(viewportWidth) * u
        self.vertical = Vec3(parameters.focusDistance) * Vec3(viewportHeight) * v
        self.lowerLeftCorner = parameters.origin - horizontal / 2 - vertical / 2 - Vec3(parameters.focusDistance) * w
        self.lensRadius = parameters.aperture / 2
    }
}
