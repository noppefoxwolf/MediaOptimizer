public enum ImageRange: Sendable, Comparable {
    case extended
    case standard
    
    public static func < (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.extended, .standard): return false
        case (.standard, .extended): return true
        default: return false
        }
    }
    
    var graphicsRendererRange: GraphicsImageRendererFormat.Range {
        switch self {
        case .standard: .standard
        case .extended: .extended
        }
    }
}
