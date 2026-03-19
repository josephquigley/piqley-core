import Testing
@testable import PiqleyCore

@Suite("MetadataFieldCatalog")
struct MetadataFieldCatalogTests {

    // MARK: - Static field arrays

    @Test("exifFields is non-empty and contains common fields")
    func exifFieldsNonEmpty() {
        let fields = MetadataFieldCatalog.exifFields
        #expect(!fields.isEmpty)
        #expect(fields.contains("ISO"))
        #expect(fields.contains("LensModel"))
        #expect(fields.contains("FocalLength"))
        #expect(fields.contains("DateTimeOriginal"))
    }

    @Test("iptcFields is non-empty and contains Keywords")
    func iptcFieldsNonEmpty() {
        let fields = MetadataFieldCatalog.iptcFields
        #expect(!fields.isEmpty)
        #expect(fields.contains("Keywords"))
    }

    @Test("tiffFields is non-empty and contains Model and Make")
    func tiffFieldsNonEmpty() {
        let fields = MetadataFieldCatalog.tiffFields
        #expect(!fields.isEmpty)
        #expect(fields.contains("Model"))
        #expect(fields.contains("Make"))
    }

    @Test("xmpFields is non-empty")
    func xmpFieldsNonEmpty() {
        let fields = MetadataFieldCatalog.xmpFields
        #expect(!fields.isEmpty)
    }

    // MARK: - fields(forSource:)

    @Test("fields(forSource:) returns FieldInfo with correct source")
    func fieldsForSourceHasCorrectSource() {
        let result = MetadataFieldCatalog.fields(forSource: .exif)
        #expect(!result.isEmpty)
        for field in result {
            #expect(field.source == .exif)
        }
    }

    @Test("fields(forSource:) returns FieldInfo with correct qualifiedName")
    func fieldsForSourceQualifiedName() {
        let result = MetadataFieldCatalog.fields(forSource: .exif)
        for field in result {
            #expect(field.qualifiedName == "EXIF:\(field.name)")
        }
    }

    @Test("fields(forSource:) returns sorted by category then name")
    func fieldsForSourceSorted() {
        // Use a mixed source set to confirm overall sort order across sources
        let exif = MetadataFieldCatalog.fields(forSource: .exif)
        let iptc = MetadataFieldCatalog.fields(forSource: .iptc)

        // Within a single source, fields should be sorted by name
        let exifNames = exif.map(\.name)
        #expect(exifNames == exifNames.sorted())

        let iptcNames = iptc.map(\.name)
        #expect(iptcNames == iptcNames.sorted())
    }

    // MARK: - FieldCategory sort order

    @Test("FieldCategory sort order: custom < exif < iptc < xmp < tiff")
    func fieldCategorySortOrder() {
        #expect(FieldCategory.custom < FieldCategory.exif)
        #expect(FieldCategory.exif < FieldCategory.iptc)
        #expect(FieldCategory.iptc < FieldCategory.xmp)
        #expect(FieldCategory.xmp < FieldCategory.tiff)
    }

    // MARK: - FieldInfo

    @Test("FieldInfo convenience init builds qualifiedName from source and name")
    func fieldInfoQualifiedName() {
        let field = FieldInfo(name: "ISO", source: .exif)
        #expect(field.qualifiedName == "EXIF:ISO")
        #expect(field.name == "ISO")
        #expect(field.source == .exif)
        #expect(field.category == .exif)
    }

    @Test("FieldInfo for IPTC source has iptc category")
    func fieldInfoIPTCCategory() {
        let field = FieldInfo(name: "Keywords", source: .iptc)
        #expect(field.category == .iptc)
        #expect(field.qualifiedName == "IPTC:Keywords")
    }

    @Test("FieldInfo for XMP source has xmp category")
    func fieldInfoXMPCategory() {
        let field = FieldInfo(name: "Rating", source: .xmp)
        #expect(field.category == .xmp)
        #expect(field.qualifiedName == "XMP:Rating")
    }

    @Test("FieldInfo for TIFF source has tiff category")
    func fieldInfoTIFFCategory() {
        let field = FieldInfo(name: "Make", source: .tiff)
        #expect(field.category == .tiff)
        #expect(field.qualifiedName == "TIFF:Make")
    }
}
