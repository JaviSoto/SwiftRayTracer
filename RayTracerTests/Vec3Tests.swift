//
//  Vec3Tests.swift
//  RayTracerTests
//
//  Created by Javier Soto on 12/11/22.
//

import XCTest
@testable import RayTracer

final class Vec3Tests: XCTestCase {
    func testInit() {
        let v = Vec3(x: 1, y: 2, z: 3)
        XCTAssertEqual(v.x, 1)
        XCTAssertEqual(v.y, 2)
        XCTAssertEqual(v.z, 3)

        XCTAssertEqual(Vec3(), .init(x: 0, y: 0, z: 0))
        XCTAssertEqual(Vec3(1, 2, 3), .init(x: 1, y: 2, z: 3))
    }

    func testEquatable() {
        let v1 = Vec3(x: 1, y: 2, z: 3)
        let v2 = Vec3(x: 1, y: 2, z: 3)

        XCTAssertEqual(v1, v2)
    }

    func testLength() {
        XCTAssertEqual(Vec3(x: 1, y: 2, z: 2).length, 3)
    }

    func testNormalized() {
        XCTAssertEqual(Vec3(1, 2, 2).normalized(), .init(1/3, 2/3, 2/3))
    }

    func testMinus() {
        let v1 = Vec3(x: 1, y: 2, z: 3)
        XCTAssertEqual(-v1, .init(x: -1, y: -2, z: -3))

        let v2 = Vec3(x: -1, y: -2, z: -3)
        XCTAssertEqual(-v2, .init(x: 1, y: 2, z: 3))
    }

    func testSubtraction() {
        let v1 = Vec3(x: 1, y: 2, z: 3)
        let v2 = Vec3(x: 0.5, y: 1, z: -1)

        XCTAssertEqual(v1 - v2, .init(x: 0.5, y: 1, z: 4))
        XCTAssertEqual(v1 - 1, .init(x: 0, y: 1, z: 2))
    }

    func testDivision() {
        let v1 = Vec3(x: 1, y: 2, z: 3)
        let v2 = Vec3(x: 2, y: 1, z: 2)

        XCTAssertEqual(v1 / v2, .init(x: 0.5, y: 2, z: 1.5))
        XCTAssertEqual(v1 / 1, v1)
    }

    func testMultiplication() {
        let v1 = Vec3(x: 1, y: 2, z: 3)
        let v2 = Vec3(x: 2, y: 1, z: 2)

        XCTAssertEqual(v1 * v2, .init(x: 2, y: 2, z: 6))
        XCTAssertEqual(v1 * 1, v1)
    }

    func testDotProduct() {
        let v1 = Vec3(x: 1, y: 2, z: 3)
        let v2 = Vec3(x: 2, y: 1, z: 2)

        XCTAssertEqual(v1 • v2, 10)
    }

    func testCrossProduct() {
        let v1 = Vec3(x: 3, y: -3, z: 1)
        let v2 = Vec3(x: 4, y: 9, z: 2)

        XCTAssertEqual(v1 ⨯ v2, .init(-15, -2, 39))
    }

    func testOperatorEquals() {
        var v = Vec3(1, 2, 3)
        v -= Vec3(0.5, 0.3, 0.1)
        XCTAssertEqual(v, .init(0.5, 1.7, 2.9))

        v += 2
        XCTAssertEqual(v, .init(2.5, 3.7, 4.9))

        v /= 0.5
        XCTAssertEqual(v, .init(5, 7.4, 9.8))

        v *= 2
        XCTAssertEqual(v, .init(10, 14.8, 19.6))
    }

    func testExpressibleByInt() {
        let v1: Vec3 = 3
        XCTAssertEqual(v1, Vec3(x: 3, y: 3, z: 3))
    }

    func testExpressibleByDouble() {
        let v1: Vec3 = 3.5
        XCTAssertEqual(v1, Vec3(x: 3.5, y: 3.5, z: 3.5))
    }
}
