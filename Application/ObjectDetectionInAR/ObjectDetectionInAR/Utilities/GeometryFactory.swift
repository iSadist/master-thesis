/*
 A class for collecting code that creates nodes with specific geometry
 */

import SceneKit
import ARKit

class GeometryFactory
{
    static func makeSphere() -> SCNNode
    {
        let geometry = SCNSphere(radius: 0.05)
        let textureImage = UIImage(named: "stone_diffuse.jpg")
        let normalImage = UIImage(named: "stone_normal.jpg")
        geometry.firstMaterial?.diffuse.contents = textureImage
        geometry.firstMaterial?.normal.contents = normalImage
        let node = SCNNode(geometry: geometry)
        return node
    }
    
    static func makeCube() -> SCNNode
    {
        let geometry = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        let textureImage = UIImage(named: "stone_diffuse.jpg")
        let normalImage = UIImage(named: "stone_normal.jpg")
        geometry.firstMaterial?.diffuse.contents = textureImage
        geometry.firstMaterial?.normal.contents = normalImage
        let node = SCNNode(geometry: geometry)
        return node
    }
    
    static func makeText(text: String) -> SCNNode
    {
        let geometry = SCNText(string: text, extrusionDepth: 5)
        
        let width = geometry.boundingBox.max.x * 0.005
        
        let textNode = SCNNode(geometry: geometry)
        textNode.scale = SCNVector3(x: 0.005, y: 0.005, z: 0.005)
        textNode.position.x = -width / 2
        
        let node = SCNNode()
        node.addChildNode(textNode)
        return node
    }
    
    static func makeLine(radius: Float, length: Float) -> SCNNode
    {
        let cylinderLength = length * 0.8
        let coneLength = length * 0.2
        
        // Make the line segment
        let cylinder = SCNCylinder(radius: CGFloat(radius), height: CGFloat(cylinderLength))
        cylinder.firstMaterial?.diffuse.contents = UIImage(named: "light_wood.jpg")
        let cylinderNode = SCNNode(geometry: cylinder)
        cylinderNode.position.y = cylinderLength / 2
        
        // Place an arrow head at the end
        let cone = SCNCone(topRadius: CGFloat(radius / 6), bottomRadius: CGFloat(radius * 2), height: CGFloat(coneLength))
        cone.firstMaterial?.diffuse.contents = UIImage(named: "metal.jpg")
        cone.firstMaterial?.metalness.contents = 0.5
        let coneNode = SCNNode(geometry: cone)
        coneNode.position.y = cylinderLength
        
        let node = SCNNode()
        node.addChildNode(cylinderNode)
        node.addChildNode(coneNode)
        return node
    }
    
    static func createPlane(planeAnchor: ARPlaneAnchor, metalDevice: MTLDevice) -> SCNNode
    {
        let planeGeometry = ARSCNPlaneGeometry(device: metalDevice)
        planeGeometry?.update(from: planeAnchor.geometry)
        
        let planeNode = SCNNode(geometry: planeGeometry)
        planeNode.opacity = 0.03
        
        return planeNode
    }

    static func makeSeat() -> SCNNode
    {
        let node = SCNNode()
        let seatNode = SCNScene(named: "art.scnassets/nolmyraSeat.scn")?.rootNode.childNode(withName: "seat", recursively: false)
        node.addChildNode(seatNode!)
        return node
    }
    
    static func makeFurniturePart(name: String) -> SCNNode
    {
        var furnitureNode: SCNNode
        
        switch name
        {
        case NOLMYRA_PIECE1:
            furnitureNode = (SCNScene(named: "art.scnassets/nolmyraPiece1.scn")?.rootNode.childNode(withName: NOLMYRA_PIECE1, recursively: false))!

            let realWidth: Float = 0.05
            let realLength: Float = 0.57
            let realHeigth: Float = 0.02
            furnitureNode.scale.x = realWidth/furnitureNode.boundingBox.max.x
            furnitureNode.scale.y = realLength/furnitureNode.boundingBox.max.y
            furnitureNode.scale.z = realHeigth/furnitureNode.boundingBox.max.z
            break
        case NOLMYRA_PIECE2:
            furnitureNode = (SCNScene(named: "art.scnassets/nolmyraPiece2.scn")?.rootNode.childNode(withName: NOLMYRA_PIECE2, recursively: false))!
            let realWidth: Float = 0.43
            let realLength: Float = 0.61
            let realHeigth: Float = 0.05
            furnitureNode.scale.x = realWidth/furnitureNode.boundingBox.max.x
            furnitureNode.scale.y = realLength/furnitureNode.boundingBox.max.y
            furnitureNode.scale.z = realHeigth/furnitureNode.boundingBox.max.z
            
            break
        case NOLMYRA_CONJOINED_PIECE1:
            furnitureNode = (SCNScene(named: "art.scnassets/nolmyraConjoinedPiece1.scn")?.rootNode.childNode(withName: NOLMYRA_CONJOINED_PIECE1, recursively: false))!
            let realWidth: Float = 0.43
            let realLength: Float = 0.61
            let realHeigth: Float = 0.62
            furnitureNode.scale.x = realWidth/furnitureNode.boundingBox.max.x
            furnitureNode.scale.y = realLength/furnitureNode.boundingBox.max.y
            furnitureNode.scale.z = realHeigth/furnitureNode.boundingBox.max.z
            
            break
        case NOLMYRA_CONJOINED_PIECE2:
            furnitureNode = (SCNScene(named: "art.scnassets/nolmyraConjoinedPiece2.scn")?.rootNode.childNode(withName: NOLMYRA_CONJOINED_PIECE2, recursively: false))!
            let realWidth: Float = 0.43
            let realLength: Float = 0.61
            let realHeigth: Float = 0.62
            furnitureNode.scale.x = realWidth/furnitureNode.boundingBox.max.x
            furnitureNode.scale.y = realLength/furnitureNode.boundingBox.max.y
            furnitureNode.scale.z = realHeigth/furnitureNode.boundingBox.max.z
            
            break
        case NOLMYRA_CONJOINED_PIECE3:
            furnitureNode = (SCNScene(named: "art.scnassets/nolmyraConjoinedPiece3.scn")?.rootNode.childNode(withName: NOLMYRA_CONJOINED_PIECE3, recursively: false))!
            let realWidth: Float = 0.43
            let realLength: Float = 0.61
            let realHeigth: Float = 0.67
            furnitureNode.scale.x = realWidth/furnitureNode.boundingBox.max.x
            furnitureNode.scale.y = realLength/furnitureNode.boundingBox.max.y
            furnitureNode.scale.z = realHeigth/furnitureNode.boundingBox.max.z
            
            break
        case NOLMYRA_SEAT:
            furnitureNode = (SCNScene(named: "art.scnassets/nolmyraSeat.scn")?.rootNode.childNode(withName: NOLMYRA_SEAT, recursively: false))!
            let realWidth: Float = 0.62
            let realLength: Float = 0.45
            let realHeigth: Float = 0.72
            furnitureNode.scale.x = realWidth/furnitureNode.boundingBox.max.x
            furnitureNode.scale.y = realLength/furnitureNode.boundingBox.max.y
            furnitureNode.scale.z = realHeigth/furnitureNode.boundingBox.max.z
            
            break
        default:
            furnitureNode = SCNNode()
            break
        }
        let node = SCNNode()
        node.addChildNode(furnitureNode)
        return node
    }
}
