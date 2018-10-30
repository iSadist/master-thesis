import SceneKit

extension SCNVector3
{
    func distanceTo(_ vector: SCNVector3) -> Float
    {
        return sqrt(pow(vector.x - self.x, 2) + pow(vector.y - self.y, 2) + pow(vector.z - self.z, 2))
    }
}

extension CGRect
{
    func IoU(other: CGRect) -> Float
    {
        let intersection = self.intersection(other)
        let union = self.union(other)
        return Float((intersection.width * intersection.height) / (union.width * union.height))
    }
}
