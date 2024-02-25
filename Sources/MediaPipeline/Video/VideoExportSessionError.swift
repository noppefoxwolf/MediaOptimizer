import Foundation

public enum VideoExportSessionError: LocalizedError {
    case noVideoTrack
    case tooHighFramerate
    case noPreferredType
    
    public var errorDescription: String? {
        switch self {
        case .noVideoTrack:
            "Not found video track."
        case .tooHighFramerate:
            "Framerate is too high."
        case .noPreferredType:
            "Not found preferred type."
        }
    }
}
