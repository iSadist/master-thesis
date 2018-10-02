import UIKit

class FurnitureCollection
{
    var furnitures: [Furniture] = []
    
    init()
    {
        furnitures.append(Furniture(name: "Nolmyra", id: "102.335.32", description: "Fåtöljen är lätt och därför enkel att flytta när du vill tvätta golvet eller möblera om.", icon: UIImage(named: "nolmyra")!))
    }
}
