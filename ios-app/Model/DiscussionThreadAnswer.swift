
import ObjectMapper
import CourseKit

class DiscussionThreadAnswer {
    var id: Int!
    var approvedBy: User!
    var forumThreadId: Int!
    var comment: Comment!
    
    
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
