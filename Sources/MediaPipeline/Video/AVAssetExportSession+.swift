@preconcurrency import AVFoundation
import UniformTypeIdentifiers

public enum VideoExportSessionUpdate: Sendable {
    case progress(Float)
    case exported(URL)
}

extension AVAssetExportSession {
    func export(_ progressUpdateHandler: @escaping (Float) -> Void) async throws -> URL {
        let task = Task(priority: .background) {
            while progress != 1.0 {
                progressUpdateHandler(progress)
                try await Task.sleep(for: .milliseconds(250))
            }
        }
        return try await withTaskCancellationHandler(
            operation: {
                await export()
                if let error {
                    throw error
                }
                if let outputURL {
                    return outputURL
                } else {
                    throw CancellationError()
                }
            }, 
            onCancel: {
                task.cancel()
                cancelExport()
            }
        )
    }
}

