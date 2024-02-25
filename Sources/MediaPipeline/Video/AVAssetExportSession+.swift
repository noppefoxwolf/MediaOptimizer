@preconcurrency import AVFoundation
import UniformTypeIdentifiers

public enum VideoExportSessionUpdate {
    case progress(Float)
    case exported(URL)
}

extension AVAssetExportSession {
    func exportStatus() -> AsyncThrowingStream<VideoExportSessionUpdate, any Error> {
        AsyncThrowingStream { continuation in
            let task = Task(priority: .background) {
                while progress != 1.0 {
                    continuation.yield(.progress(progress))
                    try await Task.sleep(for: .milliseconds(250))
                }
            }
            exportAsynchronously { [self] in
                if let error {
                    continuation.finish(throwing: error)
                }
                if let outputURL {
                    continuation.yield(.exported(outputURL))
                    continuation.finish()
                }
            }
            continuation.onTermination = { [self] _ in
                task.cancel()
                cancelExport()
            }
        }
    }
}

