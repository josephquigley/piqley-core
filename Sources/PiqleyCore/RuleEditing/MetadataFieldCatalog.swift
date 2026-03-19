// MARK: - MetadataFieldCatalog

/// A hardcoded catalog of photography-relevant metadata field names grouped by source.
/// Image-scanning for dynamic field discovery is deferred; this catalog is used by the
/// rule editor wizard's field-selection UI.
public enum MetadataFieldCatalog {

    // MARK: - Static field name arrays

    public static let exifFields: [String] = [
        "ApertureValue",
        "BrightnessValue",
        "ColorSpace",
        "DateTimeDigitized",
        "DateTimeOriginal",
        "ExposureBiasValue",
        "ExposureMode",
        "ExposureProgram",
        "ExposureTime",
        "Flash",
        "FNumber",
        "FocalLength",
        "FocalLengthIn35mmFilm",
        "ISO",
        "LensModel",
        "LensSpecification",
        "MeteringMode",
        "PixelXDimension",
        "PixelYDimension",
        "SceneType",
        "ShutterSpeedValue",
        "WhiteBalance",
    ].sorted()

    public static let iptcFields: [String] = [
        "Caption",
        "City",
        "Copyright",
        "Country",
        "Credit",
        "DateCreated",
        "Headline",
        "Keywords",
        "ObjectName",
        "Province",
        "Source",
        "SpecialInstructions",
        "Writer",
    ].sorted()

    public static let xmpFields: [String] = [
        "CreateDate",
        "CreatorTool",
        "Label",
        "ModifyDate",
        "Rating",
        "Subject",
        "Title",
    ].sorted()

    public static let tiffFields: [String] = [
        "Artist",
        "Copyright",
        "DateTime",
        "ImageDescription",
        "Make",
        "Model",
        "Orientation",
        "ResolutionUnit",
        "Software",
        "XResolution",
        "YResolution",
    ].sorted()

    // MARK: - fields(forSource:)

    /// Returns a sorted array of `FieldInfo` for the given metadata source.
    /// Fields are sorted by category (derived from source) and then alphabetically by name.
    public static func fields(forSource source: MetadataSource) -> [FieldInfo] {
        let names: [String]
        switch source {
        case .exif: names = exifFields
        case .iptc: names = iptcFields
        case .xmp:  names = xmpFields
        case .tiff: names = tiffFields
        }
        return names
            .sorted()
            .map { FieldInfo(name: $0, source: source) }
    }
}
