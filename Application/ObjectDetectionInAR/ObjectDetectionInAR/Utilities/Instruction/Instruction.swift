/*
 An instruction is a message to the user on how to
 put together the furniture in the current step.
 */

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
