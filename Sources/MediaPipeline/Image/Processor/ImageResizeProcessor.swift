import os
import Foundation

fileprivate let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier! + ".logger",
    category: #file
)

struct ImageResizeProcessor: ImageProcess, Sendable {
    let maxSize: ImageSize
    
    func process(_ image: PlatformImage) -> PlatformImage {
        if image.actualSize.width <= maxSize.width && image.actualSize.height <= maxSize.height {
            
            logger.info("""
                [Resize]
                width: \(image.actualSize.width) <= \(maxSize.width)
                height: \(image.actualSize.height) <= \(maxSize.height)
                -> passthrough
            """)
            
            return image
        }
        
        let newSize = image.actualSize.clamped(maxSize: maxSize).cgSize
        let rendererFormat = GraphicsImageRendererFormat()
        rendererFormat.scale = 1
        let renderer = GraphicsImageRenderer(size: newSize, format: rendererFormat)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

extension PlatformImage {
    var actualSize: ImageSize {
        ImageSize(size: size.applying(CGAffineTransform(scaleX: scale, y: scale)))
    }
}
