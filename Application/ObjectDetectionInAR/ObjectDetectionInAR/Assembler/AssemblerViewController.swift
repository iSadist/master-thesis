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
    @IBOutlet weak var detectedPlanesProgressBar: UIProgressView!
    
    override var prefersStatusBarHidden: Bool { return true }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return .portrait }
    override var shouldAutorotate: Bool { return false }
    
    var furniture: Furniture?
    let executioner = InstructionExecutioner()
    var currentSnapshot: CVPixelBuffer? = nil
    var currentFrame: UIImage? = nil
    
    let metalDevice = MTLCreateSystemDefaultDevice()
    var model = AssemblerModel()

    func loadWorldTrackingConfiguration()
    {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]

        // All the objects that are tracked is contained in the Objects folder
//        guard let detectingObjects = ARReferenceObject.referenceObjects(inGroupNamed: "Objects", bundle: nil) else { return }
//        configuration.detectionObjects = detectingObjects
        
//        for imageURL in trackingImageURLs
//        {
//            guard let image: CGImage = UIImage(named: imageURL)?.cgImage else { return }
//            let referenceImage = ARReferenceImage(image, orientation: CGImagePropertyOrientation.up, physicalWidth: 0.3)
//            configuration.detectionImages.insert(referenceImage)
//        }
//
//        configuration.maximumNumberOfTrackedImages = trackingImageURLs.count
        
        sceneView.session.run(configuration)
    }
    
    func translateToWorldPoint(from screenPoint: CGPoint) -> SCNVector3?
    {
        let hitResult = sceneView.hitTest(screenPoint, types: .estimatedHorizontalPlane).first
        guard let position = hitResult?.worldTransform.columns.3 else { return nil }
        return SCNVector3(position.x, position.y, position.z)
    }
    
    func moveExistingNode(to newPosition: SCNVector3, name: String) -> SCNNode?
    {
        if let node = sceneView.scene.rootNode.childNode(withName: name, recursively: true)
        {
            node.runAction(SCNAction.move(to: newPosition, duration: 0.1))
            return node
        }
        
        return nil
    }
    
    func addFurniture(part: String, position: SCNVector3)
    {
        let node = GeometryFactory.makeFurniturePart(name: part)
        addNode(node, position, part)
    }
    
    func addNode(_ node: SCNNode, _ position: SCNVector3, _ name: String)
    {
        node.position = position
        node.name = name
        sceneView.scene.rootNode.addChildNode(node)
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
    
    func updateMessageView(_ instruction: Instruction?)
    {
        messageViewButton.isEnabled = model.isValid()
        messageViewButton.isHidden = !model.isValid() || instruction?.buttonText == nil
        messageViewText.text = model.isValid() ? instruction?.message : "Detecting the floor..."
        messageViewButton.setTitle(instruction?.buttonText, for: .normal)
        
        if model.instructionHasFailed
        {
            messageViewText.text = "Failed to complete instruction..."
            messageViewButton.setTitle("Try again?", for: .normal)
            messageViewButton.isHidden = false
        }
    }
    
    func modelUpdate()
    {
        updateMessageView(executioner.currentInstruction)
        updateProgressBar()
    }
    
    func updateProgressBar()
    {
        detectedPlanesProgressBar.progress = model.detectedPlaneProgress
        detectedPlanesProgressBar.isHidden = model.detectedPlaneProgress >= 1.0
    }
    
    // MARK: Lifecycle events
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        sceneView.delegate = self
        messageView.layer.cornerRadius = 25
        model.callback = modelUpdate
        
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
        
        // Setup instruction executioner
        executioner.delegate = self
        executioner.detector = detector
        executioner.instructions = furniture?.instructions
        executioner.nextInstruction()
        
        updateMessageView(executioner.currentInstruction)
    }

    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
        executioner.repeatTimer?.invalidate()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
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
            model.numberOfPlanesDetected += 1
            model.summedPlaneAreas = planeAnchor.extent.x * planeAnchor.extent.z
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
            model.summedPlaneAreas = planeAnchor.extent.x * planeAnchor.extent.z
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor)
    {
        if anchor is ARPlaneAnchor
        {
            model.numberOfPlanesDetected -= 1
        }
    }
}

extension AssemblerViewController: InstructionExecutionerDelegate
{
    func instructionFailed(_ instruction: Instruction?, error: Error?) {
        print("Instruction unable to complete")
        model.instructionHasFailed = true
        updateMessageView(instruction)
    }
    
    func newInstructionSet(_ instruction: Instruction?)
    {
        if instruction is ScanInstruction { removeAllNodes() }
        updateMessageView(instruction)
    }
    
    func instructionCompleted()
    {
        executioner.nextInstruction()
    }
    
    func instructionCompleted(andFound objects: [ObjectRectangle])
    {
        for object in objects
        {
            let rectangle = object.getRect()
            let screenPoint = CGPoint(x: rectangle.midX, y: rectangle.midY)
            guard let worldPosition = translateToWorldPoint(from: screenPoint) else { return }
            
            addFurniture(part: object.name!, position: worldPosition)
        }
        executioner.nextInstruction()
    }
    
    func getPixelBuffer() -> CVPixelBuffer?
    {
        let snapshot = sceneView.snapshot()
        let converter = ImageConverter()
        
        return converter.convertImageToPixelBuffer(image: snapshot)
    }
}
