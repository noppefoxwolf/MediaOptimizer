import os
import Foundation

fileprivate let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier! + ".logger",
    category: #file
)

struct ImageResizeProcessor: ImageProcess {
    let maxSize: ImageSize
    
    func process(_ image: PlatformImage) -> PlatformImage {
        if image.size.width <= Double(maxSize.width) && image.size.height <= Double(maxSize.height) {
            logger.info("width: \(image.size.width) <= \(maxSize.width), height: \(image.size.height) <= \(maxSize.height),  passthrough")
            return image
        }
        
        let newSize = ImageSize(size: image.size).clamped(maxSize: maxSize).cgSize
        let rendererFormat = GraphicsImageRendererFormat()
        rendererFormat.scale = 1
        let renderer = GraphicsImageRenderer(size: newSize, format: rendererFormat)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
