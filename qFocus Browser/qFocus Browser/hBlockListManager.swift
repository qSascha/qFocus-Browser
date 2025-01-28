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
    private var checksums: [String: String] // [identifier: checksum]
    
    init() {
        if let documentsDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            cacheDirectory = documentsDirectory.appendingPathComponent("BlockListCache")
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
            fatalError("Could not access documents directory")
        }
    }
    
    private func saveChecksums() {
        let checksumURL = cacheDirectory.appendingPathComponent(checksumFileName)
        try? PropertyListEncoder().encode(checksums).write(to: checksumURL)
    }
    
    private func getIdentifierFromURL(_ url: URL) -> String {
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
        request.httpMethod = "GET" // We need the full content for checksum
        
        let (data, _) = try await URLSession.shared.data(from: sourceURL)
        let newChecksum = calculateChecksum(of: data)
        
        if let existingChecksum = checksums[identifier] {
            let hasChanged = existingChecksum != newChecksum
            print("[2025-01-27 21:11:19] BlockListManager: Checksum check for \(sourceURL.lastPathComponent): \(hasChanged ? "Changed" : "Not changed")")
            print("[2025-01-27 21:11:19] User: qSascha")
            return hasChanged
        }
        
        print("[2025-01-27 21:11:19] BlockListManager: No existing checksum for \(sourceURL.lastPathComponent)")
        print("[2025-01-27 21:11:19] User: qSascha")
        return true
    }
    
    public func processURL(_ url: URL) async throws -> (simple: String, advanced: String, compiled: WKContentRuleList?) {
        let identifier = getIdentifierFromURL(url)
        let ruleIdentifier = "Rules_\(identifier)"
        
        print("[2025-01-27 21:11:19] BlockListManager: Processing URL: \(url.absoluteString)")
        print("[2025-01-27 21:11:19] BlockListManager: Using identifier: \(identifier)")
        
        // Check if we need to update from source
        let needsUpdate = try await hasSourceChanged(sourceURL: url, identifier: identifier)
        
        if !needsUpdate {
            guard let store = await WKContentRuleListStore.default() else {
                throw BlockListError.storeUnavailable
            }
            
            // Check if we have compiled rules
            let existingRules = await withCheckedContinuation { continuation in
                store.lookUpContentRuleList(forIdentifier: ruleIdentifier) { rules, error in
                    continuation.resume(returning: rules)
                }
            }
            
            if let existingRules = existingRules {
                print("[2025-01-27 21:11:19] BlockListManager: Using existing compiled rules for \(ruleIdentifier)")
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
        guard let store = await WKContentRuleListStore.default() else {
            throw BlockListError.storeUnavailable
        }
        
        // Remove old rules if they exist
        await withCheckedContinuation { continuation in
            store.removeContentRuleList(forIdentifier: ruleIdentifier) { error in
                continuation.resume()
            }
        }
        
        // Compile new rules
        let compiledRules = await withCheckedContinuation { continuation in
            store.compileContentRuleList(forIdentifier: ruleIdentifier, encodedContentRuleList: jsonStringSimple) { rules, error in
                if let error = error {
                    print("[2025-01-27 21:11:19] BlockListManager: Error compiling rules: \(error.localizedDescription)")
                } else if rules != nil {
                    print("[2025-01-27 21:11:19] BlockListManager: Successfully compiled rules for \(ruleIdentifier)")
                }
                continuation.resume(returning: rules)
            }
        }
        
        guard let compiledRules = compiledRules else {
            throw BlockListError.compilationFailed
        }
        
        return (simple: jsonStringSimple, advanced: jsonStringAdvanced, compiled: compiledRules)
    }
}

enum BlockListError: Error {
    case invalidData
    case invalidResponse
    case compilationFailed
    case storeUnavailable
}





