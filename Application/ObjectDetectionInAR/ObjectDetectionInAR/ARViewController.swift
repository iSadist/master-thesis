import UIKit
import SceneKit
import ARKit
import Vision

class ARViewController: UIViewController, ARSCNViewDelegate
{
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var recognitionResultLabel: UILabel!
    
    override var prefersStatusBarHidden: Bool { return true }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return .portrait }
    override var shouldAutorotate: Bool { return false }
    
    let trackingImageURLs: [String] = [] // Images that will be tracked
    
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

        guard let detectingObjects = ARReferenceObject.referenceObjects(inGroupNamed: "Objects", bundle: nil) else { return }
        configuration.detectionObjects = detectingObjects
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
        
        // Load the scene
        let scene = SCNScene(named: "art.scnassets/world.scn")!
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        loadWorldTrackingConfiguration()
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
    
    // MARK: - UI Events
    
    @IBAction func identifyButtonTapped(_ sender: UIButton)
    {
        let snapshot = sceneView.snapshot()
        let converter = ImageConverter()
        
        guard let pixelBuffer = converter.convertImageToPixelBuffer(image: snapshot) else { return }
        _ = predict(pixelBuffer: pixelBuffer)
    }

    // MARK: - ARSCNViewDelegate
    
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode?
    {
        let node = SCNNode()
        
        if let objectAnchor = anchor as? ARObjectAnchor
        {
            let objectName = objectAnchor.referenceObject.name!
            print(objectName)
            let textNode = GeometryFactory.makeText(text: objectName)
            node.addChildNode(textNode)
            return node
        }
        
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
    
    func predict(pixelBuffer: CVPixelBuffer) -> Double
    {
        guard let model = try? VNCoreMLModel(for: FurnitureNet().model) else { return 99 }
        let request = VNCoreMLRequest(model: model, completionHandler: { (finishedReq, err) in
            
            if let observations = finishedReq.results as? [VNClassificationObservation]
            {
                var labelText = "[ "
                for value in observations
                {
                    labelText.append(contentsOf: "\(value.identifier): ")
                    let valueString = String(format: "%.03f", value.confidence)
                    labelText.append(contentsOf: valueString)
                    labelText.append(contentsOf: " ,")
                }
                labelText.removeLast()
                labelText.append(contentsOf: " ]")
                self.recognitionResultLabel.text = labelText
            }
            
        })
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
        
        return 99
    }
}
