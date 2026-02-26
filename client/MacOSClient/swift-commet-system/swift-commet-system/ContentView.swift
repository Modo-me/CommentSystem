import SwiftUI

public struct ContentView: View {
    
    @ObservedObject private var viewModel: PageViewModel
    @State private var inputId: String = ""
    @State private var animateBackground = false
    
    // 过渡状态
    @State private var pageTransitioning = false
    @State private var contentOpacity: Double = 1
    @State private var warpScale: CGFloat = 1
    @State private var rotationAngle: Double = 0
    
    init(viewModel: PageViewModel){
        self.viewModel = viewModel
    }
    
    public var body: some View {
        
        ZStack {
            
            // 浅蓝科技背景
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
            
            VStack(spacing: 20) {
                
                // 图标
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
                    .scaleEffect(pageTransitioning ? 0.85 : 1.05)
                    .opacity(pageTransitioning ? 0.7 : 1)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: pageTransitioning)
                
                
                // 内容
                Group {
                    if viewModel.contents.isEmpty {
                        Text("Initializing Data Stream...")
                            .font(.system(size: 16, weight: .medium, design: .monospaced))
                            .foregroundStyle(.blue)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 20)
                            .background(Color.white.opacity(0.6))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.blue.opacity(0.4), lineWidth: 1)
                            )
                    } else {
                        Text(viewModel.contents)
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
                            .transition(.opacity.combined(with: .scale))
                    }
                }
                
                
                // 按钮
                HStack(spacing: 12) {
                    button("Home", "house.fill", id: 1)
                    button("教程", "book.fill", id: 3)
                    button("赞助Modo", "heart.fill", id: 2)
                }
                .searchable(text: $inputId)
                .onChange(of: inputId) {
                    triggerWarp {
                        viewModel.loadPageByTopic(input: inputId)
                    }
                }
                .controlSize(.large)
                .padding(.horizontal)
                
                
                // Posts
                ForEach(Array(viewModel.posts.enumerated()), id: \.element.id) { index, post in
                    
                    Group {
                        if let url = URL(string: post.content),
                           url.scheme?.hasPrefix("http") == true {
                            
                            Link(post.content, destination: url)
                                .modifier(PostStyle())
                        } else {
                            Text(post.content)
                                .modifier(PostStyle())
                        }
                    }
                    .opacity(contentOpacity)
                    .offset(y: pageTransitioning ? 20 : 0)
                    .animation(
                        .spring(response: 0.6, dampingFraction: 0.85)
                        .delay(Double(index) * 0.05),
                        value: pageTransitioning
                    )
                }
            }
            .padding()
            .opacity(contentOpacity)
            .scaleEffect(warpScale)
            .rotation3DEffect(
                .degrees(pageTransitioning ? 15 : 0),
                axis: (x: 1, y: 0, z: 0),
                perspective: 0.7
            )
            .blur(radius: pageTransitioning ? 8 : 0)
            .animation(.easeInOut(duration: 0.5), value: pageTransitioning)
        }
        .task {
            animateBackground = true
            viewModel.loadPageById(input: 1)
        }
    }
    
    
    // 按钮封装
    private func button(_ title: String, _ icon: String, id: Int) -> some View {
        Button {
            triggerWarp {
                viewModel.loadPageById(input: id)
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
    
    
    // 动画
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
