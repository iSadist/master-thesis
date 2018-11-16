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

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()
        
        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }
    
    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}

extension SCNVector3
{
    func substract(other: SCNVector3) -> SCNVector3
    {
        return SCNVector3(self.x - other.x , self.y - other.y , self.z - other.z)
    }
}
