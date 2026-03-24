import Testing
import Foundation
@testable import PiqleyCore

@Suite("HookConfig")
struct HookConfigTests {

    @Test func forkFieldDecodes() throws {
        let json = #"{"fork": true}"#
        let config = try JSONDecoder.piqley.decode(HookConfig.self, from: Data(json.utf8))
        #expect(config.fork == true)
    }

    @Test func forkFieldDefaultsNil() throws {
        let json = #"{}"#
        let config = try JSONDecoder.piqley.decode(HookConfig.self, from: Data(json.utf8))
        #expect(config.fork == nil)
    }
}
