import Foundation

struct Post: Codable{
    let id: Int64?
    let parent_id: Int64
    let content: String
    let create_time: Int64
}

struct Topic: Codable{
    let id: Int64?
    let title: String
    let content: String
    let create_time: Int64
}

struct PageInfo: Codable {
    let Topic: Topic
    let PostList: [Post]
    
}

struct PageData: Codable{
    let code: Int64
    let msg: String
    let data: PageInfo
}

public struct IdData: Codable{
    let code: Int64
    let msg: String
    let id: Int
}
