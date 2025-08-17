import Testing
import AVFoundation
@testable import MediaOptimizer
import UniformTypeIdentifiers

@Suite 

struct VideoExportSessionTests {
    @Test func export() async throws {
        let url = Bundle.module.url(forResource: "ultraHD8K", withExtension: "mp4")!
        let configuration = VideoExportSessionConfiguration(url: url)
        let session = VideoExportSession(configuration: configuration)
        let outputURL = try await session.export({ _ in })
        let asset = AVURLAsset(url: outputURL)
        let track = try await asset.loadTracks(withMediaType: .video)[0]
        let size = try await track.load(.naturalSize)
        #expect(Int(size.width * size.height) <= configuration.videoMatrixLimit)
        let attributes = try FileManager.default.attributesOfItem(atPath: outputURL.path)
        let fileSize = attributes[.size] as! Int64
        #expect(fileSize <= Int(configuration.videoSizeLimit.converted(to: .bytes).value))
    }
    
    @Test func exportVGA() async throws {
        let url = Bundle.module.url(forResource: "vga", withExtension: "mp4")!
        let configuration = VideoExportSessionConfiguration(url: url)
        let session = VideoExportSession(configuration: configuration)
        let outputURL = try await session.export({ _ in })
        let asset = AVURLAsset(url: outputURL)
        let track = try await asset.loadTracks(withMediaType: .video)[0]
        let size = try await track.load(.naturalSize)
        #expect(size.width == 1280)
        #expect(size.height == 720)
    }
    
    struct Platform {
        static var isSimulator: Bool {
            #if targetEnvironment(simulator)
            true
            #else
            false
            #endif
        }
    }
    
    @Test(.enabled(if: !Platform.isSimulator))
    func exportSquare() async throws {
        let url = Bundle.module.url(forResource: "square", withExtension: "mp4")!
        let configuration = VideoExportSessionConfiguration(url: url)
        let session = VideoExportSession(configuration: configuration)
        let outputURL = try await session.export({ _ in })
        let asset = AVURLAsset(url: outputURL)
        let track = try await asset.loadTracks(withMediaType: .video)[0]
        let size = try await track.load(.naturalSize)
        #expect(size.width == 512)
        #expect(size.height == 512)
    }
    
    @Test func typeConvert() {
        let identifier = "video/mp4"
        let utType = UTType(mimeType: identifier)!
        #expect(utType == .mpeg4Movie)
        let avType = AVFileType(utType.identifier)
        #expect(avType == .mp4)
    }
    
    @Test func prefferedPreset() {
        // 7680x4320=33,177,600
        let url = Bundle.module.url(forResource: "ultraHD8K", withExtension: "mp4")!
        let configuration = VideoExportSessionConfiguration(url: url)
        let session = VideoExportSession(configuration: configuration)
        // 3840x2160=8,294,400
        // 1920x1080=2_073_600
        let preset = session.prefferedPreset(videoMatrixLimit: 2_073_600, maxVideoSize: .ultraHD)
        #expect(preset == .preset1920x1080)
    }
}
