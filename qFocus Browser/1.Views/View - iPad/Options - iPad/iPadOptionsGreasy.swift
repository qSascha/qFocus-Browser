//
//  iPadOptionsGreasy.swift
//  qFocus Browser
//
//
import FactoryKit
import SwiftUI



//MARK: GreasyMonkey Settings View
struct iPadGreasySettings: View {
    @InjectedObject(\.greasySettingsVM) private var greasySettings
    @InjectedObject(\.greasyRepo) private var greasyRepo
    @InjectedObject(\.sitesRepo) private var sitesRepo

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var nav: NavigationStateManager



    
    
    var body: some View {
        List {
            Section {
                Toggle("options.greasy.toggleGreasyMonkey", isOn: $greasySettings.toggleGreasy)
            }
//            header: {
//                Text("optionsEdit.greasy.toggle.header")
//            }
//            footer: {
//                Text("optionsEdit.greasy.toggle.footer")
//            }
            
            if !greasySettings.toggleGreasy {
                Text("optionsEdit.greasy.disabled")
                    .foregroundColor(.gray)
                    .italic()

            } else {
                
                //Custom scripts added by user
                Section {
                    ForEach(greasySettings.customScripts.map { $0 }, id: \.objectID) { script in
                        NavigationLink(destination: iOSOptionsGreasyEdit(
                            scriptObject: script,
                            greasyRepo: greasyRepo,
                            sitesRepo: sitesRepo
                        )) {

                            HStack {
                
                                    if script.scriptEnabled {

                                        if let faviconData = greasySettings.getSiteIcon(site: script.coreSite ),
                                           let favicon = UIImage(data: faviconData) {
                                            
                                            ZStack(alignment: .topTrailing) {
                                                
                                                Image(uiImage: favicon)
                                                    .resizable()
                                                    .frame(width: 32, height: 32)
                                                    .clipShape(RoundedRectangle(cornerRadius: 32/2))
                                                
                                                Circle()
                                                    .fill(Color.green)
                                                    .frame(width: 10, height: 10)
                                                    .offset(x: 2, y: -2)
                                            }

                                        } else {
                                            // Fallback icon if favicon is missing
                                            Image(systemName: "globe")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 32, height: 32)
                                                .foregroundColor(.gray)
                                        }
                                        
                                    } else {
                                        ZStack(alignment: .topTrailing) {
                                            
                                            Image(systemName: "globe")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 32, height: 32)
                                                .foregroundColor(.gray)
                                            
                                            Circle()
                                                .fill(Color.red)
                                                .frame(width: 14, height: 14)
                                                .offset(x: 2, y: -2)
                                        }
                                    }

                                Text(script.scriptName)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                
                            }
                        }
                    }
                    
                    Button("optionsEdit.greasy.addcustombutton") {
                        nav.path.append(NavTarget.greasyWiz1)
                    }
                    
                }
                header: {
                    Text("optionsEdit.greasy.custom.header")
                }
                footer: {
                    Text("optionsEdit.greasy.custom.footer")
                }
                
                // Default builtin scripts
                Section {
                    
                    ForEach(greasySettings.builtinScripts.map { $0 }, id: \.id) { script in
                        NavigationLink(destination: iOSOptionsGreasyEdit(scriptObject: script, greasyRepo: greasyRepo, sitesRepo: sitesRepo)) {

                            HStack {
                                
                                SiteIconView(script: script, scriptsRepo: greasyRepo, sitesRepo: sitesRepo)

                                Text(script.scriptName)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                
                            }
                            
                        }
                    }
                }
                header: {
                    Text("optionsEdit.greasy.default.header")
                }
//                footer: {
//                    Text("optionsEdit.greasy.default.footer")
//                }

            }
            
        }
        .navigationTitle("optionsEdit.greasy.header")
        .onAppear() {
            Collector.shared.save(event: "Viewed", parameter: "Options-GreasyMonkey")
        }

    }
    

    
    
}

