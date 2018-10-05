import UIKit
import SceneKit

private let pinchSpeedRatio: CGFloat = 1.0 / 50.0
private let panSpeedRatio: CGFloat = 1.0 / 5000.0

class FurnitureInspecterViewController: UIViewController
{
    @IBOutlet weak var sceneView: SCNView!
    var cameraConfiguration: SCNCameraControlConfiguration?
    var modelNode: SCNNode?
    var cameraNode: SCNNode?
    var furniture: Furniture?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        var scene: SCNScene
        
        if let furnitureName = furniture?.name
        {
            scene = SCNScene(named: "art.scnassets/\(furnitureName).scn")!
            modelNode = scene.rootNode.childNode(withName: furnitureName, recursively: false)
        }
        else
        {
            scene = SCNScene(named: "art.scnassets/ship.scn")!
            modelNode = scene.rootNode.childNode(withName: "ship", recursively: false)?.childNodes.first
        }
        
        cameraNode = scene.rootNode.childNode(withName: "camera", recursively: false)
        cameraNode?.constraints = [SCNLookAtConstraint(target: modelNode)]
        sceneView.scene = scene
    }

    @IBAction func panGesture(_ sender: UIPanGestureRecognizer)
    {
        let velocity = sender.velocity(in: sceneView)
        modelNode?.runAction(SCNAction.rotateBy(x: -velocity.y * pinchSpeedRatio, y: velocity.x * pinchSpeedRatio, z: 0, duration: 0.1))
    }

    @IBAction func pinchGesture(_ sender: UIPinchGestureRecognizer)
    {
        let vector = SCNVector3(0, 0, sender.velocity * panSpeedRatio)
        let action = SCNAction.move(by: vector, duration: 0.1)
        modelNode?.runAction(action)
    }
}
