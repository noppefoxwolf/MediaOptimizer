import os
import Foundation

fileprivate let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier! + ".logger",
    category: #file
)

struct ImageRangeProcessor: ImageProcess, Sendable {
    let upperRange: ImageRange
    
    func process(_ image: PlatformImage) -> PlatformImage {
        guard let imageRange = image.imageRange else { return image }
        guard imageRange > upperRange else { return image }
        let size = image.size
        let format = GraphicsImageRendererFormat()
        format.preferredRange = upperRange.graphicsRendererRange
        let renderer = GraphicsImageRenderer(size: size, format: format)
        let output = renderer.image { context in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        return output
    }
}
