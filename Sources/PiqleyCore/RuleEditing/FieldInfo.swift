// MARK: - MetadataSource

/// The metadata namespace that a field belongs to.
public enum MetadataSource: String, CaseIterable, Sendable, Equatable {
    case exif
    case iptc
    case xmp
    case tiff
}

// MARK: - FieldCategory

/// Sort order for metadata field categories in the rule editor wizard.
/// Raw values define the display ordering: custom first, then EXIF, IPTC, XMP, TIFF.
public enum FieldCategory: Int, Comparable, Sendable {
    case custom = 0
    case exif   = 1
    case iptc   = 2
    case xmp    = 3
    case tiff   = 4

    public static func < (lhs: FieldCategory, rhs: FieldCategory) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: - MetadataSource + FieldCategory mapping

extension MetadataSource {
    var fieldCategory: FieldCategory {
        switch self {
        case .exif: return .exif
        case .iptc: return .iptc
        case .xmp:  return .xmp
        case .tiff: return .tiff
        }
    }

    /// Prefix used when building a qualified field name (e.g. "EXIF:ISO").
    var qualifiedPrefix: String {
        switch self {
        case .exif: return "EXIF"
        case .iptc: return "IPTC"
        case .xmp:  return "XMP"
        case .tiff: return "TIFF"
        }
    }
}

// MARK: - FieldInfo

/// A single metadata field available for use in rule conditions and emit actions.
public struct FieldInfo: Sendable, Equatable {
    /// The bare field name, e.g. "ISO".
    public let name: String
    /// The metadata source that owns this field.
    public let source: MetadataSource
    /// The fully-qualified name combining source prefix and field name, e.g. "EXIF:ISO".
    public let qualifiedName: String
    /// Display/sort category derived from the source.
    public let category: FieldCategory

    /// Convenience initialiser that derives `qualifiedName` and `category` from `source`.
    public init(name: String, source: MetadataSource) {
        self.name = name
        self.source = source
        self.qualifiedName = "\(source.qualifiedPrefix):\(name)"
        self.category = source.fieldCategory
    }
}
