//
//  Camera.swift
//  RayTracer
//
//  Created by Javier Soto on 12/11/22.
//

import Foundation
import SwiftUI

public struct Camera: Equatable {
    public var aspectRatio: Double {
        didSet {
            updateParameters()
        }
    }

    public var verticalFoV: Angle {
        didSet {
            updateParameters()
        }
    }

    public var focalLength: Double = 1 {
        didSet {
            updateParameters()
        }
    }

    public init(aspectRatio: Double, verticalFoV: Angle = .degrees(90)) {
        self.aspectRatio = aspectRatio
        self.verticalFoV = verticalFoV

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
    private var horizontal: Vec3 = 0
    private var vertical: Vec3 = 0
    private var lowerLeftCorner: Vec3 = 0

    private mutating func updateParameters() {
        let theta = verticalFoV.radians
        let h = tan(theta / 2)
        let viewportHeight = 2 * h
        let viewportWidth = aspectRatio * viewportHeight
        self.horizontal = Vec3(viewportWidth, 0, 0)
        self.vertical = Vec3(0, viewportHeight, 0)
        self.lowerLeftCorner = rayOrigin - horizontal / 2 - vertical / 2 - Vec3(0, 0, focalLength)
    }
}
