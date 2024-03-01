import XCTest
@testable import MediaPipeline

class ImageCropProcessorTests: XCTestCase {
    let processor = ImageCropProcessor(aspectRatio: AspectSize(width: 0, height: 0))
    
    func testSizing() async throws {
        let target = CGSize(width: 100, height: 50)
        let aspect = 1.0
        let converted = processor.centerCroppedRect(for: target, aspectRatio: aspect)
        XCTAssertEqual(converted, CGRect(x: 25, y: 0, width: 50, height: 50))
    }
    
    func testSizing2() async throws {
        let target = CGSize(width: 100, height: 50)
        let aspect = 100.0 / 50.0
        let converted = processor.centerCroppedRect(for: target, aspectRatio: aspect)
        XCTAssertEqual(converted, CGRect(x: 0, y: 0, width: 100, height: 50))
    }
    
    func testSizing3() async throws {
        let target = CGSize(width: 100, height: 50)
        let aspect = 50 / 100.0
        let converted = processor.centerCroppedRect(for: target, aspectRatio: aspect)
        XCTAssertEqual(converted, CGRect(x: 37.5, y: 0, width: 25, height: 50))
    }
}

