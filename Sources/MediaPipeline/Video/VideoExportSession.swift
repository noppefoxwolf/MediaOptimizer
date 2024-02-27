import AVKit
import Foundation

public struct VideoExportSessionConfiguration: Sendable {
    let url: URL
    
    public init(url: URL) {
        self.url = url
    }
    
    public var videoSizeLimit: Int64 = 103809024
    var prefferfVideoSizeLimit: Int64 {
        let rate = wantsAdjustSizeLimit ? 0.9 : 1.0
        return Int64(Double(videoSizeLimit) * rate)
    }
    public var wantsAdjustSizeLimit: Bool = true
    public var videoFrameRateLimit: Int = 120
    public var videoMatrixLimit: Int = 8294400
    public var supportedMimeTypes: [String] = [
        "video/mp4",
    ]
    var supportedUTTypes: [UTType] {
        supportedMimeTypes.compactMap({ UTType(mimeType: $0) })
    }
    
    // フォーマットの優先度
    public let formatPriority: [UTType] = [.mpeg4Movie]
}

public final class VideoExportSession {
    let configuration: VideoExportSessionConfiguration
    
    public init(configuration: VideoExportSessionConfiguration) {
        self.configuration = configuration
    }
    
    public func export() -> AsyncThrowingStream<VideoExportSessionUpdate, any Error> {
        let asset = AVURLAsset(url: configuration.url)
        let preset = prefferedPreset(videoMatrixLimit: configuration.videoMatrixLimit)
        // TODO: framerate check
        let session = AVAssetExportSession(
            asset: asset,
            presetName: preset?.avAssetExport ?? AVAssetExportPresetPassthrough
        )!
        session.fileLengthLimit = configuration.prefferfVideoSizeLimit
        session.shouldOptimizeForNetworkUse = true
        
        let type = configuration
            .supportedUTTypes
            .first(where: { configuration.formatPriority.contains($0) })
        guard let type else {
            return .init(unfolding: { throw VideoExportSessionError.noPreferredType })
        }
        
        do {
            let filename = UUID().uuidString
            session.outputURL = try URL.temporary(filename: filename, type: type)
            session.outputFileType = AVFileType(type.identifier)
            return session.exportStatus()
        } catch {
            return .init(unfolding: { throw error })
        }
    }
    
    func prefferedPreset(videoMatrixLimit: Int) -> ExportPreset? {
        ExportPreset.allCases.reversed().firstNonNil({
            $0.matrix < videoMatrixLimit ? $0 : nil
        })
    }
}

enum ExportPreset: CaseIterable {
    case preset640x480
    case preset960x540
    case preset1280x720
    case preset1920x1080
    case preset3840x2160
    
    var matrix: Int {
        switch self {
        case .preset640x480:
            307_200
        case .preset960x540:
            518_400
        case .preset1280x720:
            921_600
        case .preset1920x1080:
            2_073_600
        case .preset3840x2160:
            8_294_400
        }
    }
    
    var avAssetExport: String {
        switch self {
        case .preset640x480:
            AVAssetExportPreset640x480
        case .preset960x540:
            AVAssetExportPreset960x540
        case .preset1280x720:
            AVAssetExportPreset1280x720
        case .preset1920x1080:
            AVAssetExportPreset1920x1080
        case .preset3840x2160:
            AVAssetExportPreset3840x2160
        }
    }
}

