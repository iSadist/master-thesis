import AVFoundation
import UIKit
import Vision

class BarcodeScannerViewController: ImageViewController, AVCapturePhotoCaptureDelegate
{
    @IBOutlet weak var cameraView: UIView!
    
    var payloadString: String?
    
    override func viewDidLoad()
    {
        cameraOutputView = cameraView
        captureDevice = AVCaptureDevice.default(for: .video)
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        capturePhoto()
    }
    
    func capturePhoto()
    {
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.flashMode = .auto
        photoSettings.isAutoStillImageStabilizationEnabled = true
        capturePhotoOutput?.capturePhoto(with: photoSettings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?)
    {
        guard let pixelBuffer = getPixelBuffer(from: photo) else { return }
        let request = VNDetectBarcodesRequest(completionHandler: { (finishedReq, err) in
            if let result = finishedReq.results as? [VNBarcodeObservation]
            {
                if let payLoadString = result.first?.payloadStringValue
                {
                    self.payloadString = payLoadString
                    self.performSegue(withIdentifier: "unwindToFurnitureSelection", sender: nil)
                }
                else
                {
                    self.capturePhoto()
                }
            }
        })
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
}
