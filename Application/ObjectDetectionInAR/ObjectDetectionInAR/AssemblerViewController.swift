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
    var tracker: ObjectTracker?
    var detector: ObjectDetector?
    var trackingRect = [CGRect]()
    var currentSnapshot: CVPixelBuffer? = nil
    var currentFrame: UIImage? = nil
    
    var currentInstruction: Instruction?
    {
        willSet
        {
            messageViewText.text = newValue?.message
            messageViewButton.setTitle(newValue?.buttonText, for: .normal)
            messageViewButton.isHidden = newValue?.buttonText == nil
            messageView.isHidden = newValue == nil
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
    
    // MARK: Lifecycle events
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        sceneView.delegate = self
        messageView.layer.cornerRadius = 25
        
        let instruction = Instruction(message: "Scan the floor", buttonText: nil)
        currentInstruction = instruction
        
        // Show statistics such as fps and timing information
//        sceneView.showsStatistics = true
//        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
//        sceneView.debugOptions.insert(ARSCNDebugOptions.showWorldOrigin)
        
        // Load the scene
        let scene = SCNScene(named: "art.scnassets/world.scn")!
        sceneView.scene = scene
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        loadWorldTrackingConfiguration()
        
        currentSnapshot = ImageConverter().convertImageToPixelBuffer(image: sceneView.snapshot())
        // Setup the object detector
        detector = ObjectDetector()
        detector?.delegate = self
        detector?.findObjects(frame: UIImage()) // TODO: Add the real frame when detector is implemeted!
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
        
        let instruction = Instruction(message: "Put together the leg and seat", buttonText: "Next")
        currentInstruction = instruction
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
        
        let converter = ImageConverter()
        guard currentSnapshot != nil else { return currentSnapshot }
        let image = converter.convertPixelBufferToUIImage(pixelBuffer: currentSnapshot!)
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        return currentSnapshot
    }
}

extension AssemblerViewController: ObjectDetectorDelegate
{
    // Called when the ObjectDetector has found some objects
    func objectsFound(objects rects: [CGRect], error: String?)
    {
        for rect in rects
        {
            addTrackingRect(rect: rect)
        }
        startTracking()
    }
    
    func getFrame() -> UIImage?
    {
        DispatchQueue.main.async {
            self.currentFrame = self.sceneView.snapshot()
        }
        
        return currentFrame
    }
}
