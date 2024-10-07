@testable import MediaPipeline
import Foundation
import Testing

@Suite 

struct ImagePipelineTests {
    @Test func pipeline() async throws {
        let imagePipeline = ImagePipeline()
            .resized(maxSize: .iPhone13ProMax)
        
        let filePath = Bundle.module.path(forResource: "screenshot", ofType: "png")!
        let image = PlatformImage(contentsOfFile: filePath)!
        
        let resultImage = imagePipeline.makeImage(from: image)
        
        #expect(resultImage.size.width == 1125)
        #expect(resultImage.size.height == 2436)
    }
    
    @Test func pipelineHD() async throws {
        let imagePipeline = ImagePipeline()
            .resized(maxSize: .hd)
        
        let filePath = Bundle.module.path(forResource: "screenshot", ofType: "png")!
        let image = PlatformImage(contentsOfFile: filePath)!
        
        let resultImage = imagePipeline.makeImage(from: image)
        
        #expect(resultImage.size.width == 332)
        #expect(resultImage.size.height == 720)
    }
}

