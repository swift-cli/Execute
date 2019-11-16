//
//  Executor.swift
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

/// Execute command with [Process](https://developer.apple.com/documentation/foundation/process).
open class Executor {

    /// The operation queue which executes command.
    open var operationQueue: OperationQueue

    public init(operationQueue: OperationQueue = .init()) {
        self.operationQueue = operationQueue
    }

    /// Execute the shell command synchronously.
    /// - Parameters:
    ///   - command: The shell command to execute.
    ///   - environment: Shell environment. If the value is `nil`, the process inherits them from the parent.
    ///   - standardOutputDataHandler: Standard output data handler. By default, it is set to `FileHandle.standardOutput`.
    ///   - standardErrorDataHandler: Standard error data handler. By default, it is set to `FileHandle.standardError`.
    @discardableResult open func sync(_ command: Command,
                                      environment: [String: String]? = nil,
                                      standardOutputDataHandler: DataHandler = FileHandle.standardOutput,
                                      standardErrorDataHandler: DataHandler = FileHandle.standardError) -> Result<Int32, Error> {
        let operation = self.operation(
            command: command,
            environment: environment,
            standardOutputDataHandler: standardOutputDataHandler,
            standardErrorDataHandler: standardErrorDataHandler
        )
        operationQueue.addOperations([operation], waitUntilFinished: true)
        precondition(operation.result != nil, "Operation was not executed.")
        return operation.result!
    }

    /// Execute the shell command asynchronously.
    /// - Parameters:
    ///   - command: The shell command to execute.
    ///   - environment: Shell environment. If the value is `nil`, the process inherits them from the parent.
    ///   - standardOutputDataHandler: Standard output data handler. By default, it is set to `FileHandle.standardOutput`.
    ///   - standardErrorDataHandler: Standard error data handler. By default, it is set to `FileHandle.standardError`.
    ///   - completionBlock: The block to execute on termination of the process.
    @discardableResult open func async(_ command: Command,
                                       environment: [String: String]? = nil,
                                       standardOutputDataHandler: DataHandler = FileHandle.standardOutput,
                                       standardErrorDataHandler: DataHandler = FileHandle.standardError,
                                       completionBlock: ((Result<Int32, Error>) -> Void)? = nil) -> Operation {
        let operation = self.operation(
            command: command,
            environment: environment,
            standardOutputDataHandler: standardOutputDataHandler,
            standardErrorDataHandler: standardErrorDataHandler
        )
        operation.completionBlock = {
            precondition(operation.result != nil, "Operation was not executed.")
            completionBlock?(operation.result!)
        }
        operationQueue.addOperations([operation], waitUntilFinished: false)
        return operation
    }

    /// Returns an operation with the command and environment.
    /// - Parameters:
    ///   - command: The shell command to execute.
    ///   - environment: Shell environment. If the value is `nil`, the process inherits them from the parent.
    ///   - standardOutputDataHandler: Standard output data handler.
    ///   - standardErrorDataHandler: Standard error data handler.
    open func operation(command: Command,
                        environment: [String: String]? = nil,
                        standardOutputDataHandler: DataHandler,
                        standardErrorDataHandler: DataHandler) -> ProcessOperation {
        let process = Process()
        process.executableURL = .init(fileURLWithPath: command.executablePath)
        process.arguments = command.arguments
        if let environment = environment {
            process.environment = environment
        }
        return .init(
            process: process,
            standardOutputDataHandler: standardOutputDataHandler,
            standardErrorDataHandler: standardErrorDataHandler
        )
    }
}
