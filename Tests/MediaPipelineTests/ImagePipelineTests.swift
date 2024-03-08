@testable import MediaPipeline

import XCTest

class ImagePipelineTests: XCTestCase {
    func testPipeline() async throws {
        let imagePipeline = ImagePipeline()
            .resized(maxSize: .iPhone13ProMax)
        
        let filePath = Bundle.module.path(forResource: "screenshot", ofType: "png")!
        let image = PlatformImage(contentsOfFile: filePath)!
        
        let resultImage = imagePipeline.makeImage(from: image)
        
        XCTAssertEqual(resultImage.size.width, 1125)
        XCTAssertEqual(resultImage.size.height, 2436)
    }
    
    func testPipelineHD() async throws {
        let imagePipeline = ImagePipeline()
            .resized(maxSize: .hd)
        
        let filePath = Bundle.module.path(forResource: "screenshot", ofType: "png")!
        let image = PlatformImage(contentsOfFile: filePath)!
        
        let resultImage = imagePipeline.makeImage(from: image)
        
        XCTAssertEqual(resultImage.size.width, 332)
        XCTAssertEqual(resultImage.size.height, 720)
    }
}

