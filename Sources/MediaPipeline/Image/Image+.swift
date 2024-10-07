#if canImport(UIKit)
import UIKit
public typealias PlatformImage = UIImage
#elseif canImport(AppKit)
import AppKit
public typealias PlatformImage = NSImage
#endif
import Foundation
import UniformTypeIdentifiers
import os

fileprivate let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier! + ".logger",
    category: #file
)

extension PlatformImage {
    func data(allowTypes: [UTType], fileLengthLimit: Int) -> (data: Data, utType: UTType)? {
        if allowTypes.contains(.heic), let data = heicData() {
            if data.count <= fileLengthLimit {
                return (data, .heic)
            }
            logger.info("HEIC over: \(data.count) > \(fileLengthLimit)")
        } else {
            if allowTypes.contains(.png), let data = pngData() {
                if data.count < fileLengthLimit {
                    return (data, .png)
                }
                logger.info("PNG over: \(data.count) > \(fileLengthLimit)")
            }
            if allowTypes.contains(.jpeg) {
                let allowsQuality = [1.0, 0.9, 0.8]
                for quality in allowsQuality {
                    if let data = jpegData(compressionQuality: quality) {
                        if data.count < fileLengthLimit {
                            return (data, .jpeg)
                        }
                        logger.info("JPG(\(quality)) over: \(data.count) > \(fileLengthLimit)")
                    }
                }
            }
        }
        return nil
    }
    
    var imageRange: ImageRange? {
        switch cgImage?.bitsPerComponent {
        case 16: .extended
        case 8: .standard
        default: nil
        }
    }
}

