import SceneKit

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
        let node = SCNNode(geometry: geometry)
        node.scale = SCNVector3(x: 0.005, y: 0.005, z: 0.005)
        return node
    }
    
    static func makeLine(radius: Float, length: Float) -> SCNNode
    {
        let cylinderLength = length * 0.8
        let coneLength = length * 0.2
        
        // Make the line segment
        let cylinder = SCNCylinder(radius: CGFloat(radius), height: CGFloat(cylinderLength))
        cylinder.firstMaterial?.diffuse.contents = UIColor.blue
        let cylinderNode = SCNNode(geometry: cylinder)
        cylinderNode.position.y = cylinderLength / 2
        
        // Place an arrow head at the end
        let cone = SCNCone(topRadius: CGFloat(radius / 6), bottomRadius: CGFloat(radius * 2), height: CGFloat(coneLength))
        let coneNode = SCNNode(geometry: cone)
        coneNode.position.y = cylinderLength
        
        let node = SCNNode()
        node.addChildNode(cylinderNode)
        node.addChildNode(coneNode)
        return node
    }
}
