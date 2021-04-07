import Foundation

public class LocalKeyValueStorage {
//    enum Keys: String {
//        case uuid = "SessionStorable.uuid"
//    }
    
    init (){}
    private lazy var defaults = UserDefaults.standard
    
    public subscript(string key: String) -> String? {
        get {
            guard let value = defaults.string(forKey: key) else {
                return nil
            }
            return value
        }
        
        set(newValue) {
            guard let newValue = newValue else {
                defaults.removeObject(forKey: key)
                return
            }
            defaults.set(newValue, forKey: key)
        }
    }

    public subscript(data key: String) -> Data? {
        get {
            guard let value = defaults.data(forKey: key) else {
                return nil
            }

            return value
        }

        set(newValue) {
            guard let newValue = newValue else {
                defaults.removeObject(forKey: key)
                return
            }
            defaults.set(newValue, forKey: key)
        }
    }
}
