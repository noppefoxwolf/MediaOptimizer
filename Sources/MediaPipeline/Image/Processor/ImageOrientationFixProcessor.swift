import os
import Foundation

fileprivate let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier! + ".logger",
    category: #file
)

struct ImageOrientationFixProcessor: ImageProcess, Sendable {
    func process(_ image: PlatformImage) -> PlatformImage {
        #if canImport(UIKit)
        guard image.imageOrientation != .up else {
            logger.info("image orientation is up, passthrougn")
            return image
        }
        logger.log("image orientation is \(image.imageOrientation.rawValue), render")
        #endif
        let rendererFormat = GraphicsImageRendererFormat()
        rendererFormat.scale = 1
        let renderer = GraphicsImageRenderer(size: image.size, format: rendererFormat)
        return renderer.image { context in
            let rect = CGRect(origin: .zero, size: image.size)
            image.draw(in: rect)
        }
    }
}
