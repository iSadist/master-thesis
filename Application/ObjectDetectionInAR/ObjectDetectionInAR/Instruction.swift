import Foundation

class Instruction
{
    var message: String
    var buttonText: String?
    
    init(message: String, buttonText: String?)
    {
        self.message = message
        self.buttonText = buttonText
    }
}
