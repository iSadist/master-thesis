import Foundation
import AVFoundation

class ImageProcessor
{
    var buffers: [CVPixelBuffer] = []
    
    func addBuffer(buffer: CVPixelBuffer)
    {
        buffers.append(buffer)
    }
}
