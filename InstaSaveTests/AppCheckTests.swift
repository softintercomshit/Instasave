import XCTest
@testable import InstaSave


class AppCheckTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testAppCheck() {
        let expectation = self.expectation(description: "Example")
        
        AppCheck.check { succes in
            XCTAssertTrue(succes, "app is not full")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2)
    }
}
