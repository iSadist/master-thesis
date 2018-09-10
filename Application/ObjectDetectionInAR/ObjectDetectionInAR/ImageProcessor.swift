import Foundation
import UIKit
import AVFoundation

class ImageProcessor
{
    var pixels: [Pixel] = []
    let croppedImages: [UIImage] = []
    
    func process(buffer: CVPixelBuffer)
    {
        CVPixelBufferLockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
        
        // Get the pixel values
        let width = CVPixelBufferGetWidth(buffer)
        let height = CVPixelBufferGetHeight(buffer)
        
        for x in 0...width
        {
            for y in 0...height
            {
                pixels.append(getPixel(x: x, y: y, frame: buffer))
            }
        }
        
        CVPixelBufferUnlockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
    }
    
    func getPixel(x: Int, y: Int, frame: CVPixelBuffer) -> Pixel {
        let baseAddress = CVPixelBufferGetBaseAddress(frame)
        
        let bytesPerRow = CVPixelBufferGetBytesPerRow(frame)
        let buffer = baseAddress!.assumingMemoryBound(to: UInt8.self)

        let index = x+y*bytesPerRow
        let b = buffer[index]
        let g = buffer[index+1]
        let r = buffer[index+2]
        let a = buffer[index+3]
        
        return Pixel.init(r: r, g: g, b: b, a: a)
    }
    
    func pixelBufferToUIImage(pixelBuffer: CVPixelBuffer) -> UIImage {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext(options: nil)
        let cgImage = context.createCGImage(ciImage, from: ciImage.extent)
        let uiImage = UIImage(cgImage: cgImage!)
        return uiImage
    }
    
    func savePhotosToLibrary()
    {
        for croppedImage in croppedImages
        {
            UIImageWriteToSavedPhotosAlbum(croppedImage, nil, nil, nil)
        }
    }
}

struct Pixel {
    var r: UInt8
    var g: UInt8
    var b: UInt8
    var a: UInt8
}
