import Testing
@testable import MediaPipeline

@Suite 

struct ImageSizeTests {
    @Test func prefferedImageSize_Safe() async throws {
        let size = ImageSize(width: 1024, height: 1024).clamped(matrixLimit: 1_048_576)
        #expect(size.width == 1024)
        #expect(size.height == 1024)
    }
    
    @Test func prefferedImageSize_Over() async throws {
        let size = ImageSize(width: 1024, height: 1024).clamped(matrixLimit: 1_048_575)
        #expect(size.width == 1023)
        #expect(size.height == 1023)
    }
    
    @Test func prefferedImageSize_Aspect() async throws {
        let size = ImageSize(width: 320, height: 640).clamped(matrixLimit: 204_800 / 2)
        #expect(size.width == 160)
        #expect(size.height == 320)
        #expect(size.height / size.width == 2)
    }
    
    @Test func prefferedImageSize_Limit() async throws {
        let size = ImageSize(width: 200, height: 200).clamped(matrixLimit: 10000)
        #expect(size.width == 100)
        #expect(size.height == 100)
    }
    
    @Test func clamp() async throws {
        let size = ImageSize(width: 1, height: 2).clamped(maxSize: Size(width: 2, height: 1))
        #expect(size.width == 1)
        #expect(size.height == 2)
    }
}


