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
    
    //通过topicID加载页面
    func loadPageById(input: Int) {
        Task{
            await load(pageId: input)
        }
    }
    
    //通过topic标题加载页面
    func loadPageByTopic(input: String){
        Task{
            await query(title: input)
        }
    }
    
    //增添新topic并加载
    func addNewTopic(title: String, content: String){
        Task{
            await createNewTopic(title: title, content: content)
        }
    }
    
    //增添新post并加载post所属页面
    func addNewPost(searchTitle: String, content: String){
        Task{
            await createNewPost(topicTitle: searchTitle, content: content)
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
    
    private func createNewTopic(title: String, content: String) async {
        do {
            let time = service.getCurrentTime()
            let createdTopic = try await service.createTopic(
                title: title,
                content: content,
                time: time
            )
            
            await load(pageId: Int(createdTopic.id ?? 0))
            
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    private func createNewPost(topicTitle: String, content: String) async {
        do{
            let time = service.getCurrentTime()
            let topicId = try await service.fetchTopicId(title: topicTitle).id
            _ = try await service.createPost(topicId: Int64(topicId), content: content, time: time)
            
            await load(pageId: topicId)
            
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
    }
}

