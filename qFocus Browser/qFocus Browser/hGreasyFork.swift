//
//  hGreasyFork.swift
//  qFocus Browser
//
//  Created by Sascha on 2025-02-13.
//
import WebKit
import Foundation
import SwiftData








class GreasyFork: ObservableObject {
    private let modelContext: ModelContext
    private let globals: GlobalVariables

    var loadedScripts: [String: (metadata: ScriptMetadata, code: String)] = [:]
    @Published private(set) var domainsWithInjectedScripts: Set<String> = []
    




    init(modelContext: ModelContext, globals: GlobalVariables) {
        self.modelContext = modelContext
        self.globals = globals
    }
    



    enum InjectionTime {
        case documentStart
        case documentEnd
        case documentIdle
        
        var webViewTime: WKUserScriptInjectionTime {
            switch self {
            case .documentStart:
                return .atDocumentStart
            case .documentEnd, .documentIdle:
                return .atDocumentEnd
            }
        }
    }
    



    struct ScriptMetadata {
        let name: String
        let description: String?
        let version: String?
        let injectionTime: InjectionTime
        let requires: [String]
        
        init(from metadataDict: [String: [String]]) {
            self.name = metadataDict["name"]?.first ?? "Unnamed Script"
            self.description = metadataDict["description"]?.first
            self.version = metadataDict["version"]?.first
            
            let runAt = metadataDict["run-at"]?.first ?? "document-end"
            switch runAt {
            case "document-start":
                self.injectionTime = .documentStart
            case "document-idle":
                self.injectionTime = .documentIdle
            default:
                self.injectionTime = .documentEnd
            }
            
            self.requires = metadataDict["require"] ?? []
        }
    }
    




    //MARK: Parse Script
    func parseScript(_ content: String) -> (metadata: ScriptMetadata, code: String)? {
        let pattern = #"(?:(\/\/ ==UserScript==[ \t]*?\r?\n([\S\s]*?)\r?\n\/\/ ==\/UserScript==)([\S\s]*))"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: content, range: NSRange(content.startIndex..., in: content)) else {
            return nil
        }
        
        guard let metaRange = Range(match.range(at: 2), in: content),
              let codeRange = Range(match.range(at: 3), in: content) else {
            return nil
        }
        
        let metaBlock = String(content[metaRange])
        let code = String(content[codeRange]).trimmingCharacters(in: .whitespacesAndNewlines)
        
        var metadata: [String: [String]] = [:]
        let metaLines = metaBlock.split(whereSeparator: \.isNewline)
        
        for line in metaLines {
            let pattern = #"^(?:[ \t]*(?:\/\/)?[ \t]*@)([\w-]+)[ \t]+([^\s]+[^\r\n\t\v\f]*)"#
            guard let regex = try? NSRegularExpression(pattern: pattern),
                  let match = regex.firstMatch(in: String(line), range: NSRange(line.startIndex..., in: line)),
                  let keyRange = Range(match.range(at: 1), in: line),
                  let valueRange = Range(match.range(at: 2), in: line) else {
                continue
            }
            
            let key = String(line[keyRange])
            let value = String(line[valueRange])
            
            if metadata[key] == nil {
                metadata[key] = []
            }
            metadata[key]?.append(value)
        }
        
        let scriptMetadata = ScriptMetadata(from: metadata)
        return (scriptMetadata, code)
    }
    




    //MARK: Load Script
    func loadScripts(for siteURL: URL, webViewController: WebViewController) {
        let strongWebViewController = webViewController
        let siteName = siteURL.host ?? ""
        
        print("Loading GreasyFork scripts for site: \(siteName)")
        
        // Clear previous scripts when loading new ones
        loadedScripts.removeAll()
        
        // Fetch script settings from SwiftData
        let descriptor = FetchDescriptor<greasyScriptSetting>()
        guard let scriptSettings = try? modelContext.fetch(descriptor) else {
            print("Failed to fetch script settings")
            return
        }

        // Get the core domain for comparison
        let coreDomain = getDomainCore(siteName)
        print("DEBUG: Loading scripts for core domain: \(coreDomain)")

        // Filter scripts where the core domains match and the script is enabled in settings
        let matchingScripts = globals.greaseForkList.filter { script in
            // Check if script matches domain and has an enabled setting
            return script.coreSite == coreDomain &&
                   scriptSettings.first(where: { $0.scriptID == script.scriptID })?.scriptEnabled ?? script.scriptEnabled
        }
        
        if matchingScripts.isEmpty {
            print("No matching scripts found for domain: \(coreDomain)")
            return
        }
        
        // Create outer group for script loading
        let loadingGroup = DispatchGroup()
        // Create strong reference to self
        let strongSelf = self
        
        for script in matchingScripts {
            loadingGroup.enter()
            print("Loading script: \(script.scriptName)")
            
            loadRemoteScript(from: script.scriptURL) { [weak self] result in
                defer { loadingGroup.leave() }
                
                switch result {
                case .success(let content):
                    if let parsed = self?.parseScript(content) {
                        DispatchQueue.main.async {
                            self?.loadedScripts[script.scriptName] = parsed
                        }
                    } else {
                        print("Failed to parse script: \(script.scriptName)")
                    }
                case .failure(let error):
                    print("Failed to load script \(script.scriptName): \(error)")
                }
            }
        }
        
        // After all scripts are loaded, handle dependencies and injection
        loadingGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            
            let scriptIdentifiers = Array(self.loadedScripts.keys)
            print("Loaded script identifiers: \(scriptIdentifiers)")
            
            if scriptIdentifiers.isEmpty {
                print("No scripts were successfully loaded")
                return
            }
            
            // Create dependencies group
            let dependenciesGroup = DispatchGroup()
            
            // Load dependencies for each script
            for identifier in scriptIdentifiers {
                dependenciesGroup.enter()
                print("Loading dependencies for script: \(identifier)")
                
                strongSelf.loadDependencies(for: identifier) { success in
                    defer { dependenciesGroup.leave() }
                    
                    if !success {
                        print("ERROR: Failed to load dependencies for \(identifier)")
                    } else {
                        print("Successfully loaded dependencies for \(identifier)")
                    }
                }
            }
            
            // After all dependencies are handled, inject the scripts
            dependenciesGroup.notify(queue: .main) {
                print("All dependencies loaded, proceeding with injection...")
                strongSelf.injectScripts(into: strongWebViewController.webView)
                print("Script injection completed")
            }
        }
    }

/*
    private func getDomainCore(_ host: String) -> String {
        let components = host.lowercased().split(separator: ".")
        guard components.count >= 2 else { return host.lowercased() }
        let mainDomain = components.suffix(2).joined(separator: ".")
        return mainDomain
    }
*/
    
    
    
    
    
    //MARK: Clear Injected Scripts
    func clearInjectedScripts() {
        DispatchQueue.main.async {
            self.domainsWithInjectedScripts.removeAll()
        }
    }



    
    //MARK: Remove Single Injected Scripts
    func removeInjectedScripts(forHost host: String) {
        DispatchQueue.main.async {
            self.domainsWithInjectedScripts.remove(host)
        }
    }





    //MARK: Inject Script
    func injectScripts(into webView: WKWebView) {
        guard let host = webView.url?.host else {
            print("No host found for webView")
            return
        }

        for (_, script) in loadedScripts {
            let userScript = WKUserScript(
                source: script.code,
                injectionTime: script.metadata.injectionTime.webViewTime,
                forMainFrameOnly: true
            )
            webView.configuration.userContentController.addUserScript(userScript)
        }
        
        DispatchQueue.main.async {
            if !self.loadedScripts.isEmpty {
                self.domainsWithInjectedScripts.insert(getDomainCore(host))
            } else {
                print("No scripts were loaded for: \(host)")
            }
        }
    }
    





    //MARK: Load Dependencies
    func loadDependencies(for identifier: String, completion: @escaping (Bool) -> Void) {
        guard let script = loadedScripts[identifier] else {
            completion(false)
            return
        }
        
        let dependencies = script.metadata.requires
        guard !dependencies.isEmpty else {
            completion(true)
            return
        }
        
        let group = DispatchGroup()
        var success = true
        
        for dependency in dependencies {
            group.enter()
            
            loadRemoteScript(from: dependency) { [weak self] result in
                switch result {
                case .success(let content):
                    if let existingScript = self?.loadedScripts[identifier] {
                        let newCode = content + "\n" + existingScript.code
                        self?.loadedScripts[identifier] = (existingScript.metadata, newCode)
                    }
                case .failure(_):
                    success = false
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(success)
        }
    }
    





    //MARK: Load Remote Script
    private func loadRemoteScript(from url: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: url) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1)))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data,
                  let content = String(data: data, encoding: .utf8) else {
                completion(.failure(NSError(domain: "Invalid data", code: -2)))
                return
            }
   
            
            print("Loaded remote script: \(url)")
            completion(.success(content))
        }.resume()
    }
}

