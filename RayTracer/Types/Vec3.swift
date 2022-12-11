//
//  Vec3.swift
//  RayTracer
//
//  Created by Javier Soto on 12/11/22.
//

import Foundation

/// Equivalent names for `Vec3` for better semantic meaning.
public typealias Point3 = Vec3
public typealias Color3 = Vec3

public struct Vec3: Equatable {
    public let x: Double
    public let y: Double
    public let z: Double

    public init() {
        self = 0
    }

    public init(_ value: Double) {
        self.init(x: value, y: value, z: value)
    }

    public init(x: Double, y: Double, z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }

    public init(_ x: Double, _ y: Double, _ z: Double) {
        self.init(x: x, y: y, z: z)
    }
}

// MARK: - Properties

extension Vec3 {
    public var length: Double {
        lengthSquared.squareRoot()
    }

    public var lengthSquared: Double {
        x*x + y*y + z*z
    }

    public mutating func normalize() {
        self = normalized()
    }

    // unit_vector()
    public func normalized() -> Vec3 {
        return self / .init(self.length)
    }
}

// MARK: - CustomSringConvertible {

extension Vec3: CustomStringConvertible {
    public var description: String {
        return "\(x) \(y) \(z)"
    }
}

// MARK: - Operators

// dot product
infix operator •

// cross product
infix operator ⨯

extension Vec3 {
    public static func - (lhs: Vec3, rhs: Vec3) -> Vec3 {
        return .init(
            x: lhs.x - rhs.x,
            y: lhs.y - rhs.y,
            z: lhs.z - rhs.z
        )
    }

    static func -= (lhs: inout Vec3, rhs: Vec3) {
        lhs = lhs - rhs
    }

    public static func + (lhs: Vec3, rhs: Vec3) -> Vec3 {
        return .init(
            x: rhs.x + lhs.x,
            y: rhs.y + lhs.y,
            z: rhs.z + lhs.z
        )
    }

    static func += (lhs: inout Vec3, rhs: Vec3) {
        lhs = lhs + rhs
    }

    public static prefix func - (vec: Vec3) -> Vec3 {
        return 0 - vec
    }

    public static func / (lhs: Vec3, rhs: Vec3) -> Vec3 {
        return .init(
            x: lhs.x / rhs.x,
            y: lhs.y / rhs.y,
            z: lhs.z / rhs.z
        )
    }

    static func /= (lhs: inout Vec3, rhs: Vec3) {
        lhs = lhs / rhs
    }

    public static func * (lhs: Vec3, rhs: Vec3) -> Vec3 {
        return .init(
            x: lhs.x * rhs.x,
            y: lhs.y * rhs.y,
            z: lhs.z * rhs.z
        )
    }

    static func *= (lhs: inout Vec3, rhs: Vec3) {
        lhs = lhs * rhs
    }

    // dot product
    public static func • (lhs: Vec3, rhs: Vec3) -> Double {
        return lhs.x * rhs.x
        + lhs.y * rhs.y
        + lhs.z * rhs.z
    }

    // cross product
    public static func ⨯ (lhs: Vec3, rhs: Vec3) -> Vec3 {
        return .init(
            lhs.y * rhs.z - lhs.z * rhs.y,
            lhs.z * rhs.x - lhs.x * rhs.z,
            lhs.x * rhs.y - lhs.y * rhs.x
        )
    }
}

// MARK: - ExpressibleBy

extension Vec3: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self.init(Double(value))
    }
}

extension Vec3: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self.init(value)
    }
}

// MARK: - Color Conversion

import SwiftUI

extension Vec3 {
    public var red: Double { x }
    public var green: Double { y }
    public var blue: Double { z }

    public var asColor: Color {
        return Color(red: x, green: y, blue: z)
    }

    public var sRGBAValue: UInt32 {
        let color = self * 255.0
        return UInt32(color.red) << 24
        + UInt32(color.green) << 16
        + UInt32(color.blue) << 8
        + 255
    }
}
