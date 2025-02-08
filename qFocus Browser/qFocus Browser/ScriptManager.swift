//
//  ScriptManager.swift
//  qFocus Browser
//
//  Created by Sascha on 2025-02-04.
//

import WebKit
import Foundation




class ScriptManager: ObservableObject {

    var loadedScripts: [String: (metadata: ScriptMetadata, code: String)] = [:]
    @Published private(set) var domainsWithInjectedScripts: Set<String> = []


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
            
            // Parse injection time
            let runAt = metadataDict["run-at"]?.first ?? "document-end"
            switch runAt {
            case "document-start":
                self.injectionTime = .documentStart
            case "document-idle":
                self.injectionTime = .documentIdle
            default:
                self.injectionTime = .documentEnd
            }
            
            // Parse requirements
            self.requires = metadataDict["require"] ?? []
        }
    }
    
    




    //MARK: Parse Script
    func parseScript(_ content: String) -> (metadata: ScriptMetadata, code: String)? {
        // Parse metadata block
        let pattern = #"(?:(\/\/ ==UserScript==[ \t]*?\r?\n([\S\s]*?)\r?\n\/\/ ==\/UserScript==)([\S\s]*))"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: content, range: NSRange(content.startIndex..., in: content)) else {
            return nil
        }
        
        // Extract metadata and code sections
        guard let metaRange = Range(match.range(at: 2), in: content),
              let codeRange = Range(match.range(at: 3), in: content) else {
            return nil
        }
        
        let metaBlock = String(content[metaRange])
        let code = String(content[codeRange]).trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Parse metadata lines
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
    func loadScripts(for siteURL: URL, webViewController: ContentBlockingWebViewController) {
        // Store a strong reference to the webViewController
        let strongWebViewController = webViewController
        let siteName = siteURL.host ?? ""
        let fileManager = FileManager.default

        print("----------------- Loading scripts for site: \(siteName)")

        // Clear previous scripts when loading new ones
//        loadedScripts.removeAll()
        
        if let resourcePath = Bundle.main.resourcePath {
            do {
                let scriptsPath = ((resourcePath as NSString).appendingPathComponent("JavaScripts") as NSString)
                    .appendingPathComponent(siteName)
                if fileManager.fileExists(atPath: scriptsPath) {
                    let scriptFiles = try FileManager.default.contentsOfDirectory(atPath: scriptsPath)
                    
                    var scriptsLoaded = false
                    for scriptFile in scriptFiles {
                        if scriptFile.hasSuffix(".js") {
                            let fullPath = (scriptsPath as NSString).appendingPathComponent(scriptFile)
                            let content = try String(contentsOf: URL(fileURLWithPath: fullPath), encoding: .utf8)

                            if let parsed = parseScript(content) {
                                loadedScripts[scriptFile] = parsed
                                scriptsLoaded = true
                            }
                        }
                    }
                    print("Scripts loaded: \(scriptsLoaded)")

                    if scriptsLoaded {
                        let group = DispatchGroup()
                        let scriptIdentifiers = Array(loadedScripts.keys)
                        print("Script identifiers: \(scriptIdentifiers)")
                        
                        if scriptIdentifiers.isEmpty {
                            print("No script identifiers found")
                            return
                        }
                        
                        // Create a strong reference to self
                        let strongSelf = self
                        
                        for identifier in scriptIdentifiers {
                            print("Loading dependencies for script \(identifier)")
                            group.enter()
                            strongSelf.loadDependencies(for: identifier) { success in
                                defer { group.leave() }
                                
                                if !success {
                                    print("ERROR: Failed to load dependencies for \(identifier)")
                                } else {
                                    print("Successfully loaded dependencies for \(identifier)")
                                }
                            }
                        }
                        
                        print("Waiting for all dependencies...")
                        group.notify(queue: .main) {
                            print("All dependencies completed. Proceeding with injection...")
                            strongSelf.injectScripts(into: strongWebViewController.webView)
                            print("Successfully injected scripts.")
                        }
                    }
                } else {
                    print("WARNING: Scripts folder does not exist for \(siteName).")
                }
            } catch {
                print("ERROR: Failed to list/load contents: \(error)")
            }
        }
    }
    




    //MARK: Inject Script
    func injectScripts(into webView: WKWebView) {
        print("Now inside the injectScripts function")
        guard let host = webView.url?.host else {
            print("No host found for webView")
            return
        }

        print("Attempting to inject scripts for \(host)")
        print("Current loadedScripts count: \(loadedScripts.count)")

        
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
                self.domainsWithInjectedScripts.insert(host)
                print("Added domain to injected scripts: \(host)")
                print("Current domains with scripts: \(self.domainsWithInjectedScripts)")
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
            
            // Load dependency
            loadRemoteScript(from: dependency) { result in
                switch result {
                case .success(let content):
                    // Prepend dependency to original script
                    if let existingScript = self.loadedScripts[identifier] {
                        let newCode = content + "\n" + existingScript.code
                        self.loadedScripts[identifier] = (existingScript.metadata, newCode)
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




