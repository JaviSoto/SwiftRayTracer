//
//  Camera.swift
//  RayTracer
//
//  Created by Javier Soto on 12/11/22.
//

import Foundation

public struct Camera {
    public var viewportWidth: Double {
        didSet {
            updateParameters()
        }
    }

    public var viewportHeight: Double {
        didSet {
            updateParameters()
        }
    }

    public var focalLength: Double = 1

    public init(viewportWidth: Double, viewportHeight: Double) {
        self.viewportWidth = viewportWidth
        self.viewportHeight = viewportHeight

        updateParameters()
    }

    public func ray(atNormalizedX x: Double, normalizedY y: Double) -> Ray {
        return Ray(
            origin: rayOrigin,
            direction: lowerLeftCorner + Vec3(x) * horizontal + Vec3(y) * vertical - rayOrigin
        )
    }

    // MARK: - Private

    private let rayOrigin = Point3(0)
    private var aspectRatio: Double = 0
    private var horizontal: Vec3 = 0
    private var vertical: Vec3 = 0
    private var lowerLeftCorner: Vec3 = 0

    private mutating func updateParameters() {
        self.aspectRatio = viewportWidth / viewportHeight
        self.horizontal = Vec3(viewportWidth, 0, 0)
        self.vertical = Vec3(0, viewportHeight, 0)
        self.lowerLeftCorner = rayOrigin - horizontal / 2 - vertical / 2 - Vec3(0, 0, focalLength)
    }
}
