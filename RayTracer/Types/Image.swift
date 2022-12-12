//
//  Image.swift
//  RayTracer
//
//  Created by Javier Soto on 12/11/22.
//

import Foundation
import CoreGraphics

public struct Image {
    public let pixels: [Vec3]
    public let width: Int
    public let height: Int

    public init(pixels: [Vec3], width: Int) {
        assert(pixels.count.isMultiple(of: width))

        self.pixels = pixels
        self.width = width
        self.height = width > 0 ? pixels.count / width : 0
    }
}

// MARK: - SwiftUI

import SwiftUI

extension Image {
    public func asSwiftUIImage() -> SwiftUI.Image {
        let pixels = pixels.map(\.sRGBAValue)

        let providerRef = CGDataProvider(data: NSData(bytes: pixels, length: width * height * 4))

        let cgImage = CGImage(
            width: width,
            height: height,
            bitsPerComponent: 8,
            bitsPerPixel: 4 * 8,
            bytesPerRow: 4 * width,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: .byteOrder32Little,
            provider: providerRef!,
            decode: nil,
            shouldInterpolate: true,
            intent: .defaultIntent
        )!

        return SwiftUI.Image(decorative: cgImage, scale: 1)
    }
}
