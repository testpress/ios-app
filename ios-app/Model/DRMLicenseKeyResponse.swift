import ObjectMapper

public class DRMLicenseKeyResponse {
    
    var licenseURL: String!

    public required init?(map: Map) {
    }
}

extension DRMLicenseKeyResponse: TestpressModel {
    public func mapping(map: Map) {
        licenseURL <- map["license_url"]
    }
}
