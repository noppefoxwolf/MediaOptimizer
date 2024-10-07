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
        var pipeline = self
        pipeline.processors.append(ImageOrientationFixProcessor())
        return pipeline
    }
    
    func resized(maxSize: ImageSize) -> ImagePipeline {
        var pipeline = self
        pipeline.processors.append(ImageResizeProcessor(maxSize: maxSize))
        return pipeline
    }
    
    func clamped(matrixLimit: Int) -> ImagePipeline {
        var pipeline = self
        pipeline.processors.append(ImageClampedMatrixProcessor(matrixLimit: matrixLimit))
        return pipeline
    }
    
    func cropping(to aspectSize: AspectSize?) -> ImagePipeline {
        var pipeline = self
        if let aspectSize {
            pipeline.processors.append(ImageCropProcessor(aspectSize: aspectSize))
        }
        return pipeline
    }
}
