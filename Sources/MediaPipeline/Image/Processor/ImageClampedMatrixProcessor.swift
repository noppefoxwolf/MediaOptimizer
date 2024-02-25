import UIKit
import os

fileprivate let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier! + ".logger",
    category: #file
)

struct ImageClampedMatrixProcessor: ImageProcess {
    let matrixLimit: Int
    func process(_ image: UIImage) -> UIImage {
        let imageSize = ImageSize(size: image.size)
        let matrix = imageSize.width * imageSize.height
        if matrix <= matrixLimit {
            logger.info("matrix: \(matrix) <= \(matrixLimit),  passthrough")
            return image
        }
        logger.info("matrix: \(matrix) > \(matrixLimit),  render")
        let newImageSize = imageSize.clamped(matrixLimit: matrixLimit)
        let newSize = newImageSize.cgSize
        let rendererFormat = UIGraphicsImageRendererFormat()
        rendererFormat.scale = 1
        let renderer = UIGraphicsImageRenderer(size: newSize, format: rendererFormat)
        let newImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        return newImage
    }
}
