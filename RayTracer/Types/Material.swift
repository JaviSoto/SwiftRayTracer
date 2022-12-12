//
//  Material.swift
//  RayTracer
//
//  Created by Javier Soto on 12/11/22.
//

import Foundation

public struct Scatter {
    public let attenuation: Color3
    public let scatteredRay: Ray
}

public protocol Material: Equatable {
    func scatter(rayIn: Ray, hitResult: HitResult) -> Scatter?
}

public struct Lambertian: Material {
    public var albedo: Color3

    public init(albedo: Color3) {
        self.albedo = albedo
    }

    public func scatter(rayIn: Ray, hitResult: HitResult) -> Scatter? {
        var scatterDirection = hitResult.normal + .randomUnitVector()

        // Catch degenerate scatter direction
        if scatterDirection.isNearZero {
            scatterDirection = hitResult.normal
        }

        let scatteredRay = Ray(origin: hitResult.point, direction: scatterDirection);
        let attenuation = albedo

        return Scatter(attenuation: attenuation, scatteredRay: scatteredRay)
    }
}

public struct Metal: Material {
    public var albedo: Color3
    public var fuzz: Double

    public init(albedo: Color3, fuzz: Double) {
        self.albedo = albedo
        self.fuzz = fuzz
    }

    public func scatter(rayIn: Ray, hitResult: HitResult) -> Scatter? {
        let reflected = rayIn.direction.normalized.reflect(hitResult.normal)
        let scatteredRay = Ray(origin: hitResult.point, direction: reflected + Vec3(fuzz) * .randomInUnitSphere())
        let attenuation = albedo

        guard scatteredRay.direction • hitResult.normal > 0 else { return nil }

        return Scatter(attenuation: attenuation, scatteredRay: scatteredRay)
    }
}

public struct Dielectric: Material {
    public var refractionIndex: Double

    public init(refractionIndex: Double) {
        self.refractionIndex = refractionIndex
    }

    public func scatter(rayIn: Ray, hitResult: HitResult) -> Scatter? {
        let attenuation = Color3(1)
        let refractionRatio = hitResult.frontFace ? 1.0 / refractionIndex : refractionIndex

        let normalizedDirection = rayIn.direction.normalized

        let cosTheta = fmin((-normalizedDirection • hitResult.normal), 1.0)
        let sinTheta = (1.0 - cosTheta * cosTheta).squareRoot()

        let cannonRefract = refractionRatio * sinTheta > 1.0

        let direction: Vec3
        if cannonRefract || reflectance(cosine: cosTheta, refractionRatio: refractionRatio) > Double.random(in: 0...1) {
            direction = normalizedDirection.reflect(hitResult.normal)
        } else {
            direction = normalizedDirection.refract(hitResult.normal, etaiOverEtat: refractionRatio)
        }

        let scatteredRay = Ray(origin: hitResult.point, direction: direction)

        return Scatter(attenuation: attenuation, scatteredRay: scatteredRay)
    }

    private func reflectance(cosine: Double, refractionRatio: Double) -> Double {
        // Use Schlick's approximation for reflectance.
        var r0 = (1 - refractionRatio) / (1 + refractionRatio)
        r0 *= r0
        return r0 + ( 1 - r0) * pow ((1 - cosine), 5)
    }
}
