import Foundation
import UIKit

class ObjectRectangle
{
    private var rectangle: CGRect = CGRect()
    private var frame: CGRect?
    
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
