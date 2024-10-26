import Testing
@testable import MediaOptimizer

@Suite
struct ImageRangeTests {
    @Test
    func compareImageRange() async throws {
        #expect(ImageRange.extended > ImageRange.standard)
        #expect(ImageRange.standard < ImageRange.extended)
    }
}
