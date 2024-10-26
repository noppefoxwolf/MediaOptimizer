import AVKit
import Foundation
import AVFoundationBackport_iOS17

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
    public var maxVideoSize: VideoSize = .ultraHD
    public var supportedMimeTypes: [String] = [
        "video/mp4",
    ]
    var supportedUTTypes: [UTType] {
        supportedMimeTypes.compactMap({ UTType(mimeType: $0) })
    }
    
    // フォーマットの優先度
    public let formatPriority: [UTType] = [.mpeg4Movie]
}

public final class VideoExportSession: Sendable {
    let configuration: VideoExportSessionConfiguration
    
    public init(configuration: VideoExportSessionConfiguration) {
        self.configuration = configuration
    }
    
    public func export(_ progressUpdateHandler: @escaping @Sendable (Float) -> Void) async throws -> URL {
        let asset = AVURLAsset(url: configuration.url)
        let preset = prefferedPreset(
            videoMatrixLimit: configuration.videoMatrixLimit,
            maxVideoSize: configuration.maxVideoSize
        )
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
            throw VideoExportSessionError.noPreferredType
        }
        let progressTask = Task {
            for try await state in session.states(updateInterval: 0.25) {
                switch state {
                case .exporting(let progress):
                    progressUpdateHandler(Float(progress.fractionCompleted))
                    break
                default:
                    break
                }
            }
        }
        
        do {
            let filename = UUID().uuidString
            let outputURL = try URL.temporary(filename: filename, type: type)
            try await session.export(
                to: outputURL,
                as: AVFileType(type.identifier)
            )
            progressTask.cancel()
            return outputURL
        } catch {
            progressTask.cancel()
            throw error
        }
    }
    
    func prefferedPreset(videoMatrixLimit: Int, maxVideoSize: VideoSize) -> ExportPreset? {
        ExportPreset.allCases.reversed().firstNonNil({
            let lessThanEqualMatrix = $0.matrix <= videoMatrixLimit
            let lessThanEqualSize = maxVideoSize.contains($0.size)
            return lessThanEqualSize && lessThanEqualMatrix ? $0 : nil
        })
    }
}

enum ExportPreset: CaseIterable, Sendable {
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
    
    var size: VideoSize {
        switch self {
        case .preset640x480:
            VideoSize(width: 640, height: 480)
        case .preset960x540:
            VideoSize(width: 960, height: 540)
        case .preset1280x720:
            VideoSize(width: 1280, height: 720)
        case .preset1920x1080:
            VideoSize(width: 1920, height: 1080)
        case .preset3840x2160:
            VideoSize(width: 3840, height: 2160)
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

extension AVAssetExportSession: @unchecked @retroactive Sendable {}
