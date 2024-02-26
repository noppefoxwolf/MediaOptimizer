import XCTest
import MediaPipeline

class ImageExportSessionTests: XCTestCase {
    func testExport() async throws {
        let filePath = Bundle.module.path(forResource: "ultraHD8K", ofType: "jpg")!
        let image = PlatformImage(contentsOfFile: filePath)!
        var configuration = ImageExportSessionConfiguration(image: image)
        configuration.imageSizeLimit = 1 * 1024 * 1024
        let session = ImageExportSession(configuration: configuration)
        let url = try await session.export()
        print(url)
        let values = try url.resourceValues(forKeys: [.fileSizeKey, .contentTypeKey])
        XCTAssertLessThanOrEqual(values.fileSize!, configuration.imageSizeLimit)
        #if os(iOS)
        XCTAssertEqual(values.contentType!, .heic)
        #else
        XCTAssertEqual(values.contentType!, .jpeg)
        #endif
        
        let resultImage = PlatformImage(contentsOfFile: url.path())!
        let matrix = Int(resultImage.size.width * resultImage.size.height)
        XCTAssertLessThanOrEqual(matrix, configuration.imageMatrixLimit)
    }
}
