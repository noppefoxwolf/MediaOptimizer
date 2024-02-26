import os
import Foundation

fileprivate let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier! + ".logger",
    category: #file
)

struct ImageClampedMatrixProcessor: ImageProcess {
    let matrixLimit: Int
    func process(_ image: PlatformImage) -> PlatformImage {
        let imageSize = ImageSize(size: image.size)
        let matrix = imageSize.width * imageSize.height
        if matrix <= matrixLimit {
            logger.info("matrix: \(matrix) <= \(matrixLimit),  passthrough")
            return image
        }
        logger.info("matrix: \(matrix) > \(matrixLimit),  render")
        let newImageSize = imageSize.clamped(matrixLimit: matrixLimit)
        let newSize = newImageSize.cgSize
        let rendererFormat = GraphicsImageRendererFormat()
        rendererFormat.scale = 1
        let renderer = GraphicsImageRenderer(size: newSize, format: rendererFormat)
        let newImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        return newImage
    }
}
