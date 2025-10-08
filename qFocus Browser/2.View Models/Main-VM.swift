//
//  Main-VM.swift
//  qFocus Browser
//
//
import Foundation
import WebKit
import Combine
import SwiftUI



@MainActor
final class MainVM: ObservableObject {
    @Published var sitesRepo: SitesRepo
    @Published var sitesDetails: [SitesDetails] = []
    @Published var selectedWebViewID: UUID?
    @Published var externalURL: IdentifiableURL? = nil
    @Published var showPrivacy: Bool = false
    @Published var statusBarBackgroundColor: Color = .black
    @Published var disableEB: Bool = false

    private var cancellables = Set<AnyCancellable>()
    private var topAreaColorTask: Task<Void, Never>? = nil
    


    //MARK: Init
    init(sitesRepo: SitesRepo) {
        self.sitesRepo = sitesRepo

        // Update Web Views - triggered by various option changes
        CombineRepo.shared.updateWebSites
             .sink { [weak self] _ in
                 Task { await self?.loadAllWebViews() }
             } .store(in: &cancellables)

        
        // Update Web Views - triggered by various option changes
        CombineRepo.shared.updateTopAreaColor
             .sink { [weak self] _ in
                 Task { self?.updateTopAreaColor() }
             } .store(in: &cancellables)


        // Select Web Views - triggered by Menu button in NavigationBar and NavigationFlow
        CombineRepo.shared.selectWebView
             .sink { [weak self] index in
                 self?.selectWebView(at: index)
             } .store(in: &cancellables)


        // Set externalURL to open External Browser sheet
        CombineRepo.shared.triggerExternalBrowser
            .sink { [weak self] url in
                self?.externalURL = IdentifiableURL(url: url)
            }
            .store(in: &cancellables)


        // Set showPrivacy = false to dismiss Resuming View
        CombineRepo.shared.dismissResuming
            .sink { [weak self] _ in
                self?.showPrivacy = false
                Task { self?.updateTopAreaColor() }
            }
            .store(in: &cancellables)


        // Subscribe to global external browser disabled state
        CombineRepo.shared.externalBrowserDisabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] disabled in
                self?.disableEB = disabled
                if !disabled {
                    self?.updateTopAreaColor()
                }
            }
            .store(in: &cancellables)

        NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { _ in
            Task { @MainActor in
                CombineRepo.shared.lockApp.send()
            }
        }


        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { notification in
            Task { @MainActor in
                print("------ Showing Privacy -----")
                self.showPrivacy = true
            }
        }
        
        

/*
        NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { _ in
            Task { @MainActor in
                print("----- Unlocking App -----")
 //               self.onResuming()
            }
        }
        
        NotificationCenter.default.addObserver(
//            forName: UIApplication.willEnterForegroundNotification,
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            Task { @MainActor in
                print("----- Hiding Privacy -----")
//                self.onResuming()
            }
        }
*/


    }

    
    
    //MARK: deinit
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    
    
    //MARK: Load All WebViews
    func loadAllWebViews() async {
        // Clear all current WebViews
        self.sitesDetails.removeAll()
        
        // Fetch the latest site configurations
        let sites = sitesRepo.getAllSites()
        var newDetails: [SitesDetails] = []
        
        for site in sites {
            let webViewVM = AppDIContainer.shared.webViewVM()
            await webViewVM.initializeWebView(assignViewID: site.cookieStoreID)

            let details = SitesDetails(id: site.cookieStoreID, viewModel: webViewVM)

            newDetails.append(details)
        }
        
        self.sitesDetails = newDetails
        
        // Select first site by default if available
        if let first = newDetails.first {
            selectedWebViewID = first.id
        }

    }
    
    
    //MARK: Get All Sites
    func getAllSites() -> [SitesStorage] {
        return sitesRepo.getAllSites(order: .descending)
    }
    
    
    //MARK: Select WebView
    func selectWebView(at index: Int) {
        // Switch active WebView by index
        guard index >= 0, index < sitesDetails.count else { return }
        selectedWebViewID = sitesDetails[index].id
    }
    
    
    
    //MARK: Update Top Area Color
    func updateTopAreaColor() {
        // Cancel any previous scheduled updates to avoid overlap
        topAreaColorTask?.cancel()

        // Start a new task that updates immediately, then every 0.5s up to 10 seconds
        topAreaColorTask = Task { @MainActor [weak self] in
            guard let self = self else { return }
            let start = Date()

            while !Task.isCancelled {
                if let topAreaColor = self.getTopAreaColor() {
                    self.statusBarBackgroundColor = topAreaColor
                }

                // Stop if we've reached 10 seconds total duration
                if Date().timeIntervalSince(start) >= 10 { break }

                // Sleep for 0.5 seconds before next update
                try? await Task.sleep(nanoseconds: 500_000_000)
            }
        }
    }
    

    
    //MARK: Get Top Area Color
    func getTopAreaColor() -> Color? {
        // Modern approach: find the key window from the foreground active window scene (iOS 15+)
        guard let windowScene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive }),
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return nil
        }
        let statusBarHeight = window.safeAreaInsets.top
        let captureHeight: CGFloat = 50
        let captureRect = CGRect(x: 0, y: statusBarHeight, width: window.bounds.width, height: captureHeight)

        let renderer = UIGraphicsImageRenderer(bounds: captureRect)

        let image = renderer.image { ctx in
            window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
            // Removed red stroke drawing here; replaced by debug overlay view
        }

        guard let cgImage = image.cgImage else {
            return nil
        }
        let width = cgImage.width
        let height = cgImage.height
        let bitmapData = calloc(width * height * 4, MemoryLayout<UInt8>.size)
        defer { free(bitmapData) }
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let ctx = CGContext(data: bitmapData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        ctx?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        var colorCounts: [UInt32: Int] = [:]
        let pixelBuffer = bitmapData!.assumingMemoryBound(to: UInt8.self)
        for y in 0..<height {
            for x in 0..<width {
                let i = (y * width + x) * 4
                let r = pixelBuffer[i]
                let g = pixelBuffer[i+1]
                let b = pixelBuffer[i+2]
                let a = pixelBuffer[i+3]
                if a < 127 { continue }
                let rgba = UInt32(r) << 24 | UInt32(g) << 16 | UInt32(b) << 8 | UInt32(a)
                colorCounts[rgba, default: 0] += 1
            }
        }
        if let (rgba, _) = colorCounts.max(by: { $0.value < $1.value }) {
            let r = Double((rgba >> 24) & 0xFF) / 255.0
            let g = Double((rgba >> 16) & 0xFF) / 255.0
            let b = Double((rgba >> 8)  & 0xFF) / 255.0
            let a = Double(rgba & 0xFF) / 255.0
            let color = Color(.sRGB, red: r, green: g, blue: b, opacity: a)
            return color
        }
        return nil
    }


}
