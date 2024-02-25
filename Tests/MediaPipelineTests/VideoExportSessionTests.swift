import XCTest
import AVFoundation
@testable import MediaPipeline
import UniformTypeIdentifiers

class VideoExportSessionTests: XCTestCase {
    func testExport() async throws {
        let url = Bundle.module.url(forResource: "ultraHD8K", withExtension: "mp4")!
        let configuration = VideoExportSessionConfiguration(url: url)
        let session = VideoExportSession(configuration: configuration)
        let outputURL = try await session.export().exported()
        let asset = AVURLAsset(url: outputURL)
        let track = try await asset.loadTracks(withMediaType: .video)[0]
        let size = try await track.load(.naturalSize)
        XCTAssertLessThanOrEqual(Int(size.width * size.height), configuration.videoMatrixLimit)
        let attributes = try FileManager.default.attributesOfItem(atPath: outputURL.path)
        let fileSize = attributes[.size] as! Int64
        XCTAssertLessThanOrEqual(fileSize, configuration.videoSizeLimit)
    }
    
    func testExportVGA() async throws {
        let url = Bundle.module.url(forResource: "vga", withExtension: "mp4")!
        let configuration = VideoExportSessionConfiguration(url: url)
        let session = VideoExportSession(configuration: configuration)
        let outputURL = try await session.export().exported()
        let asset = AVURLAsset(url: outputURL)
        let track = try await asset.loadTracks(withMediaType: .video)[0]
        let size = try await track.load(.naturalSize)
        XCTAssertEqual(size.width, 1280)
        XCTAssertEqual(size.height, 720)
    }
    
    func testExportSquare() async throws {
        let url = Bundle.module.url(forResource: "square", withExtension: "mp4")!
        let configuration = VideoExportSessionConfiguration(url: url)
        let session = VideoExportSession(configuration: configuration)
        let outputURL = try await session.export().exported()
        let asset = AVURLAsset(url: outputURL)
        let track = try await asset.loadTracks(withMediaType: .video)[0]
        let size = try await track.load(.naturalSize)
        XCTAssertEqual(size.width, 512)
        XCTAssertEqual(size.height, 512)
    }
    
    func testTypeConvert() {
        let identifier = "video/mp4"
        let utType = UTType(mimeType: identifier)!
        XCTAssertEqual(utType, .mpeg4Movie)
        let avType = AVFileType(utType.identifier)
        XCTAssertEqual(avType, .mp4)
    }
    
    func testPrefferedPreset() {
        let url = Bundle.module.url(forResource: "ultraHD8K", withExtension: "mp4")!
        let configuration = VideoExportSessionConfiguration(url: url)
        let session = VideoExportSession(configuration: configuration)
        let preset = session.prefferedPreset(videoMatrixLimit: 2_073_600)
        XCTAssertEqual(preset, .preset1280x720)
    }
}

extension AsyncThrowingStream<VideoExportSessionUpdate, any Error> {
    func exported() async throws -> URL {
        for try await update in self {
            if case .exported(let url) = update {
                return url
            }
        }
        fatalError()
    }
}
