import SwiftUI

@main
struct swift_commet_systemApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: PageViewModel(service: PageService()))
        }
    }
}
