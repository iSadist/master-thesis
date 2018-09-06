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
    
    func savePhotosToLibrary()
    {
        for croppedImage in croppedImages
        {
            UIImageWriteToSavedPhotosAlbum(croppedImage, nil, nil, nil)
        }
    }
}
