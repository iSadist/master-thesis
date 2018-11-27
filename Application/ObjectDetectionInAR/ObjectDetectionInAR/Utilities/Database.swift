/*
 The database class provides information to the whole app about the furnitures.
 The database is supposed to make calls to fetch that information.
 */

import Foundation
import UIKit
import SceneKit

class Database
{
    static var instance = Database()
    
    init()
    {
        // Implement a connection to a server
    }
    
    func getFurnitures() -> [Furniture]
    {
        var collection: [Furniture] = []
        
        // Hardcoded furnitures can easily be changed to get data with a request
        
        collection.append(Furniture(name: "Nolmyra", id: "102.335.32", description: "Fåtöljen är lätt och därför enkel att flytta när du vill tvätta golvet eller möblera om.", icon: UIImage(named: "nolmyra")!))
        collection.append(Furniture(name: "Havsta", id: "604.041.97", description: "Massivt trä med hantverksdetaljer och borstad yta gör att satsbordet HAVSTA ger en genuin känsla och charm till ditt rum. Du kan använda dem var för sig eller skjuta ihop dem för att spara plats.", icon: UIImage(named: "havsta")!))
        collection.append(Furniture(name: "Brusali", id: "703.022.97", description: "Flyttbara hyllplan; anpassa avstånd efter behov. Kabeluttag gör det enklare att dra ut kablar på baksidan, så att de är dolda men samtidigt enkla att komma åt när du behöver dem.", icon: UIImage(named: "brusali")!))
        collection.append(Furniture(name: "Dalshult", id: "991.615.55", description: "Bordsskivan i melamin är fukttålig, fläcktålig och lätt att hålla ren.", icon: UIImage(named: "dalshult")!))
        collection.append(Furniture(name: "Malsjö", id: "603.034.81", description: "Glasdörrar håller dina favoriter dammfria men synliga. Välarbetade detaljer ger möbeln en påtaglig hantverkskaraktär.", icon: UIImage(named: "malsjo")!))
        collection.append(Furniture(name: "Säbövik", id: "292.394.59", description: "I den här kompletta sängen har madrassen bonnellresårer som ger hela kroppen ett fast stöd så att du kan sova gott hela natten. Och alla delar ryms i två platta paket och en rulle. Smidigt, eller hur?", icon: UIImage(named: "sabovik")!))
        collection.append(Furniture(name: "Bosse", id: "700.872.12", description: "Lätt att flytta tack vare hålet i sitsen. Massivt trä är ett slitstarkt naturmaterial.", icon: UIImage(named: "bosse")!))
        collection.append(Furniture(name: "Havsta", id: "604.041.97", description: "Massivt trä med hantverksdetaljer och borstad yta gör att satsbordet HAVSTA ger en genuin känsla och charm till ditt rum. Du kan använda dem var för sig eller skjuta ihop dem för att spara plats.", icon: UIImage(named: "havsta")!))
        collection.append(Furniture(name: "Brusali", id: "703.022.97", description: "Flyttbara hyllplan; anpassa avstånd efter behov. Kabeluttag gör det enklare att dra ut kablar på baksidan, så att de är dolda men samtidigt enkla att komma åt när du behöver dem.", icon: UIImage(named: "brusali")!))
        collection.append(Furniture(name: "Dalshult", id: "991.615.55", description: "Bordsskivan i melamin är fukttålig, fläcktålig och lätt att hålla ren.", icon: UIImage(named: "dalshult")!))
        collection.append(Furniture(name: "Malsjö", id: "603.034.81", description: "Glasdörrar håller dina favoriter dammfria men synliga. Välarbetade detaljer ger möbeln en påtaglig hantverkskaraktär.", icon: UIImage(named: "malsjo")!))
        collection.append(Furniture(name: "Säbövik", id: "292.394.59", description: "I den här kompletta sängen har madrassen bonnellresårer som ger hela kroppen ett fast stöd så att du kan sova gott hela natten. Och alla delar ryms i två platta paket och en rulle. Smidigt, eller hur?", icon: UIImage(named: "sabovik")!))
        collection.append(Furniture(name: "Bosse", id: "700.872.12", description: "Lätt att flytta tack vare hålet i sitsen. Massivt trä är ett slitstarkt naturmaterial.", icon: UIImage(named: "bosse")!))
        
        return collection
    }
    
    func getInstructions(for furniture: Furniture) -> [Instruction]?
    {
        switch furniture.name
        {
        case "Nolmyra":
            var nolmyraInstructions = [Instruction]()
            nolmyraInstructions.append(Instruction(message: "Point the camera to the furniture parts", buttonText: "Start scan"))
            nolmyraInstructions.append(ScanInstruction(message: "Looking for the leg and the bridge piece", buttonText: nil, firstItem: NOLMYRA_PIECE1, secondItem: NOLMYRA_PIECE2))
            nolmyraInstructions.append(AssembleInstruction(message: "Put these two pieces together", buttonText: "Done", firstItem: NOLMYRA_PIECE1, secondItem: NOLMYRA_PIECE2, assembledItem: NOLMYRA_CONJOINED_PIECE1))
            nolmyraInstructions.append(ScanInstruction(message: "Looking for the last piece and the other bridge piece", buttonText: nil, firstItem: NOLMYRA_CONJOINED_PIECE1, secondItem: NOLMYRA_PIECE1))
            nolmyraInstructions.append(AssembleInstruction(message: "Put these two pieces together", buttonText: "Done", firstItem: NOLMYRA_CONJOINED_PIECE1, secondItem: NOLMYRA_PIECE1, assembledItem: NOLMYRA_CONJOINED_PIECE2))
            nolmyraInstructions.append(ScanInstruction(message: "Looking for the last piece and the other leg piece", buttonText: nil, firstItem: NOLMYRA_CONJOINED_PIECE2, secondItem: NOLMYRA_PIECE2))
            nolmyraInstructions.append(AssembleInstruction(message: "Put these two pieces together", buttonText: "Done", firstItem: NOLMYRA_CONJOINED_PIECE2, secondItem: NOLMYRA_PIECE2, assembledItem: NOLMYRA_CONJOINED_PIECE3))
            nolmyraInstructions.append(ScanInstruction(message: "Looking for the last piece and the seat", buttonText: nil, firstItem: NOLMYRA_CONJOINED_PIECE3, secondItem: NOLMYRA_SEAT))
            nolmyraInstructions.append(AssembleInstruction(message: "Put these two pieces together", buttonText: "Done", firstItem: NOLMYRA_CONJOINED_PIECE3, secondItem: NOLMYRA_SEAT, assembledItem: "nolmyra"))
            nolmyraInstructions.append(Instruction(message: "You are done putting together Nolmyra", buttonText: "Complete"))
            return nolmyraInstructions
        default:
            return nil
        }
    }
    func getMeasurements(forPart part: String?) -> (SCNVector3)
    {
        switch part {
        case NOLMYRA_PIECE1:
            return SCNVector3(0.05, 0.57, 0.02)
        case NOLMYRA_PIECE2:
            return SCNVector3(0.05, 0.61, 0.43)
        case NOLMYRA_CONJOINED_PIECE1:
            return SCNVector3(0.62, 0.61, 0.43)
        case NOLMYRA_CONJOINED_PIECE2:
            return  SCNVector3(0.62, 0.61, 0.43)
        case NOLMYRA_CONJOINED_PIECE3:
            return SCNVector3(0.67, 0.61, 0.43)
        case NOLMYRA_SEAT:
            return SCNVector3(0.62, 0.45, 0.72)
        default:
            return SCNVector3Zero
        }
    }
    
}
