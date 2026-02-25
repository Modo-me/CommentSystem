import SwiftUI

public struct ContentView: View {
    
    @ObservedObject private var viewModel: PageViewModel
    @State private var inputId: String = ""
    @State private var animateGradient = false
    
    // 过渡状态
    @State private var pageTransitioning = false
    @State private var contentOpacity: Double = 1
    @State private var warpScale: CGFloat = 1
    @State private var hueRotation: Double = 0
    
    init(viewModel: PageViewModel){
        self.viewModel = viewModel
    }
    
    public var body: some View {
        
        ZStack {
            
            // 超级动态宇宙背景
            LinearGradient(
                colors: animateGradient ?
                [.purple, .blue, .pink, .orange] :
                [.orange, .pink, .blue, .purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .hueRotation(.degrees(hueRotation))
            .saturation(pageTransitioning ? 2 : 1)
            .contrast(pageTransitioning ? 1.3 : 1)
            .scaleEffect(pageTransitioning ? 1.6 : 1)
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.8), value: pageTransitioning)
            .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true), value: animateGradient)
            
            
            VStack(spacing: 20) {
                
                // 图标
                Image(systemName: "globe")
                    .font(.system(size: 55))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.cyan, .purple, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .cyan, radius: pageTransitioning ? 40 : 20)
                    .rotationEffect(.degrees(animateGradient ? 360 : 0))
                    .scaleEffect(pageTransitioning ? 1.4 : 1)
                    .animation(.linear(duration: 20).repeatForever(autoreverses: false), value: animateGradient)
                
                
                // 标题
                Text(viewModel.title)
                    .font(.system(size: 36, weight: .black))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .yellow, .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: .white.opacity(0.9), radius: 10)
                    .scaleEffect(pageTransitioning ? 0.7 : 1.05)
                    .animation(.spring(response: 0.6, dampingFraction: 0.6), value: pageTransitioning)
                
                
                // 内容
                Group {
                    if viewModel.contents.isEmpty {
                        Text("Loading...")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.8))
                            .padding(.vertical, 12)
                            .padding(.horizontal, 20)
                            .background(.ultraThinMaterial)
                            .cornerRadius(18)
                            .shadow(radius: 8)
                    } else {
                        Text(viewModel.contents)
                            .font(.callout)
                            .foregroundColor(.white)
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(20)
                            .shadow(radius: 10)
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .opacity
                            ))
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
                
                
                //  Posts
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
                    .offset(y: pageTransitioning ? 40 : 0)
                    .animation(
                        .spring(response: 0.6, dampingFraction: 0.8)
                        .delay(Double(index) * 0.05),
                        value: pageTransitioning
                    )
                }
            }
            .padding()
            .opacity(contentOpacity)
            .scaleEffect(warpScale)
            .rotation3DEffect(
                .degrees(pageTransitioning ? 25 : 0),
                axis: (x: 1, y: 1, z: 0),
                perspective: 0.6
            )
            .blur(radius: pageTransitioning ? 18 : 0)
            .animation(.easeInOut(duration: 0.5), value: pageTransitioning)
        }
        .task {
            animateGradient = true
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
                .frame(maxWidth: .infinity)
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .shadow(color: .white.opacity(0.6), radius: 10)
        }
        .buttonStyle(.plain)
    }
    
    
    // 动画
    private func triggerWarp(action: @escaping () -> Void) {
        
        withAnimation(.easeInOut(duration: 0.35)) {
            pageTransitioning = true
            contentOpacity = 0
            warpScale = 0.6
            hueRotation += 180
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            action()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                pageTransitioning = false
                contentOpacity = 1
                warpScale = 1.05
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
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
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [.cyan, .purple, .pink],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
            )
            .shadow(color: .purple.opacity(0.6), radius: 15)
            .padding(.vertical, 6)
    }
}
