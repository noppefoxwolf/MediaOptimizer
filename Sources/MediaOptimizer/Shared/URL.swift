import Foundation
import UniformTypeIdentifiers

extension URL {
    static func temporary(filename: String, type: UTType) throws -> URL {
        let tempDirectory = try FileManager.default.url(
            for: .itemReplacementDirectory,
            in: .userDomainMask,
            appropriateFor: FileManager.default.temporaryDirectory,
            create: true
        )
        let filename = UUID().uuidString
        let url = tempDirectory
            .appending(path: filename)
            .appendingPathExtension(for: type)
        return url
    }
}
