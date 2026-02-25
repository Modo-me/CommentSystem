import SwiftUI
import Combine

public class PageViewModel: ObservableObject {
    @Published private(set) var title: String = ""
    @Published private(set) var contents: String = ""
    @Published private(set) var posts: [Post] = []
    @Published private(set) var errorMessage: String?
    @Published private(set) var cteateTime: Int64 = 0
    
    private let service: PageServiceProtocol

    init(service: PageServiceProtocol) {
        self.service = service
    }

    func loadPageById(input: Int) {
        Task{
            await load(pageId: input)
        }
    }
    
    func loadPageByTopic(input: String){
        Task{
            await query(title: input)
        }
    }
    
    private func query(title: String) async {
        do {
            let idData = try await service.fetchTopicId(title: title)
            await load(pageId: idData.id)
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    private func load(pageId: Int) async {
            do {
                let pageData = try await service.fetchPage(Id: pageId)

                self.title = pageData.data.Topic.title
                self.posts = pageData.data.PostList
                self.cteateTime = pageData.data.Topic.create_time
                self.contents = pageData.data.Topic.content

            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
}

