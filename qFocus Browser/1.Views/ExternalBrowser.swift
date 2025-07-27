//
//  ExternalBrowser.swift
//  qFocus Browser
//
//
import SwiftUI
import WebKit

enum ScrollDirection {
    case up
    case down
}

struct ExternalBrowserView: View {
    @ObservedObject var viewModel: ExternalBrowserVM
    @Environment(\.dismiss) private var dismiss
    @State private var isSharing = false
    @State private var showToolbar: Bool = true
    
    
    
    var body: some View {
        
        if #available(iOS 26.0, *) {
            
            ZStack(alignment: .bottomTrailing) {
                ExtWebViewRepresentable(
                    webView: viewModel.webView,
                    onSwipeBack: {
                        viewModel.goBackOrClose { dismiss() }
                    },
                    onScrollDirection: { direction in
                        withAnimation(.easeInOut(duration: 0.5)) {
                            switch direction {
                            case .up:
                                showToolbar = false
                            case .down:
                                showToolbar = true
                            }
                        }
                    }
                )
                .ignoresSafeArea()
                .onAppear() {
                    Collector.shared.save(event: "ExternalBrowser", parameter: "URL: \(viewModel.url)")
                }
                
                HStack(spacing: 32) {
                    Button {
                        isSharing = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: (24), height: (24), alignment: .center)
                    }
                    
                    Button {
                        UIApplication.shared.open(viewModel.webView.url ?? viewModel.url)
                    } label: {
                        Image(systemName: "safari")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: (22), height: (22), alignment: .center)
                    }
                    
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: (20), height: (20), alignment: .center)
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 20)
                .glassEffect()
                .padding(.trailing, 32)
                .offset(y: showToolbar ? 0 : 120)
                .opacity(showToolbar ? 1 : 0)
                .animation(.easeInOut(duration: 0.5), value: showToolbar)
            }
            .sheet(isPresented: $isSharing) {
                ShareSheet(activityItems: viewModel.shareSheetItems())
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        } else {
            
            //Legacy Versions
            ZStack(alignment: .bottomTrailing) {
                ExtWebViewRepresentable(
                    webView: viewModel.webView,
                    onSwipeBack: {
                        viewModel.goBackOrClose { dismiss() }
                    },
                    onScrollDirection: { direction in
                        withAnimation(.easeInOut(duration: 0.5)) {
                            switch direction {
                            case .up:
                                showToolbar = false
                            case .down:
                                showToolbar = true
                            }
                        }
                    }
                )
                .ignoresSafeArea()
                .onAppear() {
                    Collector.shared.save(event: "ExternalBrowser", parameter: "URL: \(viewModel.url)")
                }
                
                HStack(spacing: 32) {
                    Button {
                        isSharing = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: (24), height: (24), alignment: .center)
                    }
                    
                    Button {
                        UIApplication.shared.open(viewModel.webView.url ?? viewModel.url)
                    } label: {
                        Image(systemName: "safari")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: (22), height: (22), alignment: .center)
                    }
                    
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: (20), height: (20), alignment: .center)
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 20)
                .background(Color.gray.opacity(0.5))
                .cornerRadius(20)
                .padding(.trailing, 32)
                .offset(y: showToolbar ? 0 : 120)
                .opacity(showToolbar ? 1 : 0)
                .animation(.easeInOut(duration: 0.5), value: showToolbar)
            }
            .sheet(isPresented: $isSharing) {
                ShareSheet(activityItems: viewModel.shareSheetItems())
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
            
        }
    }
}



//MARK: Ext Web View Representable
struct ExtWebViewRepresentable: UIViewRepresentable {
    let webView: WKWebView
    let onSwipeBack: () -> Void
    var onScrollDirection: ((ScrollDirection) -> Void)? = nil

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: container.topAnchor),
            webView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])

        // Detect edge swipe (back gesture)
        let edgePan = UIScreenEdgePanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleSwipeBack(_:)))
        edgePan.edges = .left
        container.addGestureRecognizer(edgePan)

        webView.scrollView.delegate = context.coordinator

        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onSwipeBack: onSwipeBack, onScrollDirection: onScrollDirection)
    }

    class Coordinator: NSObject, UIScrollViewDelegate {
        let onSwipeBack: () -> Void
        var onScrollDirection: ((ScrollDirection) -> Void)?
        private var previousContentOffsetY: CGFloat = 0

        init(onSwipeBack: @escaping () -> Void, onScrollDirection: ((ScrollDirection) -> Void)? = nil) {
            self.onSwipeBack = onSwipeBack
            self.onScrollDirection = onScrollDirection
            super.init()
        }

        @MainActor @objc func handleSwipeBack(_ gesture: UIScreenEdgePanGestureRecognizer) {
            if gesture.state == .recognized {
                onSwipeBack()
            }
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let currentY = scrollView.contentOffset.y
            let delta = currentY - previousContentOffsetY
            if abs(delta) > 3 {
                if delta > 0 {
                    onScrollDirection?(.up)
                } else if delta < 0 {
                    onScrollDirection?(.down)
                }
            }
            previousContentOffsetY = currentY
        }
    }
}



/*
struct ActivityView: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
*/




