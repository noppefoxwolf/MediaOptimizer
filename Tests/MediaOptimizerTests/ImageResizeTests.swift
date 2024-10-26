import Testing
import UIKit

@Suite
struct ImageResizeTests {
    @Test
    func resize() async throws {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 128, height: 128), format: format)
        let image = renderer.image(actions: { _ in })
        #expect(image.scale == 1)
        #expect(image.size == CGSize(width: 128, height: 128))
    }
}
