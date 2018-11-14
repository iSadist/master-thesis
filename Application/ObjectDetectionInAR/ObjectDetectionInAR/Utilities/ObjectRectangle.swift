/*
 The object rectangle is a class that keeps a rectangle
 and can convert it from and to a regular or normalised coordinate system.
 */

import Foundation
import UIKit

class ObjectRectangle
{
    private var rectangle: CGRect = CGRect()
    private var frame: CGRect?
    private let paddingPercentage : CGFloat = 0.08
    var name: String?
    
    init(rectangle: CGRect)
    {
        self.rectangle = rectangle
    }
    
    init(visionRect rectangle: CGRect, frame: CGRect)
    {
        self.frame = frame
        self.rectangle = translateFromNormalizedRect(normalized: rectangle, frame: frame)
    }
    
    func getNormalizedRect(frame: CGRect) -> CGRect
    {
        return normalizeRect(rectangle, frame: frame)
    }
    
    func getRect() -> CGRect
    {
        return rectangle
    }
    
    func addPadding()
    {
        let widthToMove = rectangle.width * paddingPercentage
        let heigthToMove = rectangle.height * paddingPercentage
        let newXOrigin = rectangle.origin.x - widthToMove/2.0
        let newYOrigin = rectangle.origin.y + heigthToMove/2.0
        let newWidth = rectangle.width + widthToMove
        let newHeigth = rectangle.height + heigthToMove
        rectangle = CGRect(x: newXOrigin, y: newYOrigin, width: newWidth, height: newHeigth)
    }
    
    func setNewBoundingBox(newBoundingBox: CGRect, frame: CGRect?)
    {
        guard frame != nil else { self.rectangle = newBoundingBox; return }
        self.rectangle = translateFromNormalizedRect(normalized: newBoundingBox, frame: frame!)
    }

    private func translateFromNormalizedRect(normalized rect: CGRect, frame: CGRect) -> CGRect
    {
        let pointY = 1 - rect.minY
        let scaleFactor = frame.size
        let realHeight = rect.height * frame.height
        let realWidth = rect.width * frame.width
        let topLeftCorner = (rect.minX * scaleFactor.width + frame.origin.x, pointY * scaleFactor.height - realHeight)
        let scaledRect = CGRect(x: topLeftCorner.0, y: topLeftCorner.1, width: realWidth, height: realHeight)
        return scaledRect
    }
    
    private func normalizeRect(_ rect: CGRect, frame: CGRect) -> CGRect
    {
        var normalizedRect = rect
        normalizedRect.origin.x = (normalizedRect.origin.x - frame.origin.x) / frame.width
        normalizedRect.origin.y = (normalizedRect.origin.y - frame.origin.y) / frame.height
        normalizedRect.size.width /= frame.width
        normalizedRect.size.height /= frame.height
        // Adjust to Vision.framework input requrement - origin at LLC
        normalizedRect.origin.y = 1.0 - normalizedRect.origin.y - normalizedRect.size.height
        return normalizedRect
    }
}
