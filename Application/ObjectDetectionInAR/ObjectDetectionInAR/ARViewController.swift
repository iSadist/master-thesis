import UIKit
import SceneKit
import ARKit
import Vision

class ARViewController: UIViewController, ARSCNViewDelegate, AVCaptureVideoDataOutputSampleBufferDelegate
{
    @IBOutlet var sceneView: ARSCNView!
    
    override var prefersStatusBarHidden: Bool { return true }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return .portrait }
    override var shouldAutorotate: Bool { return false }
    
    var object: ARFrame?
    var videoDataOutput: AVCaptureVideoDataOutput?
    var captureSession: AVCaptureSession?
    let trackingImageURLs: [String] = [] // Images that will be tracked
    
    func makeSphere() -> SCNNode
    {
        let geometry = SCNSphere(radius: 0.2)
        let textureImage = UIImage(named: "stone_diffuse.jpg")
        let normalImage = UIImage(named: "stone_normal.jpg")
        geometry.firstMaterial?.diffuse.contents = textureImage
        geometry.firstMaterial?.normal.contents = normalImage
        let node = SCNNode(geometry: geometry)
        return node
    }
    
    func loadImageConfiguration()
    {
        let imageConfig = ARImageTrackingConfiguration()
        
        for imageURL in trackingImageURLs
        {
            guard let image: CGImage = UIImage(named: imageURL)?.cgImage else { return }
            let referenceImage = ARReferenceImage(image, orientation: CGImagePropertyOrientation.up, physicalWidth: 0.3)
            imageConfig.trackingImages.insert(referenceImage)
        }

        imageConfig.isAutoFocusEnabled = true
        imageConfig.maximumNumberOfTrackedImages = trackingImageURLs.count
        sceneView.session.run(imageConfig)
    }
    
    func loadWorldTrackingConfiguration()
    {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        sceneView.session.run(configuration)
    }
    
    // MARK: Lifecycle events
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.debugOptions = [
            ARSCNDebugOptions.showFeaturePoints,
            ARSCNDebugOptions.showWorldOrigin
        ]
        
        // Setup data capture for the camera
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let captureInput = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        let dataOutput = AVCaptureVideoDataOutput()
        captureSession = AVCaptureSession()
        captureSession?.addInput(captureInput)
        captureSession?.addOutput(dataOutput)
        
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        
        // Load the scene
        let scene = SCNScene(named: "art.scnassets/world.scn")!
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        loadWorldTrackingConfiguration()
        captureSession?.startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode?
    {
        let node = SCNNode()
        
        let sphereNode = makeSphere()
        node.addChildNode(sphereNode)
        
        return node
    }
    
    func session(_ session: ARSession, didFailWithError error: Error)
    {
        // Present an error message to the user
    }
    
    func sessionWasInterrupted(_ session: ARSession)
    {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
    }
    
    func sessionInterruptionEnded(_ session: ARSession)
    {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
    }
    
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        
        guard let model = try? VNCoreMLModel(for: Furniture().model) else { return }
        let request = VNCoreMLRequest(model: model, completionHandler: { (finishedReq, err) in
            
            if let result = finishedReq.results as? [VNCoreMLFeatureValueObservation]
            {
                let observations = result.first?.featureValue.multiArrayValue!
                let confidenceValues: [Double] = [observations![0], observations![1], observations![2]] as! [Double]
                
                let maxNumber = confidenceValues.max()
                let index = confidenceValues.index(of: maxNumber!)
                
                print(confidenceValues)
            }
            
        })
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
}
