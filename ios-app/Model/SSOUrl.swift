import ObjectMapper
import CourseKit

public class SSOUrl {

    var url: String!

    public required init?(map: Map) {
    }
}

extension SSOUrl: TestpressModel {
    public func mapping(map: Map) {
        url <- map["sso_url"]
    }
}
