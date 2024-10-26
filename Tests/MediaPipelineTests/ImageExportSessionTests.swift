import Testing
@testable import MediaPipeline
import Foundation

@Suite 

struct ImageExportSessionTests {
    @Test func export() async throws {
        let filePath = Bundle.module.path(forResource: "ultraHD8K", ofType: "jpg")!
        let image = PlatformImage(contentsOfFile: filePath)!
        var configuration = ImageExportSessionConfiguration(image: image)
        configuration.imageSizeLimit = 1 * 1024 * 1024
        let session = ImageExportSession(configuration: configuration)
        let url = try await session.export()
        print(url)
        let values = try url.resourceValues(forKeys: [.fileSizeKey, .contentTypeKey])
        #expect(values.fileSize! <= configuration.imageSizeLimit)
        #expect(values.contentType! == .heic)
        
        let resultImage = PlatformImage(contentsOfFile: url.path())!
        let matrix = Int(resultImage.size.width * resultImage.size.height)
        #expect(matrix <= configuration.imageMatrixLimit)
    }
    
    @Test func exportTo400x400() async throws {
        let filePath = Bundle.module.path(forResource: "ultraHD8K", ofType: "jpg")!
        let image = PlatformImage(contentsOfFile: filePath)!
        var configuration = ImageExportSessionConfiguration(image: image)
        configuration.maxImageSize = ImageSize(width: 400, height: 400)
        let session = ImageExportSession(configuration: configuration)
        #expect(session.allowsMaxSizes().count == 1)
    }
}
