//
//  iOSOptionsGreasyWiz2.swift
//  qFocus Browser
//
// Refactored to push edit view onto navigation stack and remove previous two views.
import SwiftUI
import WebKit
import FactoryKit
import Foundation



struct GreasyWizard2: View {
    @EnvironmentObject var nav: NavigationStateManager

    @ObservedObject var viewModel: GreasyBrowserVM
    @InjectedObject(\.greasyRepo) private var greasyRepo
    @InjectedObject(\.sitesRepo) private var sitesRepo
    @Environment(\.dismiss) private var dismiss

    @State private var showEditView = false
    @State private var newScript: defaultGreasyScriptItem?

    var onDetectedScriptInfo: ((String?, String?, String?, String?) -> Void)? = nil


    var body: some View {
        GreasyWebViewRepresentable(
            webView: viewModel.webView,
            onSwipeBack: { viewModel.goBackOrClose { dismiss() } },
            onDetectedUserScriptPage: { viewModel.detectedUserScriptPage = $0 },
            onDetectedScriptInfo: { name, currentURL, previousURL, description in
                newScript = defaultGreasyScriptItem(
                    scriptName: name ?? "",
                    scriptID: UUID().uuidString,
                    coreSite: "###disabled###",
                    scriptEnabled: true,
                    scriptExplanation: description ?? "",
                    scriptLicense: "###",
                    siteURL: previousURL ?? "",
                    scriptURL: currentURL ?? "",
                    defaultScript: false
                )

                showEditView = true

            }
        )
        .ignoresSafeArea()
        .navigationDestination(isPresented: $showEditView) {
            iOSOptionsGreasyEdit(scriptObject: nil, greasyRepo: greasyRepo, sitesRepo: sitesRepo, newScript: newScript)
        }

    }
    
}



struct GreasyWebViewRepresentable: UIViewRepresentable {
    let webView: WKWebView
    let onSwipeBack: () -> Void
    var onDetectedUserScriptPage: ((Bool) -> Void)? = nil
    var onDetectedUserScriptName: ((String) -> Void)? = nil
    var onDetectedScriptInfo: ((String?, String?, String?, String?) -> Void)? = nil


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
        
        webView.navigationDelegate = context.coordinator
        
        return container
    }
    
    
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onSwipeBack: onSwipeBack, onDetectedUserScriptPage: onDetectedUserScriptPage, onDetectedScriptInfo: onDetectedScriptInfo)
    }
    
    
    
    
    class Coordinator: NSObject, WKNavigationDelegate {
        let onSwipeBack: () -> Void
        var onDetectedUserScriptPage: ((Bool) -> Void)?
        var onDetectedScriptInfo: ((String?, String?, String?, String?) -> Void)?
        
        var previousURLString: String? = ""
        var currentURLString: String? = ""
        var detectedUserScriptName: String? = ""
        var detectedUserScriptDescription: String? = ""
        


        init(onSwipeBack: @escaping () -> Void, onDetectedUserScriptPage: ((Bool) -> Void)? = nil, onDetectedScriptInfo: ((String?, String?, String?, String?) -> Void)? = nil) {
            self.onSwipeBack = onSwipeBack
            self.onDetectedUserScriptPage = onDetectedUserScriptPage
            self.onDetectedScriptInfo = onDetectedScriptInfo
            
            super.init()
        }
        

        @MainActor @objc func handleSwipeBack(_ gesture: UIScreenEdgePanGestureRecognizer) {
            if gesture.state == .recognized {
                onSwipeBack()
            }
        }
        

        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            previousURLString = currentURLString
            currentURLString = webView.url?.absoluteString
            
            webView.evaluateJavaScript("document.body.innerText.split('\\n').slice(0,100)") { result, error in
                if let lines = result as? [String] {
                    if let userScriptLine = lines.first(where: { $0.contains("=UserScript=") }) {
                        self.onDetectedUserScriptPage?(true)
                        print("=== Found Script ===")
                        // Look for name and description anywhere after the UserScript line
                        if let nameLine = lines.first(where: { $0.contains("// @name") }),
                           let namePrefixRange = nameLine.range(of: "// @name") {
                            let nameText = nameLine[namePrefixRange.upperBound...].trimmingCharacters(in: .whitespaces)
                            self.detectedUserScriptName = String(nameText)
                        } else {
                            self.detectedUserScriptName = nil
                        }
                        if let descLine = lines.first(where: { $0.contains("// @description") }),
                           let range = descLine.range(of: "// @description") {
                            let descText = descLine[range.upperBound...].trimmingCharacters(in: .whitespaces)
                            self.detectedUserScriptDescription = String(descText)
                        } else {
                            self.detectedUserScriptDescription = nil
                        }
                        self.onDetectedScriptInfo?(self.detectedUserScriptName, self.currentURLString, self.previousURLString, self.detectedUserScriptDescription)
                    } else {
                        self.onDetectedUserScriptPage?(false)
                        self.detectedUserScriptName = nil
                        self.detectedUserScriptDescription = nil
                    }
                } else {
                    self.onDetectedUserScriptPage?(false)
                    self.detectedUserScriptName = nil
                    self.detectedUserScriptDescription = nil
                }
            }
        }
    }
    
    
    
}





