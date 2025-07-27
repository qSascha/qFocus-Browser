//
//  Enumerations.swift
//  qFocus Browser
//
//



//MARK: AppPlatform
enum AppPlatform {
    case iOS, iPadOS, macOS, visionOS
}



//MARK: StartViewState
enum StartViewState {
    case initial
    case loading(AppPlatform)
    case onboarding(AppPlatform)
    case main(AppPlatform)
}



//MARK: SiteOrders
enum SortOrder {
    case ascending
    case descending
}
