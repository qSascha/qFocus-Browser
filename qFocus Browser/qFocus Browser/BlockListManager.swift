import Foundation
import WebKit
import SwiftUI
import ContentBlockerConverter




// MARK: Block List Manager
class BlockListManager {
    private let cacheDirectory: URL
    private let cacheValidityDuration: TimeInterval = 7 * 24 * 60 * 60
    private let lastUpdateFileName = "lastUpdate.plist"
    private var lastUpdateTimes: [String: Date]
//    private let userLogin = "srhein"
//    private let timestamp = "2025-01-04 07:48:20"
    
    init() {
        if let documentsDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            cacheDirectory = documentsDirectory.appendingPathComponent("BlockListCache")
            try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
            
            let lastUpdateURL = cacheDirectory.appendingPathComponent(lastUpdateFileName)
            if let data = try? Data(contentsOf: lastUpdateURL),
               let decoded = try? PropertyListDecoder().decode([String: Date].self, from: data) {
                lastUpdateTimes = decoded
            } else {
                lastUpdateTimes = [:]
            }
        } else {
            fatalError("Could not access documents directory")
        }
    }
    
    private func saveLastUpdateTimes() {
        let lastUpdateURL = cacheDirectory.appendingPathComponent(lastUpdateFileName)
        try? PropertyListEncoder().encode(lastUpdateTimes).write(to: lastUpdateURL)
    }
    
    private func getUniqueFileIdentifier(from url: URL) -> String {
        let components = url.pathComponents
        if let filterComponent = components.first(where: { $0.hasPrefix("filter_") }) {
            return filterComponent
        }
        let parentFolder = components.dropLast().last ?? "unknown"
        let filename = url.lastPathComponent
        return "\(parentFolder)_\(filename)"
    }
    
    private func loadFromCache(for url: URL) throws -> (simple: String, advanced: String)? {
        let identifier = getUniqueFileIdentifier(from: url)
        let simpleRulesCacheURL = cacheDirectory.appendingPathComponent("\(identifier)_simple.json")
        let advancedRulesCacheURL = cacheDirectory.appendingPathComponent("\(identifier)_advanced.json")
        
        // Check if both cache files exist
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: simpleRulesCacheURL.path),
              fileManager.fileExists(atPath: advancedRulesCacheURL.path) else {
            print("Cache files missing for \(identifier)")
            return nil
        }
        
        do {
            let simpleRules = try String(contentsOf: simpleRulesCacheURL, encoding: .utf8)
            let advancedRules = try String(contentsOf: advancedRulesCacheURL, encoding: .utf8)
            return (simple: simpleRules, advanced: advancedRules)
        } catch {
            print("Error reading cache files for \(identifier): \(error.localizedDescription)")
            // Delete corrupted cache files
            try? fileManager.removeItem(at: simpleRulesCacheURL)
            try? fileManager.removeItem(at: advancedRulesCacheURL)
            return nil
        }
    }
    
    private func saveToCache(simpleRules: String, advancedRules: String, for url: URL) throws {
        let identifier = getUniqueFileIdentifier(from: url)
        let simpleRulesCacheURL = cacheDirectory.appendingPathComponent("\(identifier)_simple.json")
        let advancedRulesCacheURL = cacheDirectory.appendingPathComponent("\(identifier)_advanced.json")
        
        try simpleRules.write(to: simpleRulesCacheURL, atomically: true, encoding: .utf8)
        try advancedRules.write(to: advancedRulesCacheURL, atomically: true, encoding: .utf8)
        print("Cached files saved for \(identifier)")
    }
    
    private func shouldUpdateCache(for url: URL) -> Bool {
        let urlKey = url.absoluteString
        let identifier = getUniqueFileIdentifier(from: url)
        
        // Check if files exist
        let simpleRulesCacheURL = cacheDirectory.appendingPathComponent("\(identifier)_simple.json")
        let advancedRulesCacheURL = cacheDirectory.appendingPathComponent("\(identifier)_advanced.json")
        let fileManager = FileManager.default
        let filesExist = fileManager.fileExists(atPath: simpleRulesCacheURL.path) &&
                        fileManager.fileExists(atPath: advancedRulesCacheURL.path)
        
        // Check if cache is valid
        if let lastUpdate = lastUpdateTimes[urlKey] {
            let cacheIsValid = Date().timeIntervalSince(lastUpdate) < cacheValidityDuration
            return !filesExist || !cacheIsValid
        }
        
        return true
    }
    
    public func processURL(_ url: URL) async throws -> (simple: String, advanced: String, compiled: WKContentRuleList?) {
        let urlKey = url.absoluteString
        let identifier = getUniqueFileIdentifier(from: url)
        
        // Check if we should use cache
        if !shouldUpdateCache(for: url),
           let cachedContent = try? loadFromCache(for: url) {
            print("Using cached content for \(identifier)")
            let ruleIdentifier = "Rules_\(identifier)"
            
            if let store = await WKContentRuleListStore.default(),
               let compiledRules = try? await store.compileContentRuleList(
                forIdentifier: ruleIdentifier,
                encodedContentRuleList: cachedContent.simple
               ) {
                return (simple: cachedContent.simple, advanced: cachedContent.advanced, compiled: compiledRules)
            }
        }
        
        // Download and process
        print("Downloading fresh content for \(identifier)")
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let content = String(data: data, encoding: .utf8) else {
            throw BlockListError.invalidData
        }
        
        // Rest of the processing remains the same...
        let rules = content.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { line in
                !line.isEmpty &&
                !line.hasPrefix("!") &&
                !line.hasPrefix("! ") &&
                !line.hasPrefix("[Adblock") &&
                !line.hasPrefix("# ") &&
                !line.hasPrefix("# Checksum") &&
                !line.hasPrefix("! Checksum")
            }
        
        let originalStdout = dup(STDOUT_FILENO)
        let null = fopen("/dev/null", "w")
        dup2(fileno(null), STDOUT_FILENO)
        
        let result = ContentBlockerConverter().convertArray(
            rules: rules,
            safariVersion: SafariVersion(18.1),
            optimize: false,
            advancedBlocking: true,
            advancedBlockingFormat: .json,
            maxJsonSizeBytes: nil,
            progress: nil
        )
        
        fclose(null)
        dup2(originalStdout, STDOUT_FILENO)
        close(originalStdout)
        
        let jsonStringSimple = result.converted
        let jsonStringAdvanced = result.advancedBlocking ?? ""
        
        try saveToCache(simpleRules: jsonStringSimple,
                       advancedRules: jsonStringAdvanced,
                       for: url)
        
        let ruleIdentifier = "Rules_\(identifier)"
        
        var compiledRules: WKContentRuleList? = nil
        if let store = await WKContentRuleListStore.default() {
            compiledRules = try? await store.compileContentRuleList(
                forIdentifier: ruleIdentifier,
                encodedContentRuleList: jsonStringSimple
            )
        }
        
        lastUpdateTimes[urlKey] = Date()
        saveLastUpdateTimes()
        
        return (simple: jsonStringSimple, advanced: jsonStringAdvanced, compiled: compiledRules)
    }
}



enum BlockListError: Error {
    case invalidData
}

