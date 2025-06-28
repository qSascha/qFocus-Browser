//
//  GreasyScript-UC.swift
//  qFocus Browser
//
//
import WebKit
import Foundation
import SwiftData



@MainActor
final class GreasyScriptUC: ObservableObject {
    private let greasyRepo: GreasyScriptRepo
    private let settingsRepo: SettingsRepo
    
    var loadedScripts: [String: (metadata: ScriptMetadata, code: String)] = [:]
    private(set) var domainsWithInjectedScripts: Set<String> = []
    
    var greaseForkList: [greasyScriptItem] = createGreasyScriptsList() {
        didSet { objectWillChange.send()}
    }

    
    
    //MARK:Init
    init(greasyRepo: GreasyScriptRepo, settingsRepo: SettingsRepo) {
        self.greasyRepo = greasyRepo
        self.settingsRepo = settingsRepo
    }
    
    
    
    //MARK: Enum Injection Time
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
    
    
    
    //MARK: Struc Sript Meta Data
    struct ScriptMetadata {
        let name: String
        let description: String?
        let version: String?
        let injectionTime: InjectionTime
        let requires: [String]
        
        init(from metadataDict: [String: [String]]) {
            /// Creates script metadata from parsed header information.
            /// Takes a dictionary of metadata fields extracted from script headers and
            /// converts them into a structured format. This initializer handles defaults for
            /// missing fields and converts string-based timing directives into appropriate enum values.
            
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
        /// Parses a userscript string into metadata and executable code components.
        /// Uses regular expressions to extract the metadata block and script content from userscript text.
        /// The metadata is parsed line by line to extract directives like @name, @description, and @require,
        /// returning both the structured metadata and the actual JavaScript code for execution.
        
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
    
    
    
    //MARK: Load Scripts
    func loadScripts(for siteURL: URL) {
        /// Loads all applicable userscripts for a given website URL.
        /// Fetches script settings from the database, matches them against the current site's domain,
        /// and loads each applicable script asynchronously. After loading scripts, it processes their
        /// dependencies. Injection is now handled externally.
        
        let siteName = siteURL.host ?? ""
        
        // Clear previous scripts when loading new ones
        loadedScripts.removeAll()
        
        let scriptSettings = greasyRepo.loadedScripts
        
        // Get the core domain for comparison
        let coreDomain = getDomainCore(siteName)
        
        // Filter scripts where the core domains match and the script is enabled in settings
        let matchingScripts = greaseForkList.filter { script in
            script.coreSite == coreDomain &&
            scriptSettings.contains { $0.scriptID == script.scriptID && $0.scriptEnabled }
        }
        
        if matchingScripts.isEmpty {
            //            print("No matching scripts found for domain: \(coreDomain)")
            return
        }
        
        // Create outer group for script loading
        let loadingGroup = DispatchGroup()
        // Create strong reference to self
        let strongSelf = self
        
        for script in matchingScripts {
            loadingGroup.enter()
            
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
        
        // After all scripts are loaded, handle dependencies
        loadingGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            
            let scriptIdentifiers = Array(self.loadedScripts.keys)
            
            if scriptIdentifiers.isEmpty {
                print("No scripts were successfully loaded")
                return
            }
            
            // Create dependencies group
            let dependenciesGroup = DispatchGroup()
            
            // Load dependencies for each script
            for identifier in scriptIdentifiers {
                dependenciesGroup.enter()
                
                strongSelf.loadDependencies(for: identifier) { success in
                    defer { dependenciesGroup.leave() }
                    
                    if !success {
                        print("ERROR: Failed to load dependencies for \(identifier)")
                    } else {
//                        print("Successfully loaded dependencies for \(identifier)")
                    }
                }
            }
            
        }
    }
    
    
    
    //MARK: Clear Injected Script
    func clearInjectedScripts() {
        /// Clears all injected scripts from the manager's state.
        /// Resets the tracking set that monitors which domains have active scripts.
        /// This function is typically called when the user clears browsing data or when
        /// scripts need to be reloaded due to settings changes.
        
        DispatchQueue.main.async {
            self.domainsWithInjectedScripts.removeAll()
        }
    }
    
    
    
    //MARK: Remove Injected Scripts
    func removeInjectedScripts(forHost host: String) {
        /// Removes injected scripts for a specific host domain.
        /// Takes a hostname and removes it from the tracking set of domains with active scripts.
        /// This is useful when navigating away from a site or when scripts need to be selectively
        /// disabled for certain domains.
        
        DispatchQueue.main.async {
            self.domainsWithInjectedScripts.remove(host)
        }
    }
    
    
    
    //MARK: Get User Scripts
    func getUserScripts(for siteURL: URL) -> [WKUserScript] {
        /// Generates WKUserScript instances for all loaded scripts.
        /// Returns an array of WKUserScript objects to be injected externally by the caller.
        
        guard let host = siteURL.host else {
            print("No host found for webView")
            return []
        }
        
        var userScripts: [WKUserScript] = []
        
        for (_, script) in loadedScripts {
            let userScript = WKUserScript(
                source: script.code,
                injectionTime: script.metadata.injectionTime.webViewTime,
                forMainFrameOnly: true
            )
            userScripts.append(userScript)
        }
        
//        DispatchQueue.main.async {
            if !self.loadedScripts.isEmpty {
                self.domainsWithInjectedScripts.insert(getDomainCore(host))
            } else {
                print("No scripts were loaded for: \(host)")
            }
//        }
        
        return userScripts
    }
    
    
    
    //MARK: Load Dependencies
    func loadDependencies(for identifier: String, completion: @escaping (Bool) -> Void) {
        /// Loads and processes dependencies for a script.
        /// Takes a script identifier, fetches any required dependency scripts listed in its metadata,
        /// and prepends them to the original script's code. This ensures that libraries and
        /// helper functions are available to the main script when it executes.
        
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
    
    
    
    //MARK: Load Remote Scripts
    private func loadRemoteScript(from url: String, completion: @escaping (Result<String, Error>) -> Void) {
        /// Fetches a script from a remote URL.
        /// Creates a network request to download script content from a given URL and returns
        /// the result asynchronously. This private helper method is used for fetching both
        /// main scripts and their dependencies from CDNs or script hosting services.
        
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
            
            completion(.success(content))
        }.resume()
    }
    
}

