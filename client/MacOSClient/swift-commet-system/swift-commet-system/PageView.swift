import SwiftUI

public struct ContentView: View {
    
    @ObservedObject private var viewModel: PageViewModel
    
    @State private var inputId: String = ""
    @State private var animateBackground = false
    
    // 创建内容
    @State private var newTopicTitle: String = ""
    @State private var newTopicContent: String = ""
    @State private var newPostContent: String = ""
    
    // 过渡状态
    @State private var pageTransitioning = false
    @State private var contentOpacity: Double = 1
    @State private var warpScale: CGFloat = 1
    @State private var rotationAngle: Double = 0
    
    // MARK: Loading Overlay State (新增：淡入淡出加载覆盖层)
    @State private var isLoadingOverlayVisible: Bool = false
    @State private var loadingPulse: Bool = false
    @State private var pendingLoadToken: UUID = UUID()
    
    init(viewModel: PageViewModel){
        self.viewModel = viewModel
    }
    
    public var body: some View {
        
        ZStack {
            
            // 背景
            RadialGradient(
                colors: animateBackground ?
                [Color.white, Color.blue.opacity(0.25), Color.cyan.opacity(0.35)] :
                    [Color.white, Color.cyan.opacity(0.25), Color.blue.opacity(0.3)],
                center: .center,
                startRadius: 80,
                endRadius: 700
            )
            .overlay(
                LinearGradient(
                    colors: [.cyan.opacity(0.2), .clear, .blue.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .blendMode(.plusLighter)
            )
            .scaleEffect(pageTransitioning ? 1.15 : 1)
            .rotationEffect(.degrees(animateBackground ? 360 : 0))
            .ignoresSafeArea()
            .animation(.linear(duration: 60).repeatForever(autoreverses: false), value: animateBackground)
            .animation(.easeInOut(duration: 0.6), value: pageTransitioning)
            
            ScrollView {
                // MARK: 创建 Topic UI
                
                VStack(spacing: 12) {
                    
                    sectionTitle("Create New Topic")
                    
                    futuristicField("Topic Title", text: $newTopicTitle)
                    futuristicField("Topic Content", text: $newTopicContent)
                    
                    futuristicActionButton("Create Topic", "plus.circle.fill") {
                        guard !newTopicTitle.isEmpty,
                              !newTopicContent.isEmpty else { return }
                        
                        let titleToSubmit = newTopicTitle
                        let contentToSubmit = newTopicContent
                        
                        triggerWarp {
                            viewModel.addNewTopic(title: titleToSubmit, content: contentToSubmit)
                        }
                        
                        newTopicTitle = ""
                        newTopicContent = ""
                    }
                }
                
                VStack(spacing: 20) {
                    
                    Image(systemName: "globe")
                        .font(.system(size: 55))
                        .foregroundStyle(
                            AngularGradient(
                                colors: [.cyan, .blue, .white, .cyan],
                                center: .center
                            )
                        )
                        .shadow(color: .blue.opacity(0.6), radius: pageTransitioning ? 25 : 10)
                        .rotation3DEffect(
                            .degrees(animateBackground ? 360 : 0),
                            axis: (x: 0, y: 1, z: 0)
                        )
                        .animation(.linear(duration: 20).repeatForever(autoreverses: false), value: animateBackground)
                    
                    // 标题
                    Text(viewModel.title)
                        .font(.system(size: 34, weight: .heavy, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .cyan, .white],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: .blue.opacity(0.6), radius: 6)
                    
                    // 内容
                    Text(viewModel.contents.isEmpty ? "Initializing Data Stream..." : viewModel.contents)
                        .font(.system(.callout, design: .monospaced))
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color.white.opacity(0.6))
                        .cornerRadius(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(
                                    LinearGradient(
                                        colors: [.cyan, .blue.opacity(0.7)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.2
                                )
                        )
                    
                    // 页面切换按钮
                    HStack(spacing: 12) {
                        
                        button("教程", "book.fill", id: 2)
                        button("Home", "house.fill", id: 1)
                        button("赞助Modo", "heart.fill", id: 4)
                    }
                    .searchable(text: $inputId)
                    .onChange(of: inputId) {
                        loadWithOverlay {
                            triggerWarp {
                                viewModel.loadPageByTopic(input: inputId)
                            }
                        }
                    }
                    
                    
                    // MARK: 创建 Post UI
                    
                    VStack(spacing: 12) {
                        
                        sectionTitle("Add Post To Current Topic")
                        
                        futuristicField("Post Content", text: $newPostContent)
                        
                        futuristicActionButton("Add Post", "paperplane.fill") {
                            guard !newPostContent.isEmpty else { return }
                            
                            let contentToSubmit = newPostContent
                            
                            triggerWarp {
                                viewModel.addNewPost(
                                    searchTitle: viewModel.title,
                                    content: contentToSubmit
                                )
                            }
                            
                            newPostContent = ""
                        }
                    }
                    
                    
                    // MARK: Posts
                    
                    ForEach(viewModel.posts.reversed(), id: \.id) { post in
                        
                        if let url = URL(string: post.content),
                           url.scheme?.hasPrefix("http") == true {
                            
                            Link(post.content, destination: url)
                                .modifier(PostStyle())
                            
                        } else {
                            
                            Text(post.content)
                                .modifier(PostStyle())
                        }
                    }
                }
                .padding()
            }
            
            // MARK: Loading Overlay (新增：与主题一致的淡入淡出覆盖层)
            if isLoadingOverlayVisible {
                loadingOverlay
                    .transition(.opacity)
                    .zIndex(10)
            }
        }
        .task {
            animateBackground = true
            loadWithOverlay {
                viewModel.loadPageById(input: 1)
            }
        }
        // 网络数据回来后自动淡出（不改任何现有 UI，只监听数据变化）
        .onChange(of: viewModel.contents) {
            hideOverlayIfReady()
        }
        .onChange(of: viewModel.title) {
            hideOverlayIfReady()
        }
        .onChange(of: viewModel.posts.count) { 
            hideOverlayIfReady()
        }
    }
    
    
    // MARK: UI Components
    
    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 18, weight: .bold, design: .rounded))
            .foregroundStyle(
                LinearGradient(
                    colors: [.cyan, .blue],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
    }
    
    
    private func futuristicField(_ placeholder: String,
                                 text: Binding<String>) -> some View {
        
        TextField(placeholder, text: text)
            .padding()
            .background(Color.white.opacity(0.6))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [.cyan, .blue.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .blue.opacity(0.3), radius: 6)
    }
    
    
    private func futuristicActionButton(_ title: String,
                                        _ icon: String,
                                        action: @escaping () -> Void) -> some View {
        
        Button(action: action) {
            Label(title, systemImage: icon)
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white.opacity(0.65))
                .cornerRadius(18)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(
                            LinearGradient(
                                colors: [.cyan, .blue.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.2
                        )
                )
                .shadow(color: .blue.opacity(0.4), radius: 8)
        }
        .buttonStyle(.plain)
    }
    
    
    private func button(_ title: String, _ icon: String, id: Int) -> some View {
        Button {
            loadWithOverlay {
                triggerWarp {
                    viewModel.loadPageById(input: id)
                }
            }
        } label: {
            Label(title, systemImage: icon)
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white.opacity(0.6))
                .cornerRadius(18)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(
                            LinearGradient(
                                colors: [.cyan, .blue.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.2
                        )
                )
                .shadow(color: .blue.opacity(0.4), radius: 8)
        }
        .buttonStyle(.plain)
    }
    
    
    // MARK: Warp Animation
    
    private func triggerWarp(action: @escaping () -> Void) {
        
        withAnimation(.easeInOut(duration: 0.3)) {
            pageTransitioning = true
            contentOpacity = 0
            warpScale = 0.8
            rotationAngle += 180
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            action()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.7)) {
                pageTransitioning = false
                contentOpacity = 1
                warpScale = 1.05
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            withAnimation(.easeOut(duration: 0.3)) {
                warpScale = 1
            }
        }
    }
    
    
    // MARK: Loading Overlay Helpers (新增)
    
    private func loadWithOverlay(_ action: @escaping () -> Void) {
        let token = UUID()
        pendingLoadToken = token
        
        // 轻微延迟：避免“闪一下”的尴尬（数据很快时不显示）
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            guard pendingLoadToken == token else { return }
            withAnimation(.easeInOut(duration: 0.25)) {
                isLoadingOverlayVisible = true
            }
            // 丝滑呼吸脉冲
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                loadingPulse = true
            }
        }
        
        action()
        
        // 兜底：即使没有触发任何 onChange（极端情况）也会自动收起
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
            guard pendingLoadToken == token else { return }
            hideOverlay()
        }
    }
    
    private func hideOverlayIfReady() {
        // 只要有任何一个“有意义的数据”出现，就认为网络回来了 -> 淡出
        let hasAnyData =
        !viewModel.title.isEmpty ||
        !viewModel.contents.isEmpty ||
        !viewModel.posts.isEmpty
        
        guard hasAnyData else { return }
        hideOverlay()
    }
    
    private func hideOverlay() {
        pendingLoadToken = UUID() // 失效旧 token
        withAnimation(.easeInOut(duration: 0.35)) {
            isLoadingOverlayVisible = false
            loadingPulse = false
        }
    }
    
    
    // MARK: Loading Overlay View (新增)
    
    private var loadingOverlay: some View {
        ZStack {
            // 轻雾化遮罩，保持主题的 cyan/blue 光感
            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(0.85)
                .ignoresSafeArea()
                .overlay(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.15),
                            Color.cyan.opacity(0.18),
                            Color.blue.opacity(0.16)
                        ],
                        center: .center,
                        startRadius: 40,
                        endRadius: 520
                    )
                    .blendMode(.plusLighter)
                )
            
            VStack(spacing: 14) {
                ZStack {
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.cyan.opacity(0.9), .blue.opacity(0.75)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 62, height: 62)
                        .opacity(0.85)
                        .scaleEffect(loadingPulse ? 1.10 : 0.92)
                        .blur(radius: loadingPulse ? 0.0 : 0.6)
                    
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.white.opacity(0.55), Color.cyan.opacity(0.35), Color.blue.opacity(0.22)],
                                center: .center,
                                startRadius: 4,
                                endRadius: 42
                            )
                        )
                        .frame(width: 52, height: 52)
                        .opacity(0.85)
                        .scaleEffect(loadingPulse ? 1.00 : 0.90)
                    
                    Image(systemName: "bolt.circle.fill")
                        .font(.system(size: 26, weight: .semibold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .cyan, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .blue.opacity(0.35), radius: 10)
                        .rotationEffect(.degrees(loadingPulse ? 8 : -8))
                }
                
                Text("Syncing Neural Stream…")
                    .font(.system(.callout, design: .monospaced))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .cyan, .white],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.55))
                    .cornerRadius(18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(
                                LinearGradient(
                                    colors: [.cyan.opacity(0.85), .blue.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: .blue.opacity(0.25), radius: 10)
                    .opacity(loadingPulse ? 1.0 : 0.82)
            }
            .padding(20)
        }
        .allowsHitTesting(true) // 覆盖期间阻止误触
        .onAppear {
            // 如果 overlay 直接显示（比如外部强制），确保脉冲启动
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                loadingPulse = true
            }
        }
        .onDisappear {
            loadingPulse = false
        }
    }
}


// Post 样式
struct PostStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(.callout, design: .monospaced))
            .foregroundColor(.blue)
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.65))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        LinearGradient(
                            colors: [.cyan.opacity(0.8), .blue.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .cornerRadius(18)
            .shadow(color: .blue.opacity(0.3), radius: 8)
            .padding(.vertical, 6)
    }
}
