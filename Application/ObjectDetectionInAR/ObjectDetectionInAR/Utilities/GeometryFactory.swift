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
}
