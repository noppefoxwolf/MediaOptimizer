import SwiftUI
import _AVKit_SwiftUI
import MediaPipeline
import PhotosUI

@main
struct App: SwiftUI.App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State
    var image: PhotosPickerItem? = nil
    
    @State
    var video: PhotosPickerItem? = nil
    
    var body: some View {
        VStack(content: {
            PhotosPicker(
                selection: $image,
                matching: .images,
                label: {
                    Text("Choose")
                }
            )
            PhotosPicker(
                selection: $video,
                matching: .videos,
                label: {
                    Text("Choose")
                }
            )
        })
        .photosPickerStyle(.inline)
        .photosPickerAccessoryVisibility(.hidden)
        .sheet(isPresented:
                Binding(get: { image != nil }, set: { if !$0 { image = nil } })
        ) {
            NavigationStack {
                PhotoEditorView(selection: image!)
            }
        }
        .sheet(isPresented:
                Binding(get: { video != nil }, set: { if !$0 { video = nil } })
        ) {
            NavigationStack {
                VideoEditorView(selection: video!)
            }
        }
    }
}

struct VideoEditorView: View {
    let selection: PhotosPickerItem
    
    @State
    var originalURL: URL? = nil
    
    @State
    var originalVideoPlayer: AVPlayer? = nil
    
    @State
    var originalVideoSize: CGSize? = nil
    
    @State
    var exportProgress: Float = 0
    
    @State
    var exportedURL: URL? = nil
    
    @State
    var exportedVideoPlayer: AVPlayer? = nil
    
    @State
    var exportedVideoSize: CGSize? = nil
    
    @State
    var videoSizeLimit: Int = 5
    
    @State
    var videoMatrixLimit: Int = 1024
    
    var body: some View {
        ScrollView(content: {
            HStack {
                VStack {
                    VideoPlayer(player: originalVideoPlayer)
                        .frame(height: 200)
                    if let url = originalURL {
                        Text(url.pathExtension)
                        
                        let attr = try! FileManager.default.attributesOfItem(atPath: url.path())
                        Text((attr[.size] as! UInt64).formatted(.byteCount(style: .file)))
                    }
                    if let size = originalVideoSize {
                        Text("\(Int(size.width))x\(Int(size.height))")
                    }
                }
                VStack {
                    VideoPlayer(player: exportedVideoPlayer)
                        .frame(height: 200)
                    ProgressView(value: exportProgress)
                        .progressViewStyle(.linear)
                    if let url = exportedURL {
                        Text(url.pathExtension)
                        
                        let attr = try! FileManager.default.attributesOfItem(atPath: url.path())
                        Text((attr[.size] as! UInt64).formatted(.byteCount(style: .file)))
                    }
                    if let size = exportedVideoSize {
                        Text("\(Int(size.width))x\(Int(size.height))")
                    }
                }
            }
            Stepper(value: $videoSizeLimit, in: 1...100, step: 5) {
                Text("Data Size Limit: ") + Text((videoSizeLimit * 1024 * 1024).formatted(.byteCount(style: .file)))
            }
            
            Stepper(value: $videoMatrixLimit, in: 512...4096, step: 512) {
                Text("Matrix Limit: ") + Text((videoMatrixLimit * videoMatrixLimit).formatted())
            }
        })
        .toolbar(content: {
            ToolbarItem(placement: .bottomBar) {
                Button {
                    Task {
                        var configuration = VideoExportSessionConfiguration(url: originalURL!)
                        configuration.videoSizeLimit = Int64(videoSizeLimit * 1024 * 1024)
                        configuration.videoMatrixLimit = videoMatrixLimit * videoMatrixLimit
                        let session = VideoExportSession(configuration: configuration)
                        let url = try await session.export { progress in
                            Task {
                                await MainActor.run {
                                    exportProgress = progress
                                }
                            }
                        }
                        exportedURL = url
                        exportedVideoPlayer = AVPlayer(url: exportedURL!)
                        let asset = AVAsset(url: exportedURL!)
                        let tracks = try await asset.loadTracks(withMediaType: .video)
                        exportedVideoSize = try await tracks[0].load(.naturalSize)
                        exportProgress = 0
                    }
                } label: {
                    Text("Optimize")
                }

            }
        })
        
        .task {
            let movie = try! await selection.loadTransferable(type: Movie.self)!
            originalURL = movie.url
            originalVideoPlayer = AVPlayer(url: originalURL!)
            let asset = AVAsset(url: originalURL!)
            let tracks = try! await asset.loadTracks(withMediaType: .video)
            originalVideoSize = try! await tracks[0].load(.naturalSize)
        }
    }
}

struct PhotoEditorView: View {
    
    @State
    var exportedUIImage: UIImage? = nil
    @State
    var exportedDataCount: UInt64 = 0
    @State
    var exportedFileType: String = ""
    
    @State
    var uiImage: UIImage? = nil
    
    @State
    var dataCount: Int = 0
    
    let selection: PhotosPickerItem
    
    @State
    var imageDataSizeLimit: Int = 5
    
    @State
    var imageMatrixLimit: Int = 1024
    
    @State
    var imageSizeLimit: ImageSize = .fullHD
    
    @State
    var allowsHEIC: Bool = true
    
    @State
    var isProcessing: Bool = false
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    if let image = uiImage {
                        VStack {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                            Text("\(Int(image.size.width))x\(Int(image.size.height))")
                            Text(dataCount.formatted(.byteCount(style: .file)))
                        }
                    }
                    if let image = exportedUIImage {
                        VStack {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                            Text("\(Int(image.size.width))x\(Int(image.size.height))")
                            Text(exportedDataCount.formatted(.byteCount(style: .file)))
                            Text(exportedFileType)
                        }
                    }
                    if isProcessing {
                        ProgressView().progressViewStyle(.circular)
                    }
                }
                
                Stepper(value: $imageDataSizeLimit, in: 1...10, step: 1) {
                    Text("Data Size Limit: ") + Text((imageDataSizeLimit * 1024 * 1024).formatted(.byteCount(style: .file)))
                }
                Stepper(value: $imageMatrixLimit, in: 512...4096, step: 512) {
                    Text("Matrix Limit: ") + Text((imageMatrixLimit * imageMatrixLimit).formatted())
                }
                
                Picker("Max image Size: ", selection: $imageSizeLimit) {
                    Text(ImageSize.ultraHD.debugDescription).tag(ImageSize.ultraHD)
                    Text(ImageSize.fullHD.debugDescription).tag(ImageSize.fullHD)
                    Text(ImageSize.hd.debugDescription).tag(ImageSize.hd)
                    Text(ImageSize.sd.debugDescription).tag(ImageSize.sd)
                }.pickerStyle(.segmented)
                
                Toggle(isOn: $allowsHEIC) {
                    Text("Allows HEIC: ")
                }
            }.padding()
        }
        .toolbar(content: {
            ToolbarItem(placement: .bottomBar) {
                Button {
                    var configuration = ImageExportSessionConfiguration(image: uiImage!)
                    configuration.imageSizeLimit = imageDataSizeLimit * 1024 * 1024
                    configuration.imageMatrixLimit = imageMatrixLimit * imageMatrixLimit
                    configuration.maxImageSize = imageSizeLimit
                    configuration.supportedMimeTypes = [
                        "image/jpeg",
                        "image/png",
                    ]
                    if allowsHEIC {
                        configuration.supportedMimeTypes.append("image/heic")
                    }
                    let session = ImageExportSession(configuration: configuration)
                    Task {
                        isProcessing = true
                        let url = try await session.export()
                        let attr = try FileManager.default.attributesOfItem(atPath: url.path())
                        exportedFileType = url.pathExtension
                        exportedUIImage = UIImage(contentsOfFile: url.path())
                        exportedDataCount = attr[.size] as! UInt64
                        isProcessing = false
                    }
                } label: {
                    Text("Optimize")
                }.disabled(uiImage == nil)
            }
        })
        .task {
            let data = try! await selection.loadTransferable(type: Data.self)!
            dataCount = data.count
            uiImage = UIImage(data: data)
        }
    }
}

import CoreTransferable

struct Movie: Transferable {
  let url: URL

  static var transferRepresentation: some TransferRepresentation {
    FileRepresentation(contentType: .movie) { movie in
      SentTransferredFile(movie.url)
    } importing: { receivedData in
      let fileName = receivedData.file.lastPathComponent
      let copy: URL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

      if FileManager.default.fileExists(atPath: copy.path) {
        try FileManager.default.removeItem(at: copy)
      }

      try FileManager.default.copyItem(at: receivedData.file, to: copy)
      return .init(url: copy)
    }
  }
}
