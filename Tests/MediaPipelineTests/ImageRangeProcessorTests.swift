import Testing
@testable import MediaPipeline
import UIKit

@MainActor
@Suite
struct ImageRangeProcessorTests {
    @Test
    func export() throws {
        let filePath = Bundle.module.path(forResource: "screenshot", ofType: "png")!
        let image = PlatformImage(contentsOfFile: filePath)!
        #expect(image.imageRange == .standard)
        let processor = ImageRangeProcessor(upperRange: .standard)
        let output = processor.process(image)
        #expect(output.imageRange == .standard)
    }
    
    @Test
    func export10bit() throws {
        let filePath = Bundle.module.path(forResource: "10bit", ofType: "heic")!
        let image = PlatformImage(contentsOfFile: filePath)!
        #expect(image.imageRange == .extended)
        let processor = ImageRangeProcessor(upperRange: .standard)
        let output = processor.process(image)
        #expect(output.imageRange == .standard)
    }
}
