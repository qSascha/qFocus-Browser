//
//  ExternalWebViewController.swift
//  qFocus Browser
//
//  Created by qSascha on 2025-02-01.
//

import WebKit
import UIKit
import SwiftUI
import SwiftData



class ExternalWebViewController: UIViewController {
    private var webView: WKWebView!
    private let url: URL
    private var toolbarHeight: CGFloat = 44
    private var toolbar: UIToolbar!
    private var settings: settingsStorage?
    private let modelContext: ModelContext
    
    init(url: URL, modelContext: ModelContext) {
        self.url = url
        self.modelContext = modelContext
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchSettings()
        setupUI()
        loadURL()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateLayout()
    }
    
    private func fetchSettings() {
        do {
            let descriptor = FetchDescriptor<settingsStorage>()
            let settingsArray = try modelContext.fetch(descriptor)
            
            if let firstSettings = settingsArray.first {
                settings = firstSettings
            }
        } catch {
            print("Error fetching settings: \(error)")
            // Use default bottom navigation if settings can't be fetched
            settings = settingsStorage(
                navOption: .freeFlow,
                opacity: 0.7,
                enableAdBlock: true,
                freeFlowX: UIScreen.main.bounds.width - 50,
                freeFlowY: UIScreen.main.bounds.height - 100,
                showTopBar: true,
                showBottomBar: false
            )
        }
    }

    private func setupUI() {
        setupToolbar()
        setupWebView()
        setupRefreshControl()
    }
    
    private func setupToolbar() {

        // Create toolbar
        toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolbar)
        
        // Create toolbar items
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(backButtonTapped))
        let forwardButton = UIBarButtonItem(image: UIImage(systemName: "chevron.forward"),
                                            style: .plain,
                                            target: self,
                                            action: #selector(forwardButtonTapped))
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh,
                                            target: self,
                                            action: #selector(refreshButtonTapped))
        let shareButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(shareButtonTapped))
        let safariButton = UIBarButtonItem(image: UIImage(systemName: "safari"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(openInSafari))
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done,
                                         target: self,
                                         action: #selector(doneButtonTapped))
        
        toolbar.items = [doneButton, flexSpace, backButton, flexSpace, forwardButton, flexSpace, refreshButton, shareButton, safariButton]

        // Setup constraints
        if settings?.navOption == .top {
            NSLayoutConstraint.activate([
                toolbar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                toolbar.heightAnchor.constraint(equalToConstant: toolbarHeight)
            ])
        } else {
            NSLayoutConstraint.activate([
                toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                toolbar.heightAnchor.constraint(equalToConstant: toolbarHeight)
            ])
        }

    }
    
    @objc private func openInSafari() {
        let currentURL = webView.url ?? url
        UIApplication.shared.open(currentURL)
    }

    @objc private func shareButtonTapped() {
        guard let url = webView.url else { return }
        
        let activityViewController = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )
        
        // For iPad: Present the share sheet in a popover
        if let popoverController = activityViewController.popoverPresentationController {
            // Find the share button's view in the toolbar
            if let shareButton = toolbar.items?.first(where: { $0.image == UIImage(systemName: "square.and.arrow.up") }) {
                popoverController.barButtonItem = shareButton
            }
        }
        
        present(activityViewController, animated: true)
    }


    private func setupWebView() {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .nonPersistent()
        configuration.processPool = WKProcessPool()
        
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        view.addSubview(webView)
        
        // Setup constraints based on navOption
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        if settings?.navOption == .top {
            NSLayoutConstraint.activate([
                webView.topAnchor.constraint(equalTo: toolbar.bottomAnchor),
                webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                webView.topAnchor.constraint(equalTo: view.topAnchor),
                webView.bottomAnchor.constraint(equalTo: toolbar.topAnchor)
            ])
        }
    }

    private func updateLayout() {

        toolbar.frame.size.width = view.bounds.width
        if settings?.navOption == .top {
            webView.frame = CGRect(x: 0,
                                 y: toolbarHeight,
                                 width: view.bounds.width,
                                 height: view.bounds.height - toolbarHeight)
        } else {
            webView.frame = CGRect(x: 0,
                                 y: 0,
                                 width: view.bounds.width,
                                 height: view.bounds.height - toolbarHeight)
        }
    }

    private func setupRefreshControl() {
        webView.scrollView.bounces = true
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshWebView), for: UIControl.Event.valueChanged)
        webView.scrollView.addSubview(refreshControl)
    }

    @objc func refreshWebView(sender: UIRefreshControl) {
        webView.reload()
        sender.endRefreshing()
    }

    private func loadURL() {
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    // MARK: - Button Actions
    @objc private func backButtonTapped() {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    
    @objc private func forwardButtonTapped() {
        if webView.canGoForward {
            webView.goForward()
        }
    }
    
    @objc private func refreshButtonTapped() {
        webView.reload()
    }
    
    @objc private func doneButtonTapped() {
        // Clear website data before dismissing
        WKWebsiteDataStore.default().removeData(
            ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
            modifiedSince: .distantPast
        ) { [weak self] in
            DispatchQueue.main.async {
                self?.dismiss(animated: true)
            }
        }
    }
    
}

// MARK: - WKNavigationDelegate
extension ExternalWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
        }
        decisionHandler(.allow)
    }
}

// MARK: - WKUIDelegate
extension ExternalWebViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let url = navigationAction.request.url {
            webView.load(URLRequest(url: url))
        }
        return nil
    }
}


//MARK: External Wev View Warpper
struct ExternalWebViewWrapper: UIViewControllerRepresentable {
    let url: URL
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> ExternalWebViewController {
        let webVC = ExternalWebViewController(url: url, modelContext: modelContext)
        return webVC
    }
    
    func updateUIViewController(_ uiViewController: ExternalWebViewController, context: Context) {
    }
}
