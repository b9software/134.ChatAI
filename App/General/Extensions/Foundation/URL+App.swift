/*
 应用级别的便捷方法：URL 扩展
 */

extension URL {

    // @MBDependency:2
    /// URL 是否是 HTTP 协议的
    var isHTTP: Bool {
        guard let aScheme = scheme?.lowercased() else { return false }
        return aScheme == "https" || aScheme == "http"
    }

    static func open(link: String) {
        guard let url = URL(string: link) else {
            assert(false)
            return
        }
        UIApplication.shared.open(url)
    }
}

extension URL: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(string: value)!
    }
}

/*
 沙箱内 URL 每次启动变化解决，参考
 https://github.com/BB9z/iOS-Project-Template/blob/4.1/App/General/Extensions/Foundation/NSURL%2BApp.h#L17-L41
 */
