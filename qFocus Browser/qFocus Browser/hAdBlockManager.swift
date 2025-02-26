//
//  hAdBlockManager.swift
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



// MARK: Ad Block Manager
@MainActor
class AdBlockManager {
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
            fatalError("AdBlockManager: Could not access documents directory")
        }
    }
    
    private func saveChecksums() {
        let checksumURL = cacheDirectory.appendingPathComponent(checksumFileName)
        try? PropertyListEncoder().encode(checksums).write(to: checksumURL)
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
            print("AdBlockManager: Checksum check for \(identifier): \(hasChanged ? "Changed" : "Not changed")")
            return hasChanged
        }
        
        return true
    }
    



    //MARK: processURL
    public func processURL(_ url: URL, identifier: String) async throws -> (simple: String, advanced: String, compiled: [WKContentRuleList]) {
        let lists = WKContentRuleListStore.default()

        // Download and process content
        let (data, _) = try await URLSession.shared.data(from: url)
        let newChecksum = calculateChecksum(of: data)
        
        print("Getting checksum for \(identifier): \(newChecksum)")
        // Check if we already have this version compiled
        if let existingChecksum = checksums[identifier], existingChecksum == newChecksum {

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
                    return (simple: "", advanced: "", compiled: existingChunks)
                }
            }
        }

        // Remove existing chunks before creating new ones
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            lists?.getAvailableContentRuleListIdentifiers { identifiers in
                if let identifiers = identifiers {
                    for id in identifiers where id.starts(with: identifier) {
                        lists?.removeContentRuleList(forIdentifier: id) { error in
                            if let error = error {
                                print("Error removing old rule list: \(error)")
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
                        print("Error compiling chunk \(index): \(error)")
                        continuation.resume(returning: nil)
                    } else {
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
}

enum BlockListError: Error {
    case invalidData
    case invalidResponse
    case compilationFailed
    case storeUnavailable
}





