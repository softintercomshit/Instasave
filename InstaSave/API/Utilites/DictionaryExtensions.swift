extension Dictionary {
    init(_ tuples: [Element]) {
        self.init()
        tuples.forEach { self[$0.0] = $0.1 }
    }
    
    subscript<T: RawRepresentable>(key: T) -> Value? where T.RawValue == Key {
        get {
            return self[key.rawValue]
        } set {
            self[key.rawValue] = newValue
        }
    }
    
    var stringValue: String? {
        do {
            let json = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            
            return String(data: json, encoding: .utf8)
        } catch {
            return nil
        }
    }
}

func +<T: RawRepresentable, V>(lhs: [T: V], rhs: [T: V]) -> [T.RawValue: V] {
    let tuples = lhs.map { ($0.key.rawValue, $0.value) } + rhs.map { ($0.key.rawValue, $0.value) }
    
    return Dictionary(tuples)
}

func + <Key, Value>(lhs: [Key: Value]?, rhs: [Key: Value]?) -> [Key: Value] {
    var new = lhs ?? [:]
    rhs?.forEach { new[$0.key] = $0.value }
    
    return new
}
