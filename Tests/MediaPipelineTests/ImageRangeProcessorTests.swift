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
    
    @Test
    func make10BitImage() throws {
        let format = GraphicsImageRendererFormat()
        format.preferredRange = .extended
        let renderer = GraphicsImageRenderer(size: CGSize(width: 1, height: 1))
        let output = renderer.image(actions: { ctx in
            UIColor(displayP3Red: 1, green: 0, blue: 0, alpha: 1).setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        })
        print(output)
        #expect(output.imageRange == .extended)
        let data = output.heicData()!
        let url = URL(filePath: NSTemporaryDirectory()).appending(path: "validationImage.heic")
        try data.write(to: url)
        print(url)
    }
    
    @Test
    func makeImageTest() async throws {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.preferredRange = .extended
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1), format: format)
        let sourceImage = renderer.image(actions: { _ in })
        #expect(sourceImage.scale == 1)
        #expect(sourceImage.size.equalTo(CGSize(width: 1, height: 1)))
        #expect(sourceImage.actualSize == ImageSize(width: 1, height: 1))
        #expect(sourceImage.imageRange == .extended)
        
        let processor = ImageRangeProcessor(upperRange: .standard)
        let output = processor.process(sourceImage)
        #expect(output.scale == 1)
        #expect(output.size.equalTo(CGSize(width: 1, height: 1)))
        #expect(sourceImage.actualSize == ImageSize(width: 1, height: 1))
    }
}
