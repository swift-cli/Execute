//
//  ProcessOperationTests.swift
//  ExecuteTests
//
//  Copyright (c) 2019 Jason Nam (https://jasonnam.com)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import XCTest
@testable import Execute

final class ProcessOperationTests: XCTestCase {

    func testOperationSuccess() {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["sh", "-c", "echo", "test"]
        let processOperation = ProcessOperation(
            process: process,
            standardOutputDataHandler: FileHandle.nullDevice,
            standardErrorDataHandler: FileHandle.nullDevice
        )

        processOperation.main()

        if case let .success(terminationStatus) = processOperation.result {
            XCTAssertEqual(terminationStatus, 0)
        } else {
            XCTFail("Process operation should succeed.")
        }
    }

    func testExecutableDoesNotExist() {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/error")
        let processOperation = ProcessOperation(
            process: process,
            standardOutputDataHandler: FileHandle.nullDevice,
            standardErrorDataHandler: FileHandle.nullDevice
        )

        processOperation.main()

        if case let .failure(error as NSError) = processOperation.result {
            XCTAssertEqual(error.domain, NSCocoaErrorDomain)
            #if os(macOS)
                XCTAssertEqual(error.code, 4)
            #elseif os(Linux)
                XCTAssertEqual(error.code, 260)
            #endif
        } else {
            XCTFail("Process operation should be finished with file does not exist error.")
        }
    }

    func testCancel() {
        let process = ProcessMock()
        let processOperation = ProcessOperation(
            process: process,
            standardOutputDataHandler: FileHandle.nullDevice,
            standardErrorDataHandler: FileHandle.nullDevice
        )

        processOperation.cancel()

        XCTAssertTrue(process.interruptCalled)
        XCTAssertEqual(process.interruptCallsCount, 1)
    }

    func testStandardOutputDataHandler() {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["sh", "-c", "echo test"]

        let expectation = self.expectation(description: "standardOutputDataHandler did not catch output.")

        let processOperation = ProcessOperation(
            process: process,
            standardOutputDataHandler: BlockDataHandler { data in
                expectation.fulfill()
                XCTAssertEqual(String(data: data, encoding: .utf8), "test\n")
            },
            standardErrorDataHandler: FileHandle.nullDevice
        )

        processOperation.main()

        waitForExpectations(timeout: 10, handler: nil)
    }

    func testStandardErrorDataHandler() {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["sh", "-c", "1>&2 echo error"]

        let expectation = self.expectation(description: "standardErrorDataHandler did not catch output.")

        let processOperation = ProcessOperation(
            process: process,
            standardOutputDataHandler: FileHandle.nullDevice,
            standardErrorDataHandler: BlockDataHandler { data in
                expectation.fulfill()
                XCTAssertEqual(String(data: data, encoding: .utf8), "error\n")
            }
        )

        processOperation.main()

        waitForExpectations(timeout: 10, handler: nil)
    }
}
