//
//  XCTestCase+Test.swift
//  UnitTests
//
//  Copyright © 2023 B9Software. All rights reserved.
//

@testable import B9Foundation
import XCTest

extension XCTestCase {
    /// Overwrite `Date.current`, the date string should in format "yyyy-MM-dd HH:mm:ss".
    func setNow(_ dateStr: String) {
        guard let date = DateFormatter.localDayTime.date(from: dateStr) else {
            fatalError("Invalid date str: \(dateStr)")
        }
        Date.overwriteCurrent(date)
    }

    /// Restore `Date.current`.
    func restoreNow() {
        Date.overwriteCurrent(nil)
    }

    /// Create a file at specified location with given string content
    func createFile(at file: URL, content: String) {
        do {
            try? FileManager.default.removeItem(at: file)
            try? FileManager.default.createDirectory(at: file.deletingLastPathComponent(), withIntermediateDirectories: true)
            try content.write(to: file, atomically: true, encoding: .utf8)
            print("Test> Create file at \(file.path)")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    /// Verify that the content of the file is the same as the given string
    func verifyFile(at file: URL, content: String) throws -> Bool {
        let fileContent = try String(contentsOf: file)
        return fileContent == content
    }

    /// Delete the file at the specified location before testing.
    /// After testing the file will be restored.
    func clearFile(at file: URL, then: () throws -> Void) throws {
        var backup: URL! = nil
        let fm = FileManager.default
        if fm.fileExists(atPath: file.path) {
            backup = file.appendingPathExtension("bak")
            try fm.forceMoveItem(at: file, to: backup)
        }
        defer {
            if let backup = backup {
                try? fm.forceMoveItem(at: backup, to: file)
            }
        }
        try then()
    }

    func noBlockingWait(_ time: TimeInterval) {
        let waiter = XCTWaiter()
        let exp = XCTestExpectation()  // Don't use self
        DispatchQueue.main.asyncAfter(deadline: .now() + time) {
            exp.fulfill()
        }
        waiter.wait(for: [exp], timeout: 10)  // No more than 10s
        print("Test> noBlockingWait end.")
    }
}

extension XCTestExpectation {
    /// Return the expectation that is not intended to happen.
    @discardableResult
    func inverted() -> Self {
        isInverted = true
        return self
    }
}

// MARK: - Assert Helpers
enum XCFilePredicate {
    case exists(URL)
    case notExists(URL)
    case contents(directory: URL, fileNames: [String])
}

extension XCTestCase {
    func assertEqual<T>(
        _ expression1: @autoclosure () throws -> T,
        _ expression2: @autoclosure () throws -> T,
        _ message: @autoclosure () -> String? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) where T: Equatable {
        do {
            let value1 = try expression1()
            let value2 = try expression2()
            if value1 == value2 { return }
            XCTFail(join(message(), "(\(value1)) is not equal to (\(value2))."), file: file, line: line)
        } catch {
            XCTFail("Throw error: \(error).", file: file, line: line)
        }
    }

    /// Asserts date equals
    func assertEqual(
        _ date: Date?,
        _ value: String,
        _ message: @autoclosure () -> String? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard let date = date else {
            XCTFail(join(message(), "Date should not be nil."), file: file, line: line)
            return
        }
        let dateValue = DateFormatter.localDayTime.string(from: date)
        if dateValue == value { return }
        XCTFail(join(message(), "Date(\(dateValue)) not equal to \(value)."), file: file, line: line)
    }

    /// Asserts file matching given predicate
    func assertFile(_ predicate: XCFilePredicate, _ message: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line) {
        switch predicate {
        case .exists(let url):
            if FileManager.default.fileExists(atPath: url.path) { return }
            XCTFail(join(message(), "File not exists at: \(url.path)"), file: file, line: line)
        case .notExists(let url):
            if !FileManager.default.fileExists(atPath: url.path) { return }
            XCTFail(join(message(), "File exists at: \(url.path)"), file: file, line: line)
        case let .contents(directory, fileNames):
            do {
                let contents = try FileManager.default.contentsOfDirectory(atPath: directory.path)
                XCTAssertEqual(contents.sorted(), fileNames.sorted(), message(), file: file, line: line)
            } catch {
                XCTFail(error.localizedDescription, file: file, line: line)
            }
        }
    }

    private func join(_ message: String?, _ reason: String) -> String {
        if message?.isEmpty == false {
            return "\(message!)\n\(reason)"  // swiftlint:disable:this force_unwrapping
        }
        return reason
    }
}

// MARK: -

public extension FileManager {
    /// Moves the file or directory at the specified URL to a new location
    ///
    /// If the destination file exists, it will be forced replaced.
    func forceMoveItem(at srcURL: URL, to dstURL: URL) throws {
        if fileExists(atPath: dstURL.path) {
            try? removeItem(at: dstURL)
        }
        try moveItem(at: srcURL, to: dstURL)
    }
}
