// MARK: - MetadataFieldCatalog

/// A hardcoded catalog of photography-relevant metadata field names grouped by source.
/// Image-scanning for dynamic field discovery is deferred; this catalog is used by the
/// rule editor wizard's field-selection UI.
public enum MetadataFieldCatalog {

    // MARK: - Static field name arrays

    public static let exifFields: [String] = [
        "ApertureValue",
        "BodySerialNumber",
        "BrightnessValue",
        "ColorSpace",
        "DateTimeDigitized",
        "DateTimeOriginal",
        "ExposureBiasValue",
        "ExposureMode",
        "ExposureProgram",
        "ExposureTime",
        "FileSource",
        "Flash",
        "FNumber",
        "FocalLength",
        "FocalLengthIn35mmFilm",
        "GPSAltitude",
        "GPSLatitude",
        "GPSLongitude",
        "ISO",
        "LensMake",
        "LensModel",
        "LensSerialNumber",
        "LensSpecification",
        "MaxApertureValue",
        "MeteringMode",
        "PixelXDimension",
        "PixelYDimension",
        "SceneCaptureType",
        "SceneType",
        "ShutterSpeedValue",
        "SubjectDistance",
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
        "LensProfileMake",
        "LensProfileModel",
        "LensProfileName",
        "LensProfilePrettyName",
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

    // MARK: - Internal source map

    /// Maps a well-known source string to its field names and qualified prefix.
    private static let sourceMap: [String: (names: [String], prefix: String, category: FieldCategory)] = [
        "exif": (exifFields, "EXIF", .exif),
        "iptc": (iptcFields, "IPTC", .iptc),
        "xmp":  (xmpFields,  "XMP",  .xmp),
        "tiff": (tiffFields, "TIFF", .tiff),
    ]

    // MARK: - fields(forSource:)

    /// Returns a sorted array of `FieldInfo` for the given source name.
    ///
    /// For well-known sources ("exif", "iptc", "xmp", "tiff") the catalog uses its
    /// built-in field list and the appropriate `FieldCategory`. Unknown source strings
    /// return an empty array.
    ///
    /// Fields within a source are sorted alphabetically by name.
    public static func fields(forSource source: String) -> [FieldInfo] {
        guard let entry = sourceMap[source] else {
            return []
        }
        return entry.names
            .sorted()
            .map { name in
                FieldInfo(
                    name: name,
                    source: source,
                    qualifiedName: "\(entry.prefix):\(name)",
                    category: entry.category
                )
            }
    }
}
