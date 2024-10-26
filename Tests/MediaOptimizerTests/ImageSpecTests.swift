import Foundation
import Testing
import UIKit

@MainActor
@Suite
struct ImageSpecTests {
    @Test
    func bitDepth() async throws {
        let url = Bundle.module.url(forResource: "10bit", withExtension: "heic")!
        var configuration = UIImageReader.Configuration()
        configuration.prefersHighDynamicRange = false
        let reader = UIImageReader(configuration: configuration)
        let image = await reader.image(contentsOf: url)!
        #expect(image.cgImage!.bitsPerComponent == 16)
    }
    
    @Test
    func bitDepth2() async throws {
        let url = Bundle.module.url(forResource: "screenshot", withExtension: "png")!
        var configuration = UIImageReader.Configuration()
        configuration.prefersHighDynamicRange = false
        let reader = UIImageReader(configuration: configuration)
        let image = await reader.image(contentsOf: url)!
        #expect(image.cgImage!.bitsPerComponent == 8)
    }
}

