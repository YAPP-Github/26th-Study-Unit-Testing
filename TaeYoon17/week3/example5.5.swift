import Foundation


class UserFailure {
    var name: String

    init(name: String) {
        self.name = name
    }

    func normaizeName() -> String {
        var result = name.trimmingCharacters(in: .whitespacesAndNewlines)

        if result.count > 50 {
            result = String(result.prefix(50))
        }
        return result
    }
}

class UserSuccess {
    /// 프로퍼티 변수 선언이 가장 먼저 Init 메서드보다 먼저 실행되는가?
    private var _name: String = "" 
    var name: String {
        get { return _name }
        set { _name = normaizeName(name: newValue) }
    }

    
    init(name: String) {
        self.name = name
    }

    /// newValue에 따라 값이 바뀌도록 파라미터가 존재하는 메서드로 바뀜
    private func normaizeName(name: String) -> String {
        var result = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if result.count > 50 {
            result = String(result.prefix(50))
        }
        return result
    }
}