#if canImport(UIKit)
import Foundation
import UIKit
import UniformTypeIdentifiers
import AVKit
import os
import Algorithms

fileprivate let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier! + ".logger",
    category: #file
)

public struct ImageExportSessionConfiguration {
    public init(image: UIImage) {
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
    
    public let image: UIImage
    // フォーマットの優先度
    public let formatPriority: [UTType] = [.heic, .png, .jpeg]
}

public final class ImageExportSession {
    public init(configuration: ImageExportSessionConfiguration) {
        self.configuration = configuration
    }
    
    let configuration: ImageExportSessionConfiguration
    
    public nonisolated func export() throws -> URL {
        let allowsMaxSizes = [ImageSize.ultraHD, .fullHD, .hd, .sd].filter({ $0 <= configuration.maxImageSize })
        
        let result = allowsMaxSizes.firstNonNil { [configuration] maxImageSize in
            logger.info("try \(maxImageSize.debugDescription)")
            
            let allowTypes = configuration
                .formatPriority
                .filter({ configuration.supportedUTTypes.contains($0) })
            
            let imagePipeline = ImagePipeline()
                .imageOrientationFixed()
                .resized(maxSize: maxImageSize)
                .clamped(matrixLimit: configuration.imageMatrixLimit)
            
            let result = imagePipeline
                .makeImage(from: configuration.image)
                .data(allowTypes: allowTypes, fileLengthLimit: configuration.imageSizeLimit)
            return result
        }!
        let url = try write(data: result.0, type: result.1)
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
#endif
