import Foundation
import SwiftUI

public protocol ServiceError: Error {
    var errorDescription: String { get }
    var recoverySuggestion: String { get }
    var suggestiveImage: Image { get }
}
