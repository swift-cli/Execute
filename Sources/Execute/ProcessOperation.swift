//
//  ProcessOperation.swift
//  Execute
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

import Foundation

/// An operation that manages the concurrent execution of
/// [Process](https://developer.apple.com/documentation/foundation/process).
open class ProcessOperation: Operation {

    /// The process execution result.
    open private(set) var result: Result<Int32, Error>?

    /// The process to execute.
    public let process: Process
    /// Standard output data handler.
    public let standardOutputDataHandler: DataHandler
    /// Standard error data handler.
    public let standardErrorDataHandler: DataHandler

    /// Creates an operation that manages the concurrent execution of
    /// [Process](https://developer.apple.com/documentation/foundation/process).
    /// - Parameters:
    ///   - process: The process to execute.
    ///   - standardOutputDataHandler: Standard output data handler.
    ///   - standardErrorDataHandler: Standard error data handler.
    public init(process: Process,
                standardOutputDataHandler: DataHandler,
                standardErrorDataHandler: DataHandler) {
        self.process = process
        self.standardOutputDataHandler = standardOutputDataHandler
        self.standardErrorDataHandler = standardErrorDataHandler
        super.init()
    }

    open override func main() {
        let dispatchQueue = DispatchQueue(label: "com.swiftcli.execute")

        let standardOutputPipe = Pipe()
        standardOutputPipe.fileHandleForReading.readabilityHandler = { [weak self] fileHandle in
            dispatchQueue.async {
                self?.standardOutputDataHandler.handle(fileHandle.availableData)
            }
        }
        process.standardOutput = standardOutputPipe

        let standardErrorPipe = Pipe()
        standardErrorPipe.fileHandleForReading.readabilityHandler = { [weak self] fileHandle in
            dispatchQueue.async {
                self?.standardErrorDataHandler.handle(fileHandle.availableData)
            }
        }
        process.standardError = standardErrorPipe

        process.terminationHandler = { _ in
            dispatchQueue.async {
                standardOutputPipe.fileHandleForReading.readabilityHandler = nil
                standardErrorPipe.fileHandleForReading.readabilityHandler = nil
            }
        }

        do {
            try process.run()
            process.waitUntilExit()
            result = .success(process.terminationStatus)
        } catch {
            result = .failure(error)
        }
    }

    open override func cancel() {
        process.interrupt()
    }
}
