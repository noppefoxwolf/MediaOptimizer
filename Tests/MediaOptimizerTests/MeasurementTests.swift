import Foundation
import Testing

@Suite
struct MeasurementTests {
    @Test
    func convertMebibytesToBytes() async throws {
        let measurement = Measurement<UnitInformationStorage>(value: 2, unit: .mebibytes)
        let mb: Double = 2 * 1024 * 1024
        #expect(measurement.converted(to: .bytes).value == mb)
    }
    
    @Test
    func convertBytesToMebibytes() async throws {
        let measurement = Measurement<UnitInformationStorage>(value: 103809024, unit: .bytes)
        let mb: Double = 99
        #expect(measurement.converted(to: .mebibytes).value == mb)
    }
}
