
import ObjectMapper

public class DiscussionThreadAnswer {
    public var id: Int!
    public var approvedBy: User!
    public var forumThreadId: Int!
    public var comment: Comment!
    
    
    public required init?(map: Map) {
    }
}

extension DiscussionThreadAnswer: TestpressModel {
    public func mapping(map: Map) {
        id <- map["id"]
        approvedBy <- map["approved_by"]
        forumThreadId <- map["forum_thread_id"]
        comment <- map["comment"]
    }
}
