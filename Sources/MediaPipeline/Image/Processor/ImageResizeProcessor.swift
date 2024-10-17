import os
import Foundation

fileprivate let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier! + ".logger",
    category: #file
)

struct ImageResizeProcessor: ImageProcess, Sendable {
    let maxSize: ImageSize
    
    func process(_ image: PlatformImage) -> PlatformImage {
        let actualSize = image.size.applying(CGAffineTransform(scaleX: image.scale, y: image.scale))
        if actualSize.width <= Double(maxSize.width) && actualSize.height <= Double(maxSize.height) {
            
            logger.info(
                "width: \(actualSize.width) <= \(maxSize.width), height: \(actualSize.height) <= \(maxSize.height),  passthrough"
            )
            
            return image
        }
        
        let newSize = ImageSize(size: actualSize).clamped(maxSize: maxSize).cgSize
        let rendererFormat = GraphicsImageRendererFormat()
        rendererFormat.scale = 1
        let renderer = GraphicsImageRenderer(size: newSize, format: rendererFormat)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
