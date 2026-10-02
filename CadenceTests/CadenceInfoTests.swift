import Foundation
import Testing
@testable import Cadence

@Suite("CadenceInfo")
struct CadenceInfoTests {
    @Test func nameMatchesAppDisplayName() {
        #expect(CadenceInfo.name == Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String)
    }
}