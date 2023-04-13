//
//  Date+Test.swift
//  UnitTests
//
//  Copyright © 2023 B9Software. All rights reserved.
//

@testable import B9ChatAI
import Foundation

extension Date {
    /// Create date from string
    ///
    /// - Parameters:
    ///   - str: A string representation of the date in `yyyy-MM-dd HH:mm:ss` format
    init(_ str: String) {
        guard let date = DateFormatter.localDayTime.date(from: str) else {
            fatalError("Invalid date string: \(str).")
        }
        self.init(timeInterval: 0, since: date)
    }

    /// Create date from string
    ///
    /// - Parameters:
    ///   - day: A string representation of the date in one of the following formats:
    ///     * `yyyy-MM-dd`
    ///     * `yyyy-MM-dd HH:mm:ss`
    init(day: String) {
        let formatter: DateFormatter
        switch day.count {
        case 10:
            formatter = .localDay
        case 19:
            formatter = .localDayTime
        default:
            fatalError("\(day) is not in acceptable format.")
        }
        guard let date = formatter.date(from: day) else {
            fatalError("\(day) is not in acceptable format.")
        }
        self.init(timeInterval: 0, since: date)
    }

    /// Create a `Date` instance from a string representation of a time.
    ///
    /// - Parameters:
    ///   - time: A time string in one of the following formats:
    ///     - `HH:mm`
    ///     - `HH:mm:ss`
    ///     - `yyyy-MM-dd HH:mm:ss`
    ///     - `yyyy-MM-dd HH:mm`
    ///   - day: A day string in `yyyy-MM-dd` format.
    ///     If not provided, the current date is used.
    init(time: String, day: String? = nil) {
        let dateString: String
        if time.count == 19 {
            dateString = time
        } else if time.count == 16 {
            dateString = time + ":00"
        } else if let day = day {
            dateString = "\(day) \(time)"
        } else {
            let today = DateFormatter.localDay.string(from: .current)
            dateString = "\(today) \(time)"
        }
        guard let date = DateFormatter.localDayTime.date(from: dateString) else {
            fatalError("\(dateString) is not in acceptable format.")
        }
        self.init(timeInterval: 0, since: date)
    }
}
