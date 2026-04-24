import XCTest
@testable import __APP_NAME__

final class AppConfigTests: XCTestCase {
    func testAPIBaseURLIsValid() throws {
        let urlString = AppConfig.apiBaseURL
        XCTAssertFalse(urlString.isEmpty, "apiBaseURL should not be empty after scaffolding")
        XCTAssertNotNil(URL(string: urlString), "apiBaseURL should be a valid URL")
    }
}
