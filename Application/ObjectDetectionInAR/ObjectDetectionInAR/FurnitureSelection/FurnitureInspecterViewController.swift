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
    
    var cameraDistance: Float = 5.0
    var cameraAngle: Float = 0.0
    var cameraHeight: Float = 0.634
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        var scene: SCNScene?
        
        if let furnitureName = furniture?.name
        {
            scene = SCNScene(named: "art.scnassets/\(furnitureName).scn")
            modelNode = scene?.rootNode.childNode(withName: furnitureName, recursively: false)
        }
        else
        {
            scene = SCNScene(named: "art.scnassets/ship.scn")!
            modelNode = scene?.rootNode.childNode(withName: "ship", recursively: false)?.childNodes.first
        }
        
        cameraNode = scene?.rootNode.childNode(withName: "camera", recursively: false)
        sceneView.scene = scene
    }

    @IBAction func panGesture(_ sender: UIPanGestureRecognizer)
    {
        let velocity = sender.velocity(in: sceneView)
        cameraAngle += Float(velocity.x * panSpeedRatio)
        updateCameraPosition()
    }

    @IBAction func pinchGesture(_ sender: UIPinchGestureRecognizer)
    {
        cameraDistance += Float(sender.velocity * pinchSpeedRatio)
        updateCameraPosition()
    }
    
    func updateCameraPosition()
    {
        // Using cylindrical coordinates
        let newPosition = SCNVector3(x: cameraDistance*cos(cameraAngle), y: cameraHeight, z: cameraDistance*sin(cameraAngle))

        cameraNode?.position = newPosition
        cameraNode?.look(at: modelNode!.position, up: SCNVector3(0, 1, 0), localFront: SCNVector3(0, 0, -1))
    }
}
