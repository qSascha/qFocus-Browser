//
//  AdBlockFilter-UC.swift
//  qFocus Browser
//
//
import Foundation
import WebKit
import ContentBlockerConverter
import CryptoKit
import FactoryKit





@MainActor
final class AdBlockFilterUC: ObservableObject {
    private let adBlockRepo: AdBlockFilterRepo
    private let settingsRepo: SettingsRepo

    private let allFilterItems: [AdBlockFilterItem] = AllAdBlockFilterListItems().getAllFilters()
    private var errorMessage: String
    
    @Published var updatingFilters: Bool = false
    @Published var totalCounter: Int = 0
    @Published var updateCounter: Int = 0
    @Published var triggeredManually: Bool = false

    
    
    //MARK: init
    init(adBlockRepo: AdBlockFilterRepo, settingsRepo: SettingsRepo) {
        self.adBlockRepo = adBlockRepo
        self.settingsRepo = settingsRepo

        self.errorMessage = ""
    }
    


    //MARK: Update Lists
    /// Processes all enabled AdBlockLists
    func compileAdBlockLists(manually: Bool) {

        let frequency = settingsRepo.get().adBlockUpdateFrequency
        let lastUpdate = settingsRepo.get().adBlockLastUpdate ?? Date.distantPast
        let now = Date()
        var shouldUpdate = false
        switch frequency {
        case 1:
            shouldUpdate = true
        case 2:
            let isSameDay = Calendar.current.isDate(now, inSameDayAs: lastUpdate)
            shouldUpdate = !isSameDay
        case 3:
            shouldUpdate = now > Calendar.current.date(byAdding: .day, value: 6, to: lastUpdate)!
        case 4:
            shouldUpdate = now > Calendar.current.date(byAdding: .day, value: 29, to: lastUpdate)!
        default:
            shouldUpdate = false
        }
        if !manually && !shouldUpdate {
            return
        }
        print("------------ Updating ...")

        triggeredManually = manually
        updatingFilters = true

        Task { @MainActor in
            let enabledSettings = adBlockRepo.getAllEnabled()
            let enabledIDs = Set(enabledSettings.map { $0.filterID })
            let filtersToCompile = allFilterItems.filter { enabledIDs.contains($0.filterID) }

            // These lines are a solution to a data race.
            // If not in place the AdBlockLoadStatus will
            // show 0/0 until first compile is complete.
            updateCounter = filtersToCompile.count
            totalCounter = updateCounter
            updateCounter = 0
            
            #if DEBUG
            print("Lists to update: \(filtersToCompile.count)")
            #endif

/*            // Compile all parallel
            let tasks = filtersToCompile.map { filter in
                Task.detached(priority: .background) { [self] in
                    await self.compileFilter(filter)
                }
            }
            for task in tasks {
                await task.value
            }
*/

            // Compile Sequential
             for filter in filtersToCompile {
                 await Task.detached(priority: .background) {
                     await self.compileFilter(filter)
                 }.value
             }
             
            
            
            settingsRepo.update() { settings in
                settings.adBlockLastUpdate = Date()
            }

            updatingFilters = false

            // If triggered manuall, through Update button in AdBlock settings then update all webviews.
            if manually {
                CombineRepo.shared.updateWebSites.send()
            }
        }
    }
    
    

    //MARK: Compile Fiter
    /// Processes the given filter with the following steps
    /// - Download the JSON file stored in AdBlockFilterItem.urlString
    /// - Compare its checksum against the locally stored checksum
    /// - If checksums don't match compile and store it in the WKContentRuleListStore, using the value of AdBlockFilterItem.filterID as an identifier
    /// - Update the local checksum, if necessary
    private func compileFilter(_ filter: AdBlockFilterItem) async {
        
        do {
            guard let tempList = try await downloadJSON(filter.urlString) else {
                throw CompilerError.badURL
            }
            
            // Return if checksum is the same
            guard let existingSetting = adBlockRepo.getSetting(for: filter.filterID) else {
                throw CompilerError.badServerResponse
            }
            let newChecksum = calculateChecksum(of: tempList)
            #if DEBUG
            print("CHECKSUM-Existing: \(existingSetting.checksum)")
            print("CHECKSUM-NewOne:   \(newChecksum)")
            #endif
            guard existingSetting.checksum != newChecksum else {
                // No changes needed
                await MainActor.run {
                    self.updateCounter += 1
                }
#if DEBUG
                        print("Is up to date: \(filter.filterID)")
#endif
                return
            }

            // Remove already existing ad-blocking list from WKContentRuleList
            do {
                try await WKContentRuleListStore.default().removeContentRuleList(forIdentifier: filter.filterID)
            } catch {
                #if DEBUGG
                print("No legbacy rule found: \(filter.filterID)")
                #endif
            }

            // Convert to UTF8
            #if DEBUGG
            print("Compiling: \(filter.filterID)")
            #endif
            guard var content = String(data: tempList, encoding: .utf8) else {
                throw CompilerError.invalidData
            }
            content.makeContiguousUTF8()
            
            // Convert from AdBlock format to JSON, so that WKContentRule can process it
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

            // Redirect stdout to /dev/null to suppress ContentBlockerConverter output
            let originalStdout = dup(STDOUT_FILENO)
            let null = fopen("/dev/null", "w")
            dup2(fileno(null), STDOUT_FILENO)
            
            // Run package dependency code from
            // https://github.com/AdguardTeam/SafariConverterLib/tree/master
            let result = ContentBlockerConverter().convertArray(
                rules: rules,
                safariVersion: SafariVersion.autodetect(),
                advancedBlocking: true,
                maxJsonSizeBytes: nil,
                progress: nil
            )
            
            // Restore stdout
            fclose(null)
            dup2(originalStdout, STDOUT_FILENO)
            close(originalStdout)

            let jsonStringSimple = result.safariRulesJSON

            // Compile the entire rule list at once
            guard let store = WKContentRuleListStore.default() else {
                throw CompilerError.storeUnavailable
            }

            let compiledList = await withCheckedContinuation { (continuation: CheckedContinuation<WKContentRuleList?, Never>) in
                store.compileContentRuleList(
                    forIdentifier: filter.filterID,
                    encodedContentRuleList: jsonStringSimple
                ) { rules, error in
                    if let error = error {
                        print("Error compiling rule list for \(filter.filterID): \(error)")
                        continuation.resume(returning: nil)
                    } else {
                        continuation.resume(returning: rules)
                    }
                }
            }

            if compiledList == nil {
                throw CompilerError.compilationFailed
            }

            
            // Save new checksum
            // We do this at the end, once we know that everything was processed as expected
            adBlockRepo.addOrUpdateSetting(for: filter.filterID, enabled: existingSetting.enabled, checksum: newChecksum)
            #if DEBUGG
            print("Checksum updated: \(filter.filterID)")
            #endif

            // update counter on AdBlockLoadStatus
            await MainActor.run {
                self.updateCounter += 1
            }
        } catch let error as CompilerError {
            // Error compiling Filter
            switch error {
                case .badURL:
                    self.errorMessage = "Bad URL."
            case .badServerResponse:
                self.errorMessage = "Bad server response."
            case .issueRemoveList:
                self.errorMessage = "Issue removing old rule from WKContentRuleListStore."
            case .invalidData:
                self.errorMessage = "No valid JSON String."
            case .invalidResponse:
                self.errorMessage = ""
            case .compilationFailed:
                self.errorMessage = ""
            case .storeUnavailable:
                self.errorMessage = ""


            }
            print("Error processing \(filter.filterID): \(self.errorMessage)")
        } catch {
            self.errorMessage = "Unexpected error: \(error.localizedDescription)"
            print("Unhandled error processing \(filter.filterID): \(self.errorMessage)")
        }
    }

    
    
    //MARK: Download JSON
    private func downloadJSON(_ urlString: String) async throws -> Data? {
        
        let url = URL(string: urlString)
        
        let (data, response) = try await URLSession.shared.data(from: url!)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw CompilerError.badServerResponse
        }
        #if DEBUG
        print("JSON downloaded successfully - \(urlString): Size: \(data.count / 1024) KB")
        #endif

        return(data)
        
    }
    
    

    //MARK: Calculate Checksum
    private func calculateChecksum(of data: Data) -> String {
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    
    
    
    
    
    
    
    private enum CompilerError: Error {
        case badURL
        case badServerResponse
        case issueRemoveList
        case invalidData
        case invalidResponse
        case compilationFailed
        case storeUnavailable
    }
    
    
    
}

