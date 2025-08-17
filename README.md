# MediaOptimizer

A Swift library for optimizing and exporting images and videos. Provides features like file size limits, resolution limits, and format conversion for efficient media file processing in applications.

[![Swift Package Manager Test](https://github.com/noppefoxwolf/MediaOptimizer/actions/workflows/test.yml/badge.svg)](https://github.com/noppefoxwolf/MediaOptimizer/actions/workflows/test.yml)

## Features

- **Image Optimization**: Size limits, matrix limits, format conversion (JPEG, PNG, HEIC)
- **Video Optimization**: File size limits, resolution limits, frame rate limits
- **Flexible Configuration**: Customizable limits and quality settings
- **iOS 17+ Support**: Leverages the latest iOS features
- **Asynchronous Processing**: Efficient processing using async/await
- **Progress Monitoring**: Progress tracking for video exports

## Requirements

- iOS 17.0+
- Swift 6.0+
- Xcode 16+

## Installation

### Swift Package Manager

1. Open your project in Xcode
2. Go to File → Add Package Dependencies...
3. Enter the following URL: `https://github.com/noppefoxwolf/MediaOptimizer`
4. Click "Add Package"

Using Package.swift:

```swift
dependencies: [
    .package(url: "https://github.com/noppefoxwolf/MediaOptimizer", from: "1.0.0")
]
```

## Usage

### Image Optimization

```swift
import MediaOptimizer
import UIKit

// Set up image
let image = UIImage(named: "sample")!

// Create configuration
var configuration = ImageExportSessionConfiguration(image: image)
configuration.imageSizeLimit = .init(value: 16, unit: .mebibytes)
configuration.imageMatrixLimit = 33_177_600 // 4K equivalent
configuration.maxImageSize = .ultraHD
configuration.rangeLimit = .extended

// Cropping configuration (optional)
configuration.croppingAspectSize = AspectSize(width: 16, height: 9)

// Execute export
let session = ImageExportSession(configuration: configuration)
do {
    let outputURL = try await session.export()
    print("Image saved: \(outputURL)")
} catch {
    print("Error: \(error)")
}
```

### Video Optimization

```swift
import MediaOptimizer
import AVFoundation

// Set up video URL
let videoURL = URL(fileURLWithPath: "path/to/video.mp4")

// Create configuration
var configuration = VideoExportSessionConfiguration(url: videoURL)
configuration.videoSizeLimit = .init(value: 99, unit: .mebibytes)
configuration.videoMatrixLimit = 8_294_400 // 4K equivalent
configuration.maxVideoSize = .ultraHD
configuration.videoFrameRateLimit = 120

// Execute export with progress monitoring
let session = VideoExportSession(configuration: configuration)
do {
    let outputURL = try await session.export { progress in
        print("Progress: \(Int(progress * 100))%")
    }
    print("Video saved: \(outputURL)")
} catch {
    print("Error: \(error)")
}
```

## API Reference

### ImageExportSessionConfiguration

A class that manages image export settings.

#### Properties

- `imageSizeLimit: Measurement<UnitInformationStorage>` - Maximum file size (default: 16MB)
- `imageMatrixLimit: Int` - Maximum matrix value (width × height) (default: 33,177,600)
- `maxImageSize: ImageSize` - Maximum resolution (default: .ultraHD)
- `rangeLimit: ImageRange` - Color range limit (default: .extended)
- `croppingAspectSize: AspectSize?` - Cropping aspect ratio (optional)
- `supportedMimeTypes: [String]` - Supported MIME types

### VideoExportSessionConfiguration

A class that manages video export settings.

#### Properties

- `videoSizeLimit: Measurement<UnitInformationStorage>` - Maximum file size (default: 99MB)
- `videoMatrixLimit: Int` - Maximum matrix value (default: 8,294,400)
- `maxVideoSize: VideoSize` - Maximum resolution (default: .ultraHD)
- `videoFrameRateLimit: Int` - Maximum frame rate (default: 120fps)
- `supportedMimeTypes: [String]` - Supported MIME types

### Size (ImageSize/VideoSize)

A structure representing resolution.

#### Predefined Sizes

- `.ultraHD` - 3840×2160 (4K)
- `.iPhone13ProMax` - 2778×1284
- `.fullHD` - 1920×1080
- `.hd` - 1280×720
- `.sd` - 720×480

## Dependencies

- [swift-algorithms](https://github.com/apple/swift-algorithms) - Algorithm utilities
- [AVFoundationBackport-iOS17](https://github.com/noppefoxwolf/AVFoundationBackport-iOS17) - AVFoundation extensions for iOS 17

## License

See the [LICENSE](LICENSE) file for details about this project's license.

## Contributing

1. Fork this repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Create a Pull Request

## Support

If you have questions or issues, please report them on [Issues](https://github.com/noppefoxwolf/MediaOptimizer/issues).
