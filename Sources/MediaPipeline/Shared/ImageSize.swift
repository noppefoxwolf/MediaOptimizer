import Foundation
import os

fileprivate let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier! + ".logger",
    category: #file
)

public typealias ImageSize = Size
public typealias VideoSize = Size
public typealias AspectSize = Size

public struct Size: Sendable, Hashable {
    public let width: Int
    public let height: Int
    
    public static let ultraHD = Size(width: 3840, height: 2160)
    public static let fullHD = Size(width: 1920, height: 1080)
    public static let hd = Size(width: 1280, height: 720)
    public static let sd = Size(width: 720, height: 480)
    
    public init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }
    
    public init(size: CGSize) {
        self.width = Int(size.width)
        self.height = Int(size.height)
    }
    
    func clamped(matrixLimit: Int) -> Size {
        let imageMatrix = width * height
        guard imageMatrix > matrixLimit else { return Size(width: width, height: height) }
        
        let sqrtLength = sqrt(Double(matrixLimit))
        let maxLength = Double(max(width, height))
        let rate = sqrtLength / maxLength
        
        let newSize = Size(
            width: Int((Double(width) * rate).rounded(.down)),
            height: Int((Double(height) * rate).rounded(.down))
        )
        return newSize.clamped(matrixLimit: matrixLimit)
    }
    
    func clamped(maxSize: Size) -> Size {
        if width <= maxSize.width && height <= maxSize.height {
            logger.info("width: \(width) <= \(maxSize.width), height: \(height) <= \(maxSize.height),  passthrough")
            return self
        }
        let newSize: Size
        if width > height {
            let ratio = Double(maxSize.width) / Double(width)
            let newHeight = Int(Double(height) * ratio)
            newSize = Size(width: maxSize.width, height: newHeight)
        } else {
            let ratio = Double(maxSize.height) / Double(height)
            let newWidth = Int(Double(width) * ratio)
            newSize = Size(width: newWidth, height: maxSize.height)
        }
        logger.info("width: \(width) -> \(newSize.width), height: \(height) -> \(newSize.height),  render")
        return newSize
    }
    
    var cgSize: CGSize {
        CGSize(width: width, height: height)
    }
}

extension Size: Equatable {}

extension Size: Comparable {
    public static func < (lhs: Size, rhs: Size) -> Bool {
        lhs.width < rhs.width && lhs.height < rhs.height
    }
    
    public func contains(_ size: Size) -> Bool {
        let rotateSize = Size(width: size.height, height: size.width)
        return self >= size || self >= rotateSize
    }
}

extension Size: CustomDebugStringConvertible {
    public var debugDescription: String {
        "\(width)x\(height)"
    }
}
