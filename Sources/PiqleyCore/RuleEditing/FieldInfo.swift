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

// MARK: - FieldInfo

/// A single metadata field available for use in rule conditions and emit actions.
public struct FieldInfo: Sendable, Equatable {
    /// The bare field name, e.g. "ISO".
    public let name: String
    /// The source namespace that owns this field, e.g. "original", "exif-tagger".
    public let source: String
    /// The fully-qualified name combining source and field name, e.g. "exif-tagger:ISO".
    public let qualifiedName: String
    /// Display/sort category for grouping fields in the rule editor wizard.
    public let category: FieldCategory

    /// Full initialiser with explicit qualifiedName.
    public init(name: String, source: String, qualifiedName: String, category: FieldCategory) {
        self.name = name
        self.source = source
        self.qualifiedName = qualifiedName
        self.category = category
    }

    /// Convenience initialiser that derives `qualifiedName` as `"\(source):\(name)"`.
    public init(name: String, source: String, category: FieldCategory) {
        self.name = name
        self.source = source
        self.qualifiedName = "\(source):\(name)"
        self.category = category
    }
}
