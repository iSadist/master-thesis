import UIKit
import SceneKit
import ARKit
import Vision

class AssemblerViewController: UIViewController
{
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var overlayView: OverlayView!
    @IBOutlet weak var recognitionResultLabel: UILabel!
    
    override var prefersStatusBarHidden: Bool { return true }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return .portrait }
    override var shouldAutorotate: Bool { return false }
    
    let trackingImageURLs: [String] = [] // Images that will be tracked
    var tracker: ObjectTracker?
    var trackingRect = [CGRect]()
    var currentSnapshot: CVPixelBuffer?

    private var trackerQueue = DispatchQueue(label: "tracker", qos: DispatchQoS.userInitiated)
    
    func loadWorldTrackingConfiguration()
    {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]

        guard let detectingObjects = ARReferenceObject.referenceObjects(inGroupNamed: "Objects", bundle: nil) else { return }
        configuration.detectionObjects = detectingObjects
        
        for imageURL in trackingImageURLs
        {
            guard let image: CGImage = UIImage(named: imageURL)?.cgImage else { return }
            let referenceImage = ARReferenceImage(image, orientation: CGImagePropertyOrientation.up, physicalWidth: 0.3)
            configuration.detectionImages.insert(referenceImage)
        }
            
        configuration.maximumNumberOfTrackedImages = trackingImageURLs.count
            
        sceneView.session.run(configuration)
    }
    
    // Classify the object in the image
    func predict(pixelBuffer: CVPixelBuffer) -> VNClassificationObservation?
    {
        var classification: VNClassificationObservation? = nil
        
        guard let model = try? VNCoreMLModel(for: FurnitureNet().model) else { return nil }
        let request = VNCoreMLRequest(model: model, completionHandler: { (finishedReq, err) in
            
            if let observations = finishedReq.results as? [VNClassificationObservation]
            {
                let maxValue = observations.max(by: {(current, next) in current.confidence < next.confidence})
                classification = maxValue
            }
        })
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
        
        return classification
    }
    
    // MARK: Lifecycle events
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
//        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
//        sceneView.debugOptions.insert(ARSCNDebugOptions.showWorldOrigin)
        
        // Load the scene
        let scene = SCNScene(named: "art.scnassets/world.scn")!
        sceneView.scene = scene
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        loadWorldTrackingConfiguration()
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
        tracker?.requestCancelTracking()
        tracker = nil
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        tracker?.requestCancelTracking()
        tracker = nil
        print("Memory is full!")
    }
    
    // MARK: - UI Events
    
    @IBAction func identifyButtonTapped(_ sender: UIButton)
    {
        let snapshot = sceneView.snapshot()
        let converter = ImageConverter()
        guard let pixelBuffer = converter.convertImageToPixelBuffer(image: snapshot) else { return }
        let result = predict(pixelBuffer: pixelBuffer)
        self.recognitionResultLabel.text = "\(result?.identifier ?? "Nil"): \(result?.confidence ?? 100.0)%"
    }

    @IBAction func trackButtonTapped(_ sender: UIButton)
    {
        tracker = ObjectTracker(objects: trackingRect, overlay: overlayView)
        tracker?.delegate = self
        trackerQueue.async{
            self.tracker?.track()
        }
    }

    @IBAction func screenTapped(_ sender: UITapGestureRecognizer)
    {
        let touchPoint = sender.location(in: overlayView)
        let rect = CGRect(x: touchPoint.x, y: touchPoint.y, width: 100, height: 100)
        
        trackingRect.append(rect)
        overlayView.rectangles = [rect]
        overlayView.setNeedsDisplay()
    }
}

extension AssemblerViewController: ARSCNViewDelegate
{
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
}

extension AssemblerViewController: ObjectTrackerDelegate
{
    func displayRects(rects: [CGRect])
    {
        DispatchQueue.main.async {
            self.overlayView.storeVisionRects(rects: rects)
            self.overlayView.setNeedsDisplay()
        }
    }
    
    func getFrame() -> CVPixelBuffer?
    {
        DispatchQueue.main.async {
            let converter = ImageConverter()
            self.currentSnapshot = converter.convertImageToPixelBuffer(image: self.sceneView.snapshot())
        }
        
        return currentSnapshot
    }
}
