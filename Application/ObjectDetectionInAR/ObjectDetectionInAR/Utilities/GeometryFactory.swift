/*
 A class for collecting code that creates nodes with specific geometry
 */

import SceneKit
import ARKit
import UIKit

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
    
    static func makeSquare(width: Float) -> SCNNode
    {
        let geometry = SCNPlane(width: CGFloat(width), height: CGFloat(width))
        geometry.firstMaterial?.diffuse.contents =  #colorLiteral(red: 0.2468146832, green: 0.827173737, blue: 0.2179623374, alpha: 1)
        let squareNode = SCNNode(geometry: geometry)
        squareNode.eulerAngles.x = -Float.pi/2
        let node = SCNNode()
        node.opacity = (0.1)
        node.addChildNode(squareNode)
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
    
    static private func setRealLengths( realLengths:  SCNVector3, boundingBox: (min: SCNVector3, max: SCNVector3)) -> SCNVector3
    {
        let x = realLengths.x / (boundingBox.max.x - boundingBox.min.x)
        let y = realLengths.y / (boundingBox.max.y - boundingBox.min.y)
        let z = realLengths.z / (boundingBox.max.z - boundingBox.min.z)
        return SCNVector3(x,y,z)
    }
    
    static func makeFurniturePart(name: String) -> SCNNode
    {
        var furnitureNode: SCNNode
        let realLengths = Database.instance.getMeasurements(forPart: name)

        switch name
        {
        case NOLMYRA_PIECE1:
            furnitureNode = (SCNScene(named: "art.scnassets/nolmyraPiece1.scn")?.rootNode.childNode(withName: NOLMYRA_PIECE1, recursively: false))!
            furnitureNode.scale = setRealLengths(realLengths: realLengths, boundingBox: furnitureNode.boundingBox)
            furnitureNode.eulerAngles.x = Float.pi
            
            let screwAnchorPoint = SCNNode()
            screwAnchorPoint.name = SCREW_ANCHOR_POINT
            screwAnchorPoint.position.z = -0.01 / furnitureNode.scale.z
            screwAnchorPoint.position.y = 0.025 / furnitureNode.scale.y
            screwAnchorPoint.position.x = -0.02 / furnitureNode.scale.x
            furnitureNode.addChildNode(screwAnchorPoint)
            break
        case NOLMYRA_PIECE2:
            furnitureNode = (SCNScene(named: "art.scnassets/nolmyraPiece2.scn")?.rootNode.childNode(withName: NOLMYRA_PIECE2, recursively: false))!
            furnitureNode.scale = setRealLengths(realLengths: realLengths, boundingBox: furnitureNode.boundingBox)
            
            let anchorPoint = SCNNode()
            anchorPoint.position.z = -0.30 / furnitureNode.scale.z
            anchorPoint.position.y = -0.06 / furnitureNode.scale.y
            anchorPoint.name = ANCHOR_POINT
            furnitureNode.addChildNode(anchorPoint)
            break
        case NOLMYRA_CONJOINED_PIECE1:
            furnitureNode = (SCNScene(named: "art.scnassets/nolmyraConjoinedPiece1.scn")?.rootNode.childNode(withName: NOLMYRA_CONJOINED_PIECE1, recursively: false))!
            furnitureNode.scale = setRealLengths(realLengths: realLengths, boundingBox: furnitureNode.boundingBox)
            let anchorPoint = SCNNode()
            anchorPoint.position.z = -0.22 / furnitureNode.scale.z
            anchorPoint.position.y = -0.505 / furnitureNode.scale.y
            anchorPoint.name = ANCHOR_POINT
            furnitureNode.addChildNode(anchorPoint)
            break
        case NOLMYRA_CONJOINED_PIECE2:
            furnitureNode = (SCNScene(named: "art.scnassets/nolmyraConjoinedPiece2.scn")?.rootNode.childNode(withName: NOLMYRA_CONJOINED_PIECE2, recursively: false))!
            furnitureNode.scale = setRealLengths(realLengths: realLengths, boundingBox: furnitureNode.boundingBox)
            let anchorPoint = SCNNode()
            anchorPoint.position.z = -0.30 / furnitureNode.scale.z
            anchorPoint.position.y = -0.055 / furnitureNode.scale.y
            anchorPoint.position.x = 0.57 / furnitureNode.scale.x
            anchorPoint.name = ANCHOR_POINT
            furnitureNode.addChildNode(anchorPoint)
            break
        case NOLMYRA_CONJOINED_PIECE3:
            furnitureNode = (SCNScene(named: "art.scnassets/nolmyraConjoinedPiece3.scn")?.rootNode.childNode(withName: NOLMYRA_CONJOINED_PIECE3, recursively: false))!
            furnitureNode.scale = setRealLengths(realLengths: realLengths, boundingBox: furnitureNode.boundingBox)
            let anchorPoint = SCNNode()
            anchorPoint.position.z = -0.40 / furnitureNode.scale.z
            anchorPoint.position.y = -0.14 / furnitureNode.scale.y
            anchorPoint.name = ANCHOR_POINT
            furnitureNode.addChildNode(anchorPoint)
            break
        case NOLMYRA_SEAT:
            furnitureNode = (SCNScene(named: "art.scnassets/nolmyraSeat.scn")?.rootNode.childNode(withName: NOLMYRA_SEAT, recursively: false))!
            furnitureNode.scale = setRealLengths(realLengths: realLengths, boundingBox: furnitureNode.boundingBox)
            let anchorPoint = SCNNode()
            anchorPoint.position.z = -0.36 / furnitureNode.scale.z
            anchorPoint.position.y = -0.06 / furnitureNode.scale.y
            anchorPoint.position.x = -0.305 / furnitureNode.scale.x
            anchorPoint.name = ANCHOR_POINT
            furnitureNode.addChildNode(anchorPoint)
            break
        default:
            furnitureNode = SCNNode()
            break
        }
        let node = SCNNode()
        node.addChildNode(furnitureNode)
        return node
    }
    
    static func makeScrew1() -> SCNNode
    {
        let node = SCNNode()
        let screwNode = (SCNScene(named: "art.scnassets/nolmyraScrew1.scn")?.rootNode.childNode(withName: NOLMYRA_SCREW1, recursively: false))!
        let measurements = Database.instance.getMeasurements(forPart: NOLMYRA_SCREW1)
        screwNode.scale = setRealLengths(realLengths: measurements, boundingBox: screwNode.boundingBox)
        node.addChildNode(screwNode)
        return node
    }
    
    static func makeScrew2() -> SCNNode
    {
        let node = SCNNode()
        let screwNode = (SCNScene(named: "art.scnassets/nolmyraScrew2.scn")?.rootNode.childNode(withName: NOLMYRA_SCREW2, recursively: false))!
        let measurements = Database.instance.getMeasurements(forPart: NOLMYRA_SCREW2)
        screwNode.scale = setRealLengths(realLengths: measurements, boundingBox: screwNode.boundingBox)
        node.addChildNode(screwNode)
        return node
    }
}
