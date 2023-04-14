
import UIKit

/*:

 我一般用 playground 辅助实现，验证简短的方法

 另见：[技术选型: 有助更快开发的工具](https://github.com/BB9z/iOS-Project-Template/wiki/%E6%8A%80%E6%9C%AF%E9%80%89%E5%9E%8B#tools-implement-faster)
 */

extension String {

    func trimming(toLength: Int, token: String = "...") -> String {
        assert(toLength >= token.count)
        if count <= toLength {
            return self
        }
        let tmp = padding(toLength: toLength - token.count, withPad: "", startingAt: 0)
        return tmp + token
    }
}


"123456789012".trimming(toLength: 5)
