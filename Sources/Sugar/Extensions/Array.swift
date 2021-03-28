import Foundation

public extension Array {
    subscript(safe index: Int) -> Element? {
        if index >= 0, index < self.count {
            return self[index]
        }
        return nil
    }
}
