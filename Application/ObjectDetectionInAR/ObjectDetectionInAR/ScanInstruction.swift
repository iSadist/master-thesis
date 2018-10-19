import Foundation

class ScanInstruction: Instruction
{
    var firstItem: String?
    var secondItem: String?
    
    init(message: String, buttonText: String?, firstItem: String, secondItem: String)
    {
        super.init(message: message, buttonText: buttonText)
        self.firstItem = firstItem
        self.secondItem = secondItem
    }
}
