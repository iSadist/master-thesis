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
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        snapshot()
    }
    
    func snapshot()
    {
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.embedsDepthDataInPhoto = true
        photoSettings.flashMode = .off
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
                    self.snapshot()
                }
            }
        })
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
}
