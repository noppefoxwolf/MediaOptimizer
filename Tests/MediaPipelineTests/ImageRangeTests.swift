import Testing
@testable import MediaPipeline

@Suite
struct ImageRangeTests {
    @Test
    func compareImageRange() async throws {
        #expect(ImageRange.extended > ImageRange.standard)
        #expect(ImageRange.standard < ImageRange.extended)
    }
}
