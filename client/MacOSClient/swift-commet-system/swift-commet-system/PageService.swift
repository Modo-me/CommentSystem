import SwiftUI

protocol PageServiceProtocol {
    func fetchPage(Id: Int) async throws -> PageData
    func fetchTopicId(title: String) async throws -> IdData
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
    
}
