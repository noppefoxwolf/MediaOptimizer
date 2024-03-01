import os
import Foundation

fileprivate let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier! + ".logger",
    category: #file
)

struct ImageCropProcessor: ImageProcess, Sendable {
    let aspectSize: AspectSize
    
    func process(_ image: PlatformImage) -> PlatformImage {
        let aspectRatio = Double(aspectSize.width) / Double(aspectSize.height)
        let outputRect = centerCroppedRect(for: image.size, aspectRatio: aspectRatio)
        guard outputRect.size == aspectSize.cgSize else {
            return image
        }
        let croppedCGImage = image.cgImage!.cropping(to: outputRect)!
        return PlatformImage(cgImage: croppedCGImage)
    }
    
    func centerCroppedRect(for size: CGSize, aspectRatio: CGFloat) -> CGRect {
        let aspectWidth = size.height * aspectRatio
        let aspectHeight = size.width / aspectRatio
        
        var x: CGFloat = 0
        var y: CGFloat = 0
        var width = size.width
        var height = size.height
        
        if aspectWidth < size.width {
            width = aspectWidth
            x = (size.width - width) / 2
        } else {
            height = aspectHeight
            y = (size.height - height) / 2
        }
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
}
