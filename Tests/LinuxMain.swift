import XCTest

import ExecuteTests

var tests = [XCTestCaseEntry]()
tests += ExecuteTests.__allTests()

XCTMain(tests)
