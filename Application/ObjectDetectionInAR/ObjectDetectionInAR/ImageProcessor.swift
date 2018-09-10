import Foundation
import UIKit
import AVFoundation

class ImageProcessor
{
    var buffers: [CVPixelBuffer] = []
    let croppedImages: [UIImage] = []
    
    func addBuffer(buffer: CVPixelBuffer)
    {
        buffers.append(buffer)
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
