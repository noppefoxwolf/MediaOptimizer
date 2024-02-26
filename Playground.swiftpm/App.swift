import SwiftUI
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
    var selection: PhotosPickerItem? = nil
    
    var body: some View {
        PhotosPicker(
            selection: $selection,
            label: {
                Text("Choose")
            }
        )
        .photosPickerStyle(.inline)
        .sheet(isPresented:
                Binding(get: { selection != nil }, set: { if !$0 { selection = nil } })
        ) {
            NavigationStack {
                PhotoEditorView(selection: selection!)
            }
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
                        let url = try await session.export()
                        let attr = try FileManager.default.attributesOfItem(atPath: url.path())
                        exportedFileType = url.pathExtension
                        exportedUIImage = UIImage(contentsOfFile: url.path())
                        exportedDataCount = attr[.size] as! UInt64
                    }
                } label: {
                    Text("Optimized")
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

