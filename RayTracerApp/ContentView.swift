//
//  ContentView.swift
//  RayTracerApp
//
//  Created by Javier Soto on 12/11/22.
//

import SwiftUI
import RayTracer

extension Vec3 {
    var sRGBValue: UInt32 {
        let color = self.normalized() * 255.0
        // BGRA format
        Int(color.blue) << 24
        + Int(color.green) << 16
        + Int(color.red) << 8
        + 255
    }
}

struct PixelImage {
    let pixels: [Vec3]
    let width: Int
    let height: Int

    init(pixels: [Vec3], width: Int) {
        assert(pixels.count.isMultiple(of: width))

        self.pixels = pixels
        self.width = width
        self.height = pixels.count / width
    }

    func render() -> Image {
        var pixels = self.pixels.map(\.sRGBValue)
        let cgImage = pixels.withUnsafeMutableBytes { ptr -> CGImage in
            return CGContext(
                data: ptr.baseAddress,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: 4*width,
                space: CGColorSpace(name: CGColorSpace.sRGB)!,
                bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue +
                CGImageAlphaInfo.premultipliedFirst.rawValue
            )!.makeImage()!
        }

        return Image(cgImage, scale: 1, label: Text(verbatim: ""))
    }
}

struct ContentView: View {
    private let width = 256
    private let height = 256

    var image: PixelImage {
        return PixelImage(
            pixels: (0..<width).flatMap { x in
                (0..<height).map { y in
                    Vec3(
                        Double(x) / (Double(width - 1)),
                        Double(y) / (Double(height - 1)),
                        0.25
                    )
                }
            }
            , width: width)
    }

    var body: some View {
        image.render()
            .frame(width: Double(width), height: Double(height), alignment: .center)
            .background(Color.green)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
