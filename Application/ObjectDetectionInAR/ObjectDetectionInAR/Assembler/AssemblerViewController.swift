import UIKit
import SceneKit
import ARKit
import Vision

class AssemblerViewController: UIViewController
{
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var overlayView: OverlayView!
    @IBOutlet weak var recognitionResultLabel: UILabel!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var messageViewButton: UIButton!
    @IBOutlet weak var messageViewText: UITextView!
    
    override var prefersStatusBarHidden: Bool { return true }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return .portrait }
    override var shouldAutorotate: Bool { return false }
    
    let trackingImageURLs: [String] = [] // Images that will be tracked
    var furniture: Furniture?
    var tracker: ObjectTracker?
    var detector: ObjectDetector?
    var trackingRect = [CGRect]()
    var currentSnapshot: CVPixelBuffer? = nil
    var currentFrame: UIImage? = nil
    
    var classifier: Timer?
    
    let executioner = InstructionExecutioner()
    var currentInstruction: Instruction?
    {
        willSet
        {
            messageViewText.text = newValue?.message
            messageViewButton.setTitle(newValue?.buttonText, for: .normal)
            messageViewButton.isHidden = newValue?.buttonText == nil
            messageView.isHidden = newValue == nil
            
            executioner.instruction = newValue
            executioner.executeInstruction()
        }
    }

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
    
    func addTrackingRect(rect: CGRect)
    {
        trackingRect.append(rect)
    }
    
    func startTracking()
    {
        tracker = ObjectTracker(objects: trackingRect, overlay: overlayView)
        tracker?.delegate = self
        trackerQueue.async{
            self.tracker?.track()
        }
    }
    
    func nextInstruction()
    {
        if furniture?.instructions?.isEmpty ?? true
        {
            currentInstruction = nil
            tracker?.requestCancelTracking()
        }
        else
        {
            currentInstruction = furniture?.instructions?.removeFirst()
        }
    }

    func connectPieces(fromScreen startPoint: CGPoint, to endPoint: CGPoint)
    {
        // Translate the point on screen to the point in the scene
        let startHit = sceneView.hitTest(startPoint, types: .estimatedHorizontalPlane).first
        let endHit = sceneView.hitTest(endPoint, types: .estimatedHorizontalPlane).first
        
        guard let startPosition = startHit?.worldTransform.columns.3 else { return }
        guard let endPosition = endHit?.worldTransform.columns.3 else { return }
        
        // The positions in the real world
        let startVector = SCNVector3(startPosition.x, startPosition.y, startPosition.z)
        let endVector = SCNVector3(endPosition.x, endPosition.y, endPosition.z)
        
        let distance = startVector.distanceTo(endVector)
        
        // Create the node and add it to the scene at the starting position
        let lineNode = GeometryFactory.makeLine(radius: 0.01, length: distance - 0.1)
        
        // Set the angle of the arrow to point from the first point to the second.
        // Assuming that the arrow will lay flat on the floor and only rotate in y-axis.
        // This is becuase the hittests only get points from a plane anyway.
        lineNode.eulerAngles.x = Float.pi / 2
        lineNode.eulerAngles.y = asin((endPosition.x - startPosition.x) / distance)
        lineNode.position = startVector
        
        sceneView.scene.rootNode.addChildNode(lineNode)
    }
    
    // MARK: Lifecycle events
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        sceneView.delegate = self
        messageView.layer.cornerRadius = 25
        
//        Show statistics such as fps and timing information
//        sceneView.showsStatistics = true
//        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
//        sceneView.debugOptions.insert(ARSCNDebugOptions.showWorldOrigin)
        
        // Load the scene
        let scene = SCNScene(named: "art.scnassets/world.scn")!
        sceneView.scene = scene
        
        executioner.controller = self
        currentInstruction = furniture?.instructions?.removeFirst()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        loadWorldTrackingConfiguration()
        
        currentSnapshot = ImageConverter().convertImageToPixelBuffer(image: sceneView.snapshot())

        // Setup the object detector
        detector = ObjectDetector()
        detector?.delegate = executioner
        
        classifier = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            let snapshot = self.sceneView.snapshot()
            let converter = ImageConverter()
            guard let pixelBuffer = converter.convertImageToPixelBuffer(image: snapshot) else { return }
            let result = self.predict(pixelBuffer: pixelBuffer)
            self.recognitionResultLabel.text = "\(result!.identifier): \(result!.confidence * 100)%"
        }
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
        tracker?.requestCancelTracking()
        tracker = nil
        classifier?.invalidate()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        tracker?.requestCancelTracking()
        tracker = nil
        print("Memory is full!")
    }
    
    // MARK: - UI Events
    
    @IBAction func messageViewButtonTapped(_ sender: UIButton)
    {
        nextInstruction()
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
    func trackingDidStop() {
        print("Tracking stopped!")
        DispatchQueue.main.async {
            self.overlayView.clearDisplay()
        }
    }
    
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
