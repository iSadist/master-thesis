//
//  CompleteInstruction.swift
//  ObjectDetectionInAR
//

import Foundation

class CompleteInstruction: Instruction
{
    override init(message: String, buttonText: String?) {
        self.message = message
        self.buttonText = buttonText
    }
}
