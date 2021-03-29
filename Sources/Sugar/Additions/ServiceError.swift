import Foundation

public protocol ServiceError: Error {
    var errorDescription: String { get }
    var recoverySuggestion: String { get }
}
