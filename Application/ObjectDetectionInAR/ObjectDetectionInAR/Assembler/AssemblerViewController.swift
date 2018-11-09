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
    let executioner = InstructionExecutioner()
    var currentSnapshot: CVPixelBuffer? = nil
    var currentFrame: UIImage? = nil
    
    let metalDevice = MTLCreateSystemDefaultDevice()
    var model = AssemblerModel()

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
    
    func connectParts(rects: [CGRect])
    {
        var shouldConnectPieces = false
        var lastRect: CGRect = CGRect()
        
        for rect in rects
        {
            if shouldConnectPieces
            {
                // For every second rect, connect with the previous one
                let firstMidpoint = CGPoint(x: lastRect.midX, y: lastRect.midY)
                let secondMidpoint = CGPoint(x: rect.midX, y: rect.midY)
                connectPieces(fromScreen: firstMidpoint, to: secondMidpoint)
            }
            
            lastRect = rect
            shouldConnectPieces = !shouldConnectPieces
        }
    }
    
    func connectParts(rects: [CGRect], with message: String)
    {
        self.connectParts(rects: rects)
        let node = GeometryFactory.makeText(text: message)
        
        // Figure out where to render the text
        let renderPoint = CGPoint(x: rects.first!.midX, y: rects.first!.midY)
        let worldPoint = self.sceneView.hitTest(renderPoint, types: .existingPlane).first?.worldTransform.columns.3
        let vector = SCNVector3(worldPoint!.x, worldPoint!.y, worldPoint!.z)
        
        node.position = vector
        node.constraints = [SCNBillboardConstraint()]
        self.sceneView.scene.rootNode.addChildNode(node)
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
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        loadWorldTrackingConfiguration()

        // Setup the object detector
        let detector = ObjectDetector(frame: overlayView.frame)
        detector.delegate = executioner
        
        // Setup the object tracker
        let tracker = ObjectTracker(viewFrame: overlayView.frame)
        tracker.delegate = self
        
        // Setup instruction executioner
        executioner.delegate = self
        executioner.detector = detector
        executioner.tracker = tracker
        executioner.instructions = furniture?.instructions
        executioner.nextInstruction()
    }

    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
        executioner.tracker?.requestCancelTracking()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        executioner.tracker?.requestCancelTracking()
        print("Memory is full!")
    }
    
    // MARK: - UI Events
    
    @IBAction func messageViewButtonTapped(_ sender: UIButton)
    {
        if model.instructionHasFailed
        {
            // Execute the same instruction that failed last time
            model.instructionHasFailed = false
            executioner.executeInstruction()

            // Hide the button again to not complete an instruction
            // while not ready
            messageViewButton.isHidden = true
            messageViewText.text = executioner.currentInstruction?.message
        }
        else
        {
            executioner.nextInstruction()
        }
    }
}

extension AssemblerViewController: ARSCNViewDelegate
{
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor)
    {
        if let objectAnchor = anchor as? ARObjectAnchor
        {
            let objectName = objectAnchor.referenceObject.name!
            let textNode = GeometryFactory.makeText(text: objectName)
            node.addChildNode(textNode)
        }
        else if let planeAnchor = anchor as? ARPlaneAnchor
        {
            node.addChildNode(GeometryFactory.createPlane(planeAnchor: planeAnchor, metalDevice: metalDevice!))
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor)
    {
        if let planeAnchor = anchor as? ARPlaneAnchor
        {
            node.enumerateChildNodes { (childNode, _) in
                childNode.removeFromParentNode()
            }
            node.addChildNode(GeometryFactory.createPlane(planeAnchor: planeAnchor, metalDevice: metalDevice!))
        }
    }
}

extension AssemblerViewController: ObjectTrackerDelegate
{
    // Called when the Object tracker outputs new rects for the tracked objects
    func trackedRects(rects: [ObjectRectangle])
    {
        for node in self.sceneView.scene.rootNode.childNodes
        {
            node.removeFromParentNode()
        }
        model.objectsOnScreen = rects
        
        // Put the bounding box rects in the rectangles list
        // and connect them
        var rectangles = [CGRect]()
        for objectRect in rects
        {
            rectangles.append(objectRect.getRect())
        }
        
        connectParts(rects: rectangles)
    }
    
    // Called whenever Object Tracker stopped tracking
    func trackingDidStop()
    {
        print("Tracking stopped!")
        DispatchQueue.main.async {
            self.overlayView.clearDisplay()
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

extension AssemblerViewController: InstructionExecutionerDelegate
{
    func instructionFailed(error: Error?) {
        print("Instruction unable to complete")
        messageViewText.text = "Failed to complete instruction..."
        messageViewButton.setTitle("Try again?", for: .normal)
        messageViewButton.isHidden = false
        model.instructionHasFailed = true
    }
    
    func newInstructionSet(_ instruction: Instruction?)
    {
        messageViewText.text = instruction?.message
        messageViewButton.setTitle(instruction?.buttonText, for: .normal)
        messageViewButton.isHidden = instruction?.buttonText == nil
        messageView.isHidden = instruction == nil
    }
    
    func instructionCompleted()
    {
        executioner.nextInstruction()
    }
    
    func getFrame() -> UIImage?
    {
        return sceneView.snapshot()
    }
}
