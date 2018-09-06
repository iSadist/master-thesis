import UIKit
import AVFoundation

class SamplePhotoViewController: UIViewController, AVCapturePhotoCaptureDelegate
{
    var imageCaptureDevice: AVCaptureDevice?
    var capturePhotoOutput: AVCapturePhotoOutput?
    var captureSession: AVCaptureSession?
    var videoPreview: AVCaptureVideoPreviewLayer?
    
    let imageProcessor = ImageProcessor()

    @IBOutlet weak var cameraOutputView: UIView!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        do
        {
            if let captureDevice = AVCaptureDevice.default(for: .video)
            {
                let input = try AVCaptureDeviceInput(device: captureDevice)
                capturePhotoOutput = AVCapturePhotoOutput()
                capturePhotoOutput?.isHighResolutionCaptureEnabled = true
                captureSession = AVCaptureSession()
                
                // Set input and output of the session
                captureSession?.addInput(input)
                captureSession?.addOutput(capturePhotoOutput!)
                
                // Setup video preview to see the current camera feed
                videoPreview = AVCaptureVideoPreviewLayer(session: captureSession!)
                videoPreview?.videoGravity = AVLayerVideoGravity.resizeAspectFill
                videoPreview?.frame = cameraOutputView.layer.bounds
                
                // Add the videoPreview to the view on the controller
                cameraOutputView.layer.addSublayer(videoPreview!)
                captureSession?.startRunning()
            }
            else
            {
                print("Error! Could not establish a capture device.")
                errorLabel.alpha = 1
                captureButton.isEnabled = false
            }
        }
        catch
        {
            print("Error! Could not create a capture device input.")
        }
    }
    
    @IBAction func captureButtonPressed(_ sender: UIButton)
    {
        if let capturePhotoOutput = self.capturePhotoOutput
        {
            // Set the photo settings
            let photoSettings = AVCapturePhotoSettings()
            photoSettings.embedsDepthDataInPhoto = true
            photoSettings.flashMode = .auto
            photoSettings.isAutoStillImageStabilizationEnabled = true
            photoSettings.isHighResolutionPhotoEnabled = true
            
            // Take a photo
            capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
        
        // Detect objects in the image
        // Save cropped images to a local storage
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let pixelBuffer = photo.pixelBuffer else { return }
        imageProcessor.addBuffer(buffer: pixelBuffer)
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
