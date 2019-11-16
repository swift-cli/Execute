//
//  Shell.swift
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

/// Execute shell command.
open class Shell: Executor {

    /// Execute the shell command synchronously.
    /// - Parameters:
    ///   - command: The shell command to execute.
    ///   - environment: Shell environment. If the value is `nil`, the process inherits them from the parent.
    ///   - standardOutputDataHandler: Standard output data handler. By default, it is set to `FileHandle.standardOutput`.
    ///   - standardErrorDataHandler: Standard error data handler. By default, it is set to `FileHandle.standardError`.
    @discardableResult open func sync(_ command: String,
                                      environment: [String: String]? = nil,
                                      standardOutputDataHandler: DataHandler = FileHandle.standardOutput,
                                      standardErrorDataHandler: DataHandler = FileHandle.standardError) -> Result<Int32, Error> {
        let command = ShCommand(command: command)
        return sync(
            command,
            environment: environment,
            standardOutputDataHandler: standardOutputDataHandler,
            standardErrorDataHandler: standardErrorDataHandler
        )
    }

    /// Execute the shell command asynchronously.
    /// - Parameters:
    ///   - command: The shell command to execute.
    ///   - environment: Shell environment. If the value is `nil`, the process inherits them from the parent.
    ///   - standardOutputDataHandler: Standard output data handler. By default, it is set to `FileHandle.standardOutput`.
    ///   - standardErrorDataHandler: Standard error data handler. By default, it is set to `FileHandle.standardError`.
    ///   - completionBlock: The block to execute on termination of the process.
    @discardableResult open func async(_ command: String,
                                       environment: [String: String]? = nil,
                                       standardOutputDataHandler: DataHandler = FileHandle.standardOutput,
                                       standardErrorDataHandler: DataHandler = FileHandle.standardError,
                                       completionBlock: ((Result<Int32, Error>) -> Void)? = nil) -> Operation {
        let command = ShCommand(command: command)
        return async(
            command,
            environment: environment,
            standardOutputDataHandler: standardOutputDataHandler,
            standardErrorDataHandler: standardErrorDataHandler,
            completionBlock: completionBlock
        )
    }
}
