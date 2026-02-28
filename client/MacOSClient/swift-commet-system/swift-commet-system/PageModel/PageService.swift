import SwiftUI

protocol PageServiceProtocol {
    func fetchPage(Id: Int) async throws -> PageData
    func fetchTopicId(title: String) async throws -> IdData
    func createTopic(title: String, content: String, time: Int64) async throws -> Topic
    func createPost(topicId: Int64, content: String, time: Int64) async throws -> Post
    func getCurrentTime() -> Int64
}

class PageService: PageServiceProtocol {
    
    func fetchPage(Id: Int) async throws -> PageData {
        let url = URL(string: "http:/localhost:8080/community/page/get/\(Id)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(PageData.self, from: data)
    }
    
    func fetchTopicId(title: String) async throws -> IdData{
        
        var components = URLComponents()
        components.scheme = "http"
        components.host = "localhost"
        components.port = 8080
        components.path = "/community/page/queryid"
        components.queryItems = [
            URLQueryItem(name: "title", value: title)
        ]
        
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(IdData.self, from: data)
    }
    
    func createTopic(title: String, content: String, time: Int64) async throws -> Topic {
        
        let newTopic = Topic(
            id: nil,
            title: title,
            content: content,
            create_time: time
        )
        
        guard let url = URL(string: "http://localhost:8080/community/page/addtopic") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try JSONEncoder().encode(newTopic)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(Topic.self, from: data)
    }
    
    func createPost(topicId: Int64, content: String, time: Int64) async throws -> Post {
        
        
        let newPost = Post(
            id: nil,
            parent_id: topicId,
            content: content,
            create_time: time
        )
        
        guard let url = URL(string: "http://localhost:8080/community/page/addpost") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try JSONEncoder().encode(newPost)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(Post.self, from: data)
    }
    
    func getCurrentTime() -> Int64 {
        return Int64(Date().timeIntervalSince1970)
    }
    
}
