import XCTest
import AVFoundation
@testable import ObjectDetectionInAR

class ObjectDetectionInARTests: XCTestCase {
    
    var processor: ImageProcessor?
    var samplePhotoVC: SamplePhotoViewController?
    
    override func setUp() {
        super.setUp()
        processor = ImageProcessor()
        samplePhotoVC = SamplePhotoViewController()
        samplePhotoVC?.viewDidLoad()
    }
    
    override func tearDown() {
        super.tearDown()
        samplePhotoVC?.viewWillDisappear(false)
    }
    
    func testExample() {
        assert(samplePhotoVC?.imageCaptureDevice == nil)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
    }
    
}
