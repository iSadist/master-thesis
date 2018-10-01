import UIKit
import SceneKit

class FurnitureInspecterViewController: UIViewController
{
    @IBOutlet weak var sceneView: SCNView!
    var cameraConfiguration: SCNCameraControlConfiguration?
    var modelNode: SCNNode?
    var cameraNode: SCNNode?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        modelNode = scene.rootNode.childNode(withName: "ship", recursively: false)?.childNodes.first
        cameraNode = scene.rootNode.childNode(withName: "camera", recursively: false)
        cameraNode?.constraints = [SCNLookAtConstraint(target: modelNode)]
        sceneView.scene = scene
    }

    @IBAction func panGesture(_ sender: UIPanGestureRecognizer)
    {
        let velocity = sender.velocity(in: sceneView)
        modelNode?.runAction(SCNAction.rotateBy(x: -velocity.y/5000, y: velocity.x/5000, z: 0, duration: 0.1))
    }

    @IBAction func pinchGesture(_ sender: UIPinchGestureRecognizer)
    {
        print(sender.velocity)
        let vector = SCNVector3(0, 0, sender.velocity/50)
        let action = SCNAction.move(by: vector, duration: 0.1)
        modelNode?.runAction(action)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
