//
//  ImageCompressor.swift
//  ImageCompressor
//

import Foundation
import UIKit
import Accelerate

class ImageCompressor {
    class func getCompressedImage(image: UIImage, x: CGFloat) -> UIImage {
        let currentWidth = image.size.width
        let currentHeight = image.size.height
        
        var newWidth: CGFloat = 0
        var newHeight: CGFloat = 0
        
        if max(currentWidth, currentHeight) > x {
            if currentWidth > currentHeight {
                newWidth = x
                let ratio = newWidth / currentWidth
                newHeight = currentHeight * ratio
            } else {
                newHeight = x
                let ratio = newHeight / currentHeight
                newWidth = currentWidth * ratio
            }
        } else {
            print("File size lower than target")
            return image
        }
        
        return image.resize(size: CGSize(width: newWidth, height: newHeight))!
        
    }
    
}

extension UIImage {
    
    func resize(minLength: CGFloat) -> UIImage? {
        let currentWidth = self.size.width
        let currentHeight = self.size.height
        
        var newWidth: CGFloat = 0
        var newHeight: CGFloat = 0
        
        if max(currentWidth, currentHeight) > minLength {
            if currentWidth > currentHeight {
                newWidth = minLength
                let ratio = newWidth / currentWidth
                newHeight = currentHeight * ratio
            } else {
                newHeight = minLength
                let ratio = newHeight / currentHeight
                newWidth = currentWidth * ratio
            }
        }
        
        return self.resize(size: CGSize(width: newWidth, height: newHeight))!
    }
    
    func resize(size: CGSize) -> UIImage? {
        
        guard let cgImage = self.cgImage else { return nil}
        
        var format = vImage_CGImageFormat(bitsPerComponent: 8, bitsPerPixel: 32, colorSpace: nil,
                                          bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.first.rawValue),
                                          version: 0, decode: nil, renderingIntent: CGColorRenderingIntent.defaultIntent)
        var sourceBuffer = vImage_Buffer()
        defer {
            if #available(iOS 13.0, *) {
                sourceBuffer.free()
            } else {
                sourceBuffer.data.deallocate()
            }
        }
        
        var error = vImageBuffer_InitWithCGImage(&sourceBuffer, &format, nil, cgImage, numericCast(kvImageNoFlags))
        guard error == kvImageNoError else { return nil }
        
        // create a destination buffer
        let scale = self.scale
        let destWidth = Int(size.width)
        let destHeight = Int(size.height)
        let bytesPerPixel = cgImage.bitsPerPixel / 8
        let destBytesPerRow = destWidth * bytesPerPixel
        let destData = UnsafeMutablePointer<UInt8>.allocate(capacity: destHeight * destBytesPerRow)
        defer {
            destData.deallocate()
        }
        var destBuffer = vImage_Buffer(data: destData, height: vImagePixelCount(destHeight), width: vImagePixelCount(destWidth), rowBytes: destBytesPerRow)
        
        // scale the image
        error = vImageScale_ARGB8888(&sourceBuffer, &destBuffer, nil, numericCast(kvImageHighQualityResampling))
        guard error == kvImageNoError else { return nil }
        
        // create a CGImage from vImage_Buffer
        guard let destCGImage = vImageCreateCGImageFromBuffer(&destBuffer, &format, nil, nil, numericCast(kvImageNoFlags), &error)?.takeRetainedValue() else { return nil}
        guard error == kvImageNoError else { return nil }
        
        // create a UIImage
        let resizedImage = UIImage(cgImage: destCGImage, scale: scale, orientation: self.imageOrientation)
        return resizedImage
    }
    
    func aspectFittedToHeight(_ newHeight: CGFloat) -> UIImage {
        let scale = newHeight / self.size.height
        let newWidth = self.size.width * scale
        let newSize = CGSize(width: newWidth, height: newHeight)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
