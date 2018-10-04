//
//  OverlayView.swift
//  ObjectDetectionInAR
//
//  Created by Jan Svensson on 2018-10-03.
//  Copyright © 2018 Jan Svensson. All rights reserved.
//

import UIKit

class OverlayView: UIView
{
    var rectangles = [CGRect]()
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect)
    {
        print(rectangles)
        let context = UIGraphicsGetCurrentContext()!

        let color = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(2)
        
        for rectangle in rectangles
        {
            let realHeight = rectangle.height * rect.height
            let realWidth = rectangle.width * rect.width
            let topLeftCorner = (rectangle.maxX * rect.width, rect.height - rectangle.minY * rect.height)
            let scaledRect = CGRect(x: topLeftCorner.0, y: topLeftCorner.1, width: realWidth, height: realHeight)
            context.stroke(scaledRect)
        }
    }
}
