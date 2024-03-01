import os
import Foundation

fileprivate let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier! + ".logger",
    category: #file
)

protocol ImageProcess: Sendable {
    func process(_ image: PlatformImage) -> PlatformImage
}

struct ImagePipeline: Sendable {
    var processors: [any ImageProcess] = []
    
    func makeImage(from image: PlatformImage) -> PlatformImage {
        var result = image
        for processor in processors {
            result = processor.process(result)
        }
        return result
    }
}

extension ImagePipeline {
    func imageOrientationFixed() -> ImagePipeline {
        var _self = self
        _self.processors.append(ImageOrientationFixProcessor())
        return _self
    }
    
    func resized(maxSize: ImageSize) -> ImagePipeline {
        var _self = self
        _self.processors.append(ImageResizeProcessor(maxSize: maxSize))
        return _self
    }
    
    func clamped(matrixLimit: Int) -> ImagePipeline {
        var _self = self
        _self.processors.append(ImageClampedMatrixProcessor(matrixLimit: matrixLimit))
        return _self
    }
}
