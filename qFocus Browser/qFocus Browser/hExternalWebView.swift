//
//  hExternalWebViewController.swift
//  qFocus Browser
//
//  Created by qSascha on 2025-02-01.
//

import SwiftUI
@preconcurrency import WebKit
import SwiftData





// MARK: - WebView - UIKit View
//Called from UIKit function: InternalWebView
class ExternalWebViewUIK: UIViewController {
    private let url: URL
    private let webViewModel = WebViewModel()
    private var webView: WKWebView!

    weak var delegate: ExternalWebViewUIKDelegate?

    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        setupNavigationBar()
    }
    
    private func setupWebView() {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .nonPersistent()
        configuration.processPool = WKProcessPool()
        
        webView = WKWebView(frame: view.bounds, configuration: configuration)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        
        webViewModel.webView = webView
        view.addSubview(webView)
        
        let request = URLRequest(url: url)
        webView.load(request)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        webView.scrollView.refreshControl = refreshControl
    }
    
    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.qBlueLight)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.compactScrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
   

        let tempButton = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "chevron.left")
        config.title = "Back"
        config.imagePadding = 8  // Spacing between image and text
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(scale: .medium)
        tempButton.configuration = config
        tempButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        tempButton.tintColor = .white
        let doneButton = UIBarButtonItem(customView: tempButton)

        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.backward"),
            style: .plain,
            target: webViewModel,
            action: #selector(WebViewModel.goBack)
        )
        backButton.isEnabled = webViewModel.canGoBack
        
        let forwardButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.forward"),
            style: .plain,
            target: webViewModel,
            action: #selector(WebViewModel.goForward)
        )
        forwardButton.isEnabled = webViewModel.canGoForward
        
        let shareButton = UIBarButtonItem(
            image: UIImage(systemName: "square.and.arrow.up"),
            style: .plain,
            target: self,
            action: #selector(showShareSheet)
        )
        
        let safariButton = UIBarButtonItem(
            image: UIImage(systemName: "safari"),
            style: .plain,
            target: self,
            action: #selector(openInSafari)
        )
        
        navigationItem.leftBarButtonItem = doneButton
        navigationItem.rightBarButtonItems = [
            safariButton,
            shareButton,
            forwardButton,
            backButton
        ]
    }
    
    @objc private func dismissView() {
        delegate?.externalWebViewWillDismiss()
        dismiss(animated: true) { [weak self] in
            self?.delegate?.externalWebViewDidDismiss()
        }
    }

    @objc private func showShareSheet() {
        let activityViewController = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )
        present(activityViewController, animated: true)
    }
    
    @objc private func openInSafari() {
        UIApplication.shared.open(url)
    }
    
    @objc private func handleRefresh(_ sender: UIRefreshControl) {
        webView.reload()
        sender.endRefreshing()
    }
}


// WebView Delegate Extensions
extension ExternalWebViewUIK: WKNavigationDelegate, WKUIDelegate {
    func webView(_ webView: WKWebView,
                decidePolicyFor navigationAction: WKNavigationAction,
                decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView,
                createWebViewWith configuration: WKWebViewConfiguration,
                for navigationAction: WKNavigationAction,
                windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let url = navigationAction.request.url {
            webView.load(URLRequest(url: url))
        }
        return nil
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Update navigation buttons state
        if let backButton = navigationItem.rightBarButtonItems?.last {
            backButton.isEnabled = webView.canGoBack
        }
        if let forwardButton = navigationItem.rightBarButtonItems?[2] {
            forwardButton.isEnabled = webView.canGoForward
        }
    }
}








// MARK: - WebView - SwiftUI View
// Called from SwifUI within NavigationStack
struct ExternalWebView: View {
    let url: URL
    @Environment(\.dismiss) private var dismiss
    @StateObject private var webViewModel = WebViewModel()
    @State private var showShareSheet = false


    var body: some View {
        ZStack {
            WebViewRepresentable(url: url, viewModel: webViewModel)
                .ignoresSafeArea(edges: .bottom)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: { webViewModel.goBack() }) {
                    Image(systemName: "chevron.backward")
                }
                .disabled(!webViewModel.canGoBack)
                
                Button(action: { webViewModel.goForward() }) {
                    Image(systemName: "chevron.forward")
                }
                .disabled(!webViewModel.canGoForward)
                
                Button(action: {showShareSheet = true} ) {
                    Image(systemName: "square.and.arrow.up")
                }
                
                Button(action: openInSafari) {
                    Image(systemName: "safari")
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: [url])
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }

    }
    

    // Open link in Safari
    private func openInSafari() {
        UIApplication.shared.open(url)
    }
    

    // ShareSheet struct for UIActivityViewController
    struct ShareSheet: UIViewControllerRepresentable {
        let activityItems: [Any]
        
        func makeUIViewController(context: Context) -> UIActivityViewController {
            let controller = UIActivityViewController(
                activityItems: activityItems,
                applicationActivities: nil
            )
            return controller
        }
        func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
    }

}




// MARK: - WebView ViewModel
class WebViewModel: ObservableObject {
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false
    weak var webView: WKWebView?
    
    @objc func goBack() {
        webView?.goBack()
    }
    
    @objc func goForward() {
        webView?.goForward()
    }
    
    func updateNavigationState() {
        // Ensure updates happen on main thread
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.canGoBack = self.webView?.canGoBack ?? false
            self.canGoForward = self.webView?.canGoForward ?? false
        }
    }
}




// MARK: - WebView Representable
struct WebViewRepresentable: UIViewRepresentable {
    let url: URL
    @ObservedObject var viewModel: WebViewModel
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .nonPersistent()
        configuration.processPool = WKProcessPool()
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        
        viewModel.webView = webView
        
        let request = URLRequest(url: url)
        webView.load(request)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(
            context.coordinator,
            action: #selector(Coordinator.handleRefresh),
            for: .valueChanged
        )
        webView.scrollView.refreshControl = refreshControl
        
        return webView
    }
    

    func updateUIView(_ webView: WKWebView, context: Context) {
        // Call updateNavigationState after a brief delay to avoid view update cycle
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            viewModel.updateNavigationState()
        }
    }

    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var parent: WebViewRepresentable
        
        init(_ parent: WebViewRepresentable) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView,
                    decidePolicyFor navigationAction: WKNavigationAction,
                    decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            decisionHandler(.allow)
        }
        
        func webView(_ webView: WKWebView,
                    createWebViewWith configuration: WKWebViewConfiguration,
                    for navigationAction: WKNavigationAction,
                    windowFeatures: WKWindowFeatures) -> WKWebView? {
            if let url = navigationAction.request.url {
                webView.load(URLRequest(url: url))
            }
            return nil
        }
        
        @objc func handleRefresh(_ sender: UIRefreshControl) {
            parent.viewModel.webView?.reload()
            sender.endRefreshing()
        }
    }
}



