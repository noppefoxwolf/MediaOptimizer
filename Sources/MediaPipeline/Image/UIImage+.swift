#if canImport(UIKit)
import UIKit
import UniformTypeIdentifiers
import os

fileprivate let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier! + ".logger",
    category: #file
)

extension UIImage {
    func data(allowTypes: [UTType], fileLengthLimit: Int) -> (Data, UTType)? {
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
}


#endif
