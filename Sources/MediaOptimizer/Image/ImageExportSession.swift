import Foundation
import UniformTypeIdentifiers
import AVKit
import os
import Algorithms

fileprivate let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier!,
    category: #file
)

public struct ImageExportSessionConfiguration: Sendable {
    public init(image: PlatformImage) {
        self.image = image
    }
    public var supportedMimeTypes: [String] = [
        "image/jpeg",
        "image/png",
        "image/heic",
    ]
    
    var supportedUTTypes: [UTType] {
        supportedMimeTypes.compactMap({ UTType(mimeType: $0) })
    }
    
    /// 最大データサイズ
    public var imageSizeLimit: Int = 16 * 1024 * 1024
    // 面積がnを超えるもの
    // Wifi, 4Kは3840×2160
    // 4G, 1080p
    public var imageMatrixLimit: Int = 33_177_600
    
    public var maxImageSize: ImageSize = .ultraHD
    
    public var rangeLimit: ImageRange = .extended
    
    public let image: PlatformImage
    // フォーマットの優先度
    public let formatPriority: [UTType] = [
        .heic,
        .png,
        .jpeg
    ]
    
    public var croppingAspectSize: AspectSize? = nil
    public var allowsSkipRendering: Bool = true
}

public final class ImageExportSession: Sendable {
    public init(configuration: ImageExportSessionConfiguration) {
        self.configuration = configuration
    }
    
    let configuration: ImageExportSessionConfiguration
    
    func allowsMaxSizes() -> [ImageSize] {
        let allowsMaxSizes: [ImageSize] = [
            .ultraHD,
            .iPhone13ProMax,
            .fullHD,
            .hd,
            .sd
        ].filter({ $0 <= configuration.maxImageSize })
        if allowsMaxSizes.isEmpty {
            return [configuration.maxImageSize]
        }
        return allowsMaxSizes
    }
    
    public nonisolated func export() throws -> URL {
        let result = allowsMaxSizes().firstNonNil { [configuration] maxImageSize in
            logger.info("try \(maxImageSize.debugDescription)")
            
            let allowTypes = configuration
                .formatPriority
                .filter({ configuration.supportedUTTypes.contains($0) })
            
            let imagePipeline = ImagePipeline()
                .imageOrientationFixed()
                .cropping(to: configuration.croppingAspectSize)
                .resized(maxSize: maxImageSize)
                .clamped(matrixLimit: configuration.imageMatrixLimit)
                .limited(in: configuration.rangeLimit)
            
            let result = imagePipeline
                .makeImage(from: configuration.image)
                .data(allowTypes: allowTypes, fileLengthLimit: configuration.imageSizeLimit)
            return result
        }!
        logger.debug("Export : data[\(result.data.count)] as \(result.utType.identifier)")
        let url = try write(data: result.data, type: result.utType)
        return url
    }
    
    public func export() async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global().async {
                do {
                    let url = try self.export()
                    continuation.resume(returning: url)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func write(data: Data, type: UTType) throws -> URL {
        let filename = UUID().uuidString
        let url = try URL.temporary(filename: filename, type: type)
        try data.write(to: url)
        return url
    }
}
