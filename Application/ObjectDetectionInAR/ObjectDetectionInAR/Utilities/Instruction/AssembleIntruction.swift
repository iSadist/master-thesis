/*
 The assemble instruction is when the app has located two pieces
 and continues to track them until the user has put them together
 and is ready for the next step.
 */

import Foundation

class AssembleInstruction: Instruction
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
