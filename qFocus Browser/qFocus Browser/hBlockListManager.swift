//
//  hBlockListManager.swift
//  qFocus Browser
//
//  Created by Sascha on 2024-12-11.
//

import Foundation
import WebKit
import SwiftUI
import SwiftData
import ContentBlockerConverter
import CryptoKit



// MARK: Block List Manager
@MainActor
class BlockListManager {
    private let cacheDirectory: URL
    private let checksumFileName = "checksums.plist"
    private var checksums: [String: String]
    private let maxRulesPerChunk = 30000
    
    init() {
        if let documentsDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            cacheDirectory = documentsDirectory.appendingPathComponent("BlockListChecksum")
            try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
            
            // Load existing checksums
            let checksumURL = cacheDirectory.appendingPathComponent(checksumFileName)
            if let data = try? Data(contentsOf: checksumURL),
               let stored = try? PropertyListDecoder().decode([String: String].self, from: data) {
                checksums = stored
            } else {
                checksums = [:]
            }
        } else {
            fatalError("BlockListManager: Could not access documents directory")
        }
    }
    
    private func saveChecksums() {
        let checksumURL = cacheDirectory.appendingPathComponent(checksumFileName)
        try? PropertyListEncoder().encode(checksums).write(to: checksumURL)
    }
    
    public func getIdentifierFromURL(_ url: URL) -> String {
        // Get the path components
        let components = url.pathComponents
        
        // Find the last meaningful component (excluding the filename)
        for component in components.reversed() {
            // Skip the filename (last component)
            if component == components.last {
                continue
            }
            // Skip empty or slash components
            if !component.isEmpty && component != "/" {
                return component
            }
        }
        
        // Fallback to the filename if no other component is found
        return url.lastPathComponent
    }
    
    private func calculateChecksum(of data: Data) -> String {
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    private func hasSourceChanged(sourceURL: URL, identifier: String) async throws -> Bool {
        // Get the checksum of the source content
        var request = URLRequest(url: sourceURL)
        request.httpMethod = "GET"
        
        let (data, _) = try await URLSession.shared.data(from: sourceURL)
        let newChecksum = calculateChecksum(of: data)
        
        if let existingChecksum = checksums[identifier] {
            let hasChanged = existingChecksum != newChecksum
            print("BlockListManager: Checksum check for \(identifier): \(hasChanged ? "Changed" : "Not changed")")
            return hasChanged
        }
        
        print("BlockListManager: No existing checksum for \(identifier)")
        return true
    }
    
    //MARK: processURL
    public func processURL(_ url: URL) async throws -> (simple: String, advanced: String, compiled: [WKContentRuleList]) {
        let lists = WKContentRuleListStore.default()
        let identifier = getIdentifierFromURL(url)
        
        print("Processing URL: \(identifier)")

        // Function to remove existing rule lists
        func removeExistingRuleList(forIdentifier: String) async throws {
            return await withCheckedContinuation { continuation in
                lists?.removeContentRuleList(forIdentifier: forIdentifier) { error in
                    if let error = error {
                        print("Error removing existing rule list: \(error)")
                    } else {
                        print("Successfully removed existing rule list: \(forIdentifier)")
                    }
                    continuation.resume()
                }
            }
        }

        // Download and process content
        let (data, _) = try await URLSession.shared.data(from: url)
        let newChecksum = calculateChecksum(of: data)
        
        // Check if we already have this version compiled
        if let existingChecksum = checksums[identifier], existingChecksum == newChecksum {
            print("[2025-01-29 18:35:56] Existing checksum matches for \(identifier)")
            
            // Get existing compiled rules
            let existingRules = await withCheckedContinuation { (continuation: CheckedContinuation<[String], Never>) in
                lists?.getAvailableContentRuleListIdentifiers { identifiers in
                    continuation.resume(returning: identifiers ?? [])
                }
            }
            
            // Find matching chunks for this identifier
            let matchingRules = existingRules.filter { $0.starts(with: identifier) }.sorted()
            
            if !matchingRules.isEmpty {
                var existingChunks: [WKContentRuleList] = []

/*                // Remove existing chunks
                await withCheckedContinuation { continuation in
                    lists?.getAvailableContentRuleListIdentifiers { identifiers in
                        if let identifiers = identifiers {
                            for id in identifiers where id.starts(with: identifier) {
                                Task {
                                    try await removeExistingRuleList(forIdentifier: id)
                                }
                            }
                        }
                        continuation.resume()
                    }
                }
*/
                for ruleId in matchingRules {
                    if let compiledRule = await withCheckedContinuation({ (continuation: CheckedContinuation<WKContentRuleList?, Never>) in
                        lists?.lookUpContentRuleList(forIdentifier: ruleId) { rules, error in
                            continuation.resume(returning: rules)
                        }
                    }) {
                        existingChunks.append(compiledRule)
                    }
                }
                
                if !existingChunks.isEmpty {
                    print("[2025-01-29 18:35:56] Found \(existingChunks.count) existing chunks for \(identifier)")
                    print("[2025-01-29 18:35:56] Reusing existing compiled rules")
                    return (simple: "", advanced: "", compiled: existingChunks)
                } else {
                    print("[2025-01-29 18:35:56] No existing chunks found for \(identifier)")
                    print("[2025-01-29 18:35:56] Completely re-compiling rules")
                    
                }
            } else {
                print("[2025-01-29 18:35:56] No existing rules found for \(identifier)")

            }
        }
        
        print("[2025-01-29 18:35:56] New or modified content detected for \(identifier)")
        print("[2025-01-29 18:35:56] Previous checksum: \(checksums[identifier] ?? "none")")
        print("[2025-01-29 18:35:56] New checksum:      \(newChecksum)")

        // Remove existing chunks before creating new ones
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            lists?.getAvailableContentRuleListIdentifiers { identifiers in
                if let identifiers = identifiers {
                    for id in identifiers where id.starts(with: identifier) {
                        lists?.removeContentRuleList(forIdentifier: id) { error in
                            if let error = error {
                                print("[2025-01-29 18:35:56] Error removing old rule list: \(error)")
                            }
                        }
                    }
                }
                continuation.resume()
            }
        }

        guard let content = String(data: data, encoding: .utf8) else {
            throw BlockListError.invalidData
        }

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

        print("Filtered \(rules.count) rules")

        // the ContentBlockerConverter function creates massive output we dont want.
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

        // Parse JSON string into array of dictionaries
        guard let jsonData = jsonStringSimple.data(using: .utf8),
              let simpleRules = try? JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]] else {
            throw BlockListError.invalidData
        }

        // Split rules into chunks
        let chunks = stride(from: 0, to: simpleRules.count, by: maxRulesPerChunk).map {
            Array(simpleRules[$0..<min($0 + maxRulesPerChunk, simpleRules.count)])
        }

        var compiledChunks: [WKContentRuleList] = []

        // Compile each chunk
        for (index, chunk) in chunks.enumerated() {
            let chunkIdentifier = "\(identifier)_chunk\(index)"
            let chunkJSON = try JSONSerialization.data(withJSONObject: chunk)
            let chunkJSONString = String(data: chunkJSON, encoding: .utf8) ?? "[]"

            guard let store = WKContentRuleListStore.default() else {
                throw BlockListError.storeUnavailable
            }

            let compiledChunk = await withCheckedContinuation { (continuation: CheckedContinuation<WKContentRuleList?, Never>) in
                store.compileContentRuleList(
                    forIdentifier: chunkIdentifier,
                    encodedContentRuleList: chunkJSONString
                ) { rules, error in
                    if let error = error {
                        print("------------------------- Error compiling chunk \(index): \(error)")
                        continuation.resume(returning: nil)
                    } else {
                        print("Successfully compiled chunk \(index + 1)/\(chunks.count)")
                        continuation.resume(returning: rules)
                    }
                }
            }

            if let compiledChunk = compiledChunk {
                compiledChunks.append(compiledChunk)
            }
        }

        // Save new checksum only after successful compilation
        checksums[identifier] = newChecksum
        saveChecksums()

        return (simple: jsonStringSimple, advanced: jsonStringAdvanced, compiled: compiledChunks)
    }

    
    /*
    public func processURL(_ url: URL) async throws -> (simple: String, advanced: String, compiled: WKContentRuleList?) {
        let lists = WKContentRuleListStore.default()
        
        // Extract identifier from the URL
        let identifier = getIdentifierFromURL(url)
        
        // Function to remove existing rule list
        func removeExistingRuleList() async throws {
            return await withCheckedContinuation { continuation in
                lists?.removeContentRuleList(forIdentifier: identifier) { error in
                    if let error = error {
                        print("ERROR: Could not remove existing rule list: \(error)")
                    } else {
                        print("Successfully removed existing rule list: \(identifier)")
                    }
                    continuation.resume()
                }
            }
        }
        
        // First, check and remove if exists
        await withCheckedContinuation { continuation in
            lists?.getAvailableContentRuleListIdentifiers { identifiers in
                if let identifiers = identifiers, identifiers.contains(identifier) {
                    Task {
                        try await removeExistingRuleList()
                    }
                }
                continuation.resume()
            }
        }
        
        let ruleIdentifier = "Rules_\(identifier)"
        
        print("BlockListManager: Processing identifier: \(identifier)")
        
        // Check if we need to update from source
        let needsUpdate = try await hasSourceChanged(sourceURL: url, identifier: identifier)
        
        if !needsUpdate {
            guard let store = WKContentRuleListStore.default() else {
                throw BlockListError.storeUnavailable
            }
            
            // Check if we have compiled rules
            let existingRules = await withCheckedContinuation { continuation in
                store.lookUpContentRuleList(forIdentifier: ruleIdentifier) { rules, error in
                    continuation.resume(returning: rules)
                }
            }
            
            if let existingRules = existingRules {
                print("BlockListManager: Using existing compiled rules for \(ruleIdentifier)")
                
                return (simple: "", advanced: "", compiled: existingRules)
            }
        }
        
        // Download content
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // Update checksum
        checksums[identifier] = calculateChecksum(of: data)
        saveChecksums()
        
        guard let content = String(data: data, encoding: .utf8) else {
            throw BlockListError.invalidData
        }
        
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
        
        // the ContentBlockerConverter function creates massive output we dont want.
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
        
        // Compile and store rules
        guard let store = WKContentRuleListStore.default() else {
            throw BlockListError.storeUnavailable
        }
        
        let ruleList = try await WKContentRuleListStore.default().contentRuleList(forIdentifier: identifier)
        print(ruleList!.description)
        
        // Remove old rules if they exist
        await withCheckedContinuation { continuation in
            store.removeContentRuleList(forIdentifier: ruleIdentifier) { error in
                continuation.resume()
            }
        }
        
        // Compile new rules
        let compiledRules = await withCheckedContinuation { (continuation: CheckedContinuation<WKContentRuleList?, Never>) in
            guard let store = WKContentRuleListStore.default() else {
                print("Error: Could not access content rule store")
                continuation.resume(returning: nil)
                return
            }
            
            store.compileContentRuleList(forIdentifier: ruleIdentifier, encodedContentRuleList: jsonStringSimple) { rules, error in
                if let error = error {
                    print("ERROR: Compilation error: \(error.localizedDescription)")
                }
                
                continuation.resume(returning: rules)
            }
        }
        
        
        if let compiledRules = compiledRules {
            print("Done with: \(identifier) ")
            
        } else {
            print("Error:  No compiled rules available")
            throw BlockListError.compilationFailed
        }
        
        return (simple: jsonStringSimple, advanced: jsonStringAdvanced, compiled: compiledRules)
    }
    */
}

enum BlockListError: Error {
    case invalidData
    case invalidResponse
    case compilationFailed
    case storeUnavailable
}





