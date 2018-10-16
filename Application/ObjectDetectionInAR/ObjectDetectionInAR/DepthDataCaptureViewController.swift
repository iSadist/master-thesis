import UIKit
import AVFoundation

class DepthDataCaptureViewController: ImageViewController, AVCapturePhotoCaptureDelegate
{
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var depthImageView: UIImageView!
    
    override func viewDidLoad()
    {
        AVCaptureDevice.requestAccess(for: .video, completionHandler: { _ in })
        if let dualCamera = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back)
        {
            captureDevice = dualCamera
            cameraOutputView = cameraView
            captureDepthData = true
            super.viewDidLoad()
            depthImageView.transform = depthImageView.transform.rotated(by: CGFloat.pi/2).scaledBy(x: 2.17, y: 0.8)
        }
        else
        {
            print("Error! Could not establish a capture device.")
        }
    }
    
    @IBAction func captureButtonPressed(_ sender: Any)
    {
        depthImageView.isHidden = true
        takePhoto()
    }
    
    func takePhoto()
    {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        settings.isAutoStillImageStabilizationEnabled = true
        settings.isDepthDataDeliveryEnabled = true
        capturePhotoOutput?.capturePhoto(with: settings, delegate: self)
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?)
    {
        guard var depthData = photo.depthData else {
            print("Failed to capture depth data")
            return }
        if depthData.depthDataType != kCVPixelFormatType_DisparityFloat32
        {
            // Make sure the depth data is in the right format
            depthData = depthData.converting(toDepthDataType: kCVPixelFormatType_DisparityFloat32)
        }
        
        let depthDataMap = depthData.depthDataMap
        depthDataMap.normalize()
        
        // Convertion to UIImage
        let ciImage = CIImage(cvPixelBuffer: depthData.depthDataMap)
        let depthMapImage = UIImage(ciImage: ciImage, scale: 1.0, orientation: .up)
        
        depthImageView.isHidden = false
        depthImageView.image = depthMapImage
        
//        UIImageWriteToSavedPhotosAlbum(depthMapImage, nil, nil, nil) Does not work for unknown reason
    }
}

extension CVPixelBuffer {
    
    func normalize()
    {
        let width = CVPixelBufferGetWidth(self)
        let height = CVPixelBufferGetHeight(self)
        
        CVPixelBufferLockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 0))
        let floatBuffer = unsafeBitCast(CVPixelBufferGetBaseAddress(self), to: UnsafeMutablePointer<Float>.self)
        
        var minPixel: Float = 1.0
        var maxPixel: Float = 0.0
        
        for y in 0 ..< height {
            for x in 0 ..< width {
                let pixel = floatBuffer[y * width + x]
                minPixel = min(pixel, minPixel)
                maxPixel = max(pixel, maxPixel)
            }
        }
        
        let range = maxPixel - minPixel
        
        for y in 0 ..< height {
            for x in 0 ..< width {
                let pixel = floatBuffer[y * width + x]
                floatBuffer[y * width + x] = (pixel - minPixel) / range
            }
        }
        
        CVPixelBufferUnlockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 0))
    }
}
