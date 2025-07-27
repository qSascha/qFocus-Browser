//
//  SiteIcon.swift
//  qFocus Browser
//
//
import SwiftUI



struct SiteIconView: View {
    @StateObject private var iconVM: SiteIconVM
    let script: GreasyScriptStorage

    init(script: GreasyScriptStorage, scriptsRepo: GreasyScriptRepo, sitesRepo: SitesRepo) {
        self.script = script
        _iconVM = StateObject(wrappedValue: SiteIconVM(script: script, scriptsRepo: scriptsRepo, sitesRepo: sitesRepo))
    }

    
    var body: some View {
        ZStack(alignment: .topTrailing) {

            Image(uiImage: iconVM.favIcon)
                .resizable()
                .frame(width: 32, height: 32)
                .foregroundColor(.gray)
            
            Circle()
                .fill(iconVM.scriptEnabled ? Color.green : Color.gray)
                .frame(width: 10, height: 10)
                .offset(x: 2, y: -2)

        }
    }
}

