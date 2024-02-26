import Foundation

#if canImport(UIKit)
import UIKit
typealias GraphicsImageRendererFormat = UIGraphicsImageRendererFormat
typealias GraphicsImageRenderer = UIGraphicsImageRenderer
typealias GraphicsImageRendererContext = UIGraphicsImageRendererContext
#endif

#if canImport(AppKit)
import AppKit
typealias GraphicsImageRendererFormat = NSGraphicsImageRendererFormat
typealias GraphicsImageRenderer = NSGraphicsImageRenderer
typealias GraphicsImageRendererContext = NSGraphicsImageRendererContext

class NSGraphicsImageRendererFormat {
    var scale: Double = 1
}

class NSGraphicsImageRenderer {
    let size: CGSize
    let format: GraphicsImageRendererFormat
    
    init(size: CGSize, format: GraphicsImageRendererFormat) {
        self.size = size
        self.format = format
    }
    
    func image(_ action: (GraphicsImageRendererContext) -> Void) -> PlatformImage {
        let bitmap = NSImage(size: size)
        bitmap.lockFocus()
        let cgContext = NSGraphicsContext.current!.cgContext
        let context = NSGraphicsImageRendererContext(cgContext: cgContext)
        action(context)
        bitmap.unlockFocus()
        let cgImage = cgContext.makeImage()!
        return NSImage(cgImage: cgImage, size: size)
    }
}

class NSGraphicsImageRendererContext {
    let cgContext: CGContext
    
    init(cgContext: CGContext) {
        self.cgContext = cgContext
    }
}

extension PlatformImage {
    func pngData() -> Data? {
        guard let tiffRepresentation else { return nil }
        guard let imageRep = NSBitmapImageRep(data: tiffRepresentation) else { return nil }
        return imageRep.representation(using: .png, properties: [:])
    }
    
    func jpegData(compressionQuality: Double) -> Data? {
        guard let tiffRepresentation else { return nil }
        guard let imageRep = NSBitmapImageRep(data: tiffRepresentation) else { return nil }
        return imageRep.representation(using: .jpeg, properties: [.compressionFactor: compressionQuality])
    }
    
    func heicData() -> Data? {
        nil
    }
}
#endif
