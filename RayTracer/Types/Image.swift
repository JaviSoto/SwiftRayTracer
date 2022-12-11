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
        self.height = pixels.count / width
    }
}

// MARK: - SwiftUI

import SwiftUI

extension Image {
    public func render() -> SwiftUI.Image {
        var pixels = pixels.map(\.sRGBAValue)
        let cgImage = pixels.withUnsafeMutableBytes { ptr -> CGImage in
            return CGContext(
                data: ptr.baseAddress,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: 4 * width,
                space: CGColorSpace(name: CGColorSpace.sRGB)!,
                bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue +
                CGImageAlphaInfo.premultipliedLast.rawValue
            )!.makeImage()!
        }

        return SwiftUI.Image(decorative: cgImage, scale: 1)
    }
}
