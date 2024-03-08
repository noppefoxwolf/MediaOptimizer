import XCTest
@testable import MediaPipeline

class ImageSizeTests: XCTestCase {
    func testprefferedImageSize_Safe() async throws {
        let size = ImageSize(width: 1024, height: 1024).clamped(matrixLimit: 1_048_576)
        XCTAssertEqual(size.width, 1024)
        XCTAssertEqual(size.height, 1024)
    }
    
    func testprefferedImageSize_Over() async throws {
        let size = ImageSize(width: 1024, height: 1024).clamped(matrixLimit: 1_048_575)
        XCTAssertEqual(size.width, 1023)
        XCTAssertEqual(size.height, 1023)
    }
    
    func testprefferedImageSize_Aspect() async throws {
        let size = ImageSize(width: 320, height: 640).clamped(matrixLimit: 204_800 / 2)
        XCTAssertEqual(size.width, 160)
        XCTAssertEqual(size.height, 320)
        XCTAssertEqual(size.height / size.width, 2)
    }
    
    func testprefferedImageSize_Limit() async throws {
        let size = ImageSize(width: 200, height: 200).clamped(matrixLimit: 10000)
        XCTAssertEqual(size.width, 100)
        XCTAssertEqual(size.height, 100)
    }
    
    func testClamp() async throws {
        let size = ImageSize(width: 1, height: 2).clamped(maxSize: Size(width: 2, height: 1))
        XCTAssertEqual(size.width, 1)
        XCTAssertEqual(size.height, 2)
    }
}


