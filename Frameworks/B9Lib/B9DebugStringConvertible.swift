/*
 B9DebugStringConvertible.swift

 Copyright © 2023 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

#if canImport(CoreData)
import CoreData

extension NSFetchedResultsChangeType: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .insert: return ".insert"
        case .delete: return ".delete"
        case .move: return ".move"
        case .update: return ".update"
        @unknown default: return ".unknown(\(rawValue))"
        }
    }
}

#endif

#if canImport(UIKey)
import UIKit

extension UIGestureRecognizer.State: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .began: return ".began"
        case .cancelled: return ".cancelled"
        case .changed: return ".changed"
        case .ended: return ".ended"
        case .failed: return ".failed"
        case .possible: return ".possible"
        @unknown default:
            return ".unknown(\(rawValue))"
        }
    }
}

#endif
