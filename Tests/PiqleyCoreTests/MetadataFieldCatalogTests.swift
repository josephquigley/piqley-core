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

    @Test("fields(forSource:) returns FieldInfo with correct source string")
    func fieldsForSourceHasCorrectSource() {
        let result = MetadataFieldCatalog.fields(forSource: "exif")
        #expect(!result.isEmpty)
        for field in result {
            #expect(field.source == "exif")
        }
    }

    @Test("fields(forSource:) returns FieldInfo with correct qualifiedName")
    func fieldsForSourceQualifiedName() {
        let result = MetadataFieldCatalog.fields(forSource: "exif")
        for field in result {
            #expect(field.qualifiedName == "EXIF:\(field.name)")
        }
    }

    @Test("fields(forSource:) for iptc uses IPTC prefix")
    func fieldsForSourceIPTCQualifiedName() {
        let result = MetadataFieldCatalog.fields(forSource: "iptc")
        for field in result {
            #expect(field.qualifiedName == "IPTC:\(field.name)")
        }
    }

    @Test("fields(forSource:) for xmp uses XMP prefix")
    func fieldsForSourceXMPQualifiedName() {
        let result = MetadataFieldCatalog.fields(forSource: "xmp")
        for field in result {
            #expect(field.qualifiedName == "XMP:\(field.name)")
        }
    }

    @Test("fields(forSource:) for tiff uses TIFF prefix")
    func fieldsForSourceTIFFQualifiedName() {
        let result = MetadataFieldCatalog.fields(forSource: "tiff")
        for field in result {
            #expect(field.qualifiedName == "TIFF:\(field.name)")
        }
    }

    @Test("fields(forSource:) returns empty for unknown source")
    func fieldsForUnknownSourceReturnsEmpty() {
        let result = MetadataFieldCatalog.fields(forSource: "my-plugin")
        #expect(result.isEmpty)
    }

    @Test("fields(forSource:) returns sorted by name")
    func fieldsForSourceSorted() {
        let exif = MetadataFieldCatalog.fields(forSource: "exif")
        let iptc = MetadataFieldCatalog.fields(forSource: "iptc")

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
        let field = FieldInfo(name: "ISO", source: "exif", category: .exif)
        #expect(field.qualifiedName == "exif:ISO")
        #expect(field.name == "ISO")
        #expect(field.source == "exif")
        #expect(field.category == .exif)
    }

    @Test("FieldInfo full init uses explicit qualifiedName")
    func fieldInfoFullInit() {
        let field = FieldInfo(name: "ISO", source: "exif", qualifiedName: "EXIF:ISO", category: .exif)
        #expect(field.qualifiedName == "EXIF:ISO")
        #expect(field.source == "exif")
        #expect(field.category == .exif)
    }

    @Test("FieldInfo for plugin source has custom category")
    func fieldInfoPluginSource() {
        let field = FieldInfo(name: "MyField", source: "exif-tagger", category: .custom)
        #expect(field.category == .custom)
        #expect(field.source == "exif-tagger")
        #expect(field.qualifiedName == "exif-tagger:MyField")
    }

    @Test("FieldInfo catalog exif fields have .exif category")
    func fieldInfoCatalogExifCategory() {
        let result = MetadataFieldCatalog.fields(forSource: "exif")
        for field in result {
            #expect(field.category == .exif)
        }
    }

    @Test("FieldInfo catalog iptc fields have .iptc category")
    func fieldInfoCatalogIPTCCategory() {
        let result = MetadataFieldCatalog.fields(forSource: "iptc")
        for field in result {
            #expect(field.category == .iptc)
        }
    }

    @Test("FieldInfo catalog xmp fields have .xmp category")
    func fieldInfoCatalogXMPCategory() {
        let result = MetadataFieldCatalog.fields(forSource: "xmp")
        for field in result {
            #expect(field.category == .xmp)
        }
    }

    @Test("FieldInfo catalog tiff fields have .tiff category")
    func fieldInfoCatalogTIFFCategory() {
        let result = MetadataFieldCatalog.fields(forSource: "tiff")
        for field in result {
            #expect(field.category == .tiff)
        }
    }
}
