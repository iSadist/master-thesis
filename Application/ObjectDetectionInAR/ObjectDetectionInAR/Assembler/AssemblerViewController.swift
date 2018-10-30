/*
 AssemblerViewController
 
 This class is responsible for all interactions in the AR Scene, such as plane detection,
 hittests, rendering virtual objects etc. It also holds the object detector and tracker
 and sets them up in the beginning.
 
 AssemblerViewController also has a furniture that is set before ViewDidLoad
 and uses InstructionExecutioner for instruction handling, although it steps through
 the instructions on its own.
 */

import UIKit
import SceneKit
import ARKit
import Vision

class AssemblerViewController: UIViewController
{
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var overlayView: OverlayView!
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
    var currentSnapshot: CVPixelBuffer? = nil
    var currentFrame: UIImage? = nil
    

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

        // All the objects that are tracked is contained in the Objects folder
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
    

    /* Insert the bounding boxes of the objects that are
     of interest to track and start tracking immediately.*/
    func startTracking(on boundingBoxes: [CGRect])
    {
        tracker = ObjectTracker(objects: boundingBoxes, overlay: overlayView)
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


     /* Draws an arrow between two point in the 3D scene by inputting the
     points on the screen where the objects exist.
     Only draws arrows on the detected plane. */
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
        lineNode.name = "connectingArrow"
        
        sceneView.scene.rootNode.addChildNode(lineNode)
        
    }
    
    func removeAllNodes()
    {
        for node in sceneView.scene.rootNode.childNodes
        {
            node.removeFromParentNode()
        }
    }
    
    func removeNode(named: String) -> Bool
    {
        if let node = sceneView.scene.rootNode.childNode(withName: named, recursively: false)
        {
            node.removeFromParentNode()
            return true
        }
        
        return false
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

        // Setup the object detector
        detector = ObjectDetector()
        detector?.delegate = executioner
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
    // Called whenever Object Tracker stopped tracking
    func trackingDidStop()
    {
        print("Tracking stopped!")
        DispatchQueue.main.async {
            self.overlayView.clearDisplay()
        }
    }
    
    // Called when some rects are meant to be displayed on the screen
    func displayRects(rects: [CGRect])
    {
        DispatchQueue.main.async {
            self.overlayView.storeVisionRects(rects: rects)
            self.overlayView.setNeedsDisplay()
        }
    }
    
    // Called when Object Tracker 
    func getFrame() -> CVPixelBuffer?
    {
        DispatchQueue.main.async {
            let converter = ImageConverter()
            self.currentSnapshot = converter.convertImageToPixelBuffer(image: self.sceneView.snapshot())
        }
        return currentSnapshot
    }
}
