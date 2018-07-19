//
//  ViewController.swift
//  ObjectDetectionInAR
//
//  Created by Jan Svensson on 2018-05-28.
//  Copyright © 2018 Jan Svensson. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override var prefersStatusBarHidden: Bool { return true }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return .portrait }
    override var shouldAutorotate: Bool { return false }
    
    var addingSphere = false
    
    @IBAction func sceneLongPressed(_ sender: UILongPressGestureRecognizer) {
        if let camera = self.sceneView.pointOfView {
            let localPosition = SCNVector3(x: 0, y: 0, z: -0.5)
            let scenePosition = camera.convertPosition(localPosition, to: nil)
            addSphere(point: scenePosition)
        }
    }
    
    @IBAction func scenePressed(_ sender: UITapGestureRecognizer) {
        if let camera = self.sceneView.pointOfView {
            let localPosition = SCNVector3(x: 0, y: 0, z: -1)
            let scenePosition = camera.convertPosition(localPosition, to: nil)
            addSphere(point: scenePosition)
        }
    }
    
    func addSphere(point: SCNVector3) {
        if addingSphere { return }
        
        addingSphere = true
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2, execute: {
            self.addingSphere = false
        })
        
        let geometry = SCNSphere(radius: 0.2)
        let textureImage = UIImage(named: "stone_diffuse.jpg")
        let normalImage = UIImage(named: "stone_normal.jpg")
        geometry.firstMaterial?.diffuse.contents = textureImage
        geometry.firstMaterial?.normal.contents = normalImage
        let node = SCNNode(geometry: geometry)
        node.physicsBody = createPhysicsBody(geometry: geometry)
        node.position = point
        
        node.physicsBody?.velocity = (sceneView.pointOfView?.convertVector(SCNVector3(x: 0, y: 0, z: -1), to: nil))!
        
        self.sceneView.scene.rootNode.addChildNode(node)
    }
    
    func createPhysicsBody(geometry: SCNGeometry) -> SCNPhysicsBody {
        let shape = SCNPhysicsShape(geometry: geometry, options: nil)
        let body = SCNPhysicsBody(type: .dynamic, shape: shape)
        return body
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/world.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
