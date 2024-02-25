import UIKit
import os

fileprivate let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier! + ".logger",
    category: #file
)

struct ImageOrientationFixProcessor: ImageProcess {
    func process(_ image: UIImage) -> UIImage {
        guard image.imageOrientation != .up else {
            logger.info("image orientation is up, passthrougn")
            return image
        }
        logger.log("image orientation is \(image.imageOrientation.rawValue), render")
        let rendererFormat = UIGraphicsImageRendererFormat()
        rendererFormat.scale = 1
        let renderer = UIGraphicsImageRenderer(size: image.size, format: rendererFormat)
        return renderer.image { context in
            let rect = CGRect(origin: .zero, size: image.size)
            image.draw(in: rect)
        }
    }
}
