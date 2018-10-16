import AVFoundation
import UIKit

class ImageViewController: UIViewController
{
    var imageCaptureDevice: AVCaptureDevice?
    var capturePhotoOutput: AVCapturePhotoOutput?
    var captureSession: AVCaptureSession?
    var videoPreview: AVCaptureVideoPreviewLayer?
    
    var cameraOutputView: UIView!
    var captureDevice: AVCaptureDevice!
    var captureDepthData = false
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return .portrait }
    override var shouldAutorotate: Bool { return false }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        do
        {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            capturePhotoOutput = AVCapturePhotoOutput()
            captureSession = AVCaptureSession()
            
            // Set input and output of the session
            captureSession?.sessionPreset = .photo
            captureSession?.addInput(input)
            captureSession?.addOutput(capturePhotoOutput!)
            capturePhotoOutput?.isDepthDataDeliveryEnabled = captureDepthData
            
            // Setup video preview to see the current camera feed
            videoPreview = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreview?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreview?.frame = cameraOutputView.layer.bounds
            
            // Add the videoPreview to the view on the controller
            cameraOutputView.layer.addSublayer(videoPreview!)
            captureSession?.startRunning()
        }
        catch
        {
            print("Error! Could not create a capture device input.")
        }
    }
    
    func getPixelBuffer(from photo: AVCapturePhoto) -> CVPixelBuffer?
    {
        let imageData = photo.fileDataRepresentation()
        let image = UIImage(data: imageData!)
        
        // Converting UIImage to CGImage
        let ciImage = CIImage(image: image!)
        let context = CIContext(options: nil)
        let cgImage = context.createCGImage(ciImage!, from: ciImage!.extent)
        
        // Get the pixel buffer
        let pixelBuffer = convertToPixelBuffer(forImage: cgImage!)
        return pixelBuffer
    }
    
    private func convertToPixelBuffer (forImage image:CGImage) -> CVPixelBuffer?
    {
        let frameSize = CGSize(width: image.width, height: image.height)
        
        var pixelBuffer:CVPixelBuffer? = nil
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(frameSize.width), Int(frameSize.height), kCVPixelFormatType_32BGRA , nil, &pixelBuffer)
        
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
