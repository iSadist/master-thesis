import Foundation
import UIKit

class ImageConverter
{
    init()
    {}
    
    func convertImageToPixelBuffer(image: UIImage) -> CVPixelBuffer?
    {
        guard let cgImage = convertUIImageToCGImage(image: image) else { return nil }
        guard let pixelBuffer = convertToPixelBuffer(forImage: cgImage) else { return nil }
        return pixelBuffer
    }
    
    func convertUIImageToCGImage(image: UIImage) -> CGImage?
    {
        let ciImage = CIImage(image: image)
        let context = CIContext(options: nil)
        let cgImage = context.createCGImage(ciImage!, from: ciImage!.extent)
        return cgImage
    }
    
    func convertPixelBufferToUIImage(pixelBuffer: CVPixelBuffer) -> UIImage
    {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext(options: nil)
        let cgImage = context.createCGImage(ciImage, from: ciImage.extent)
        let uiImage = UIImage(cgImage: cgImage!)
        return uiImage
    }
    
    private func convertToPixelBuffer (forImage image:CGImage) -> CVPixelBuffer?
    {
        let frameSize = CGSize(width: image.width, height: image.height)
        
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer:CVPixelBuffer? = nil

        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(frameSize.width), Int(frameSize.height), kCVPixelFormatType_32BGRA , attrs, &pixelBuffer)

        if status != kCVReturnSuccess
        {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags.init(rawValue: 0))
        let data = CVPixelBufferGetBaseAddress(pixelBuffer!)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)
        let context = CGContext(data: data, width: Int(frameSize.width), height: Int(frameSize.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: bitmapInfo.rawValue)

        context?.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))

        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

        return pixelBuffer
    }
}
