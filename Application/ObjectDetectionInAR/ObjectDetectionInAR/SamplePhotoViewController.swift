import UIKit
import AVFoundation

class SamplePhotoViewController: UIViewController, AVCapturePhotoCaptureDelegate
{
    var imageCapturer: AVCaptureDevice?
    var cameraOutput: AVCaptureOutput?
    var captureSession: AVCaptureSession?
    var videoPreview: AVCaptureVideoPreviewLayer?

    @IBOutlet weak var cameraOutputView: UIView!
    @IBOutlet weak var captureButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        imageCapturer = AVCaptureDevice.default(for: .video)
        
        do
        {
            guard let captureDevice = imageCapturer else { return }
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            
            videoPreview = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreview?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreview?.frame = cameraOutputView.layer.bounds
            cameraOutputView.layer.addSublayer(videoPreview!)
            captureSession?.startRunning()
        }
        catch
        {
            print("Error! Could not establish camera connection.")
            return
        }

    }
    
    @IBAction func captureButtonPressed(_ sender: UIButton)
    {
        var image = captureImage()
        
        // Detect objects in the image
        // Save cropped images to a local storage
    }
    
    func captureImage() -> UIImage
    {
        let image = UIImage()
        
        return image
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
