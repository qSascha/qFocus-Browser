//
//  iOSOptionsGreasy.swift
//  qFocus Browser
//
//
import FactoryKit
import SwiftUI



//MARK: GreasyMonkey Settings View
struct iOSGreasySettings: View {
    @InjectedObject(\.greasySettingsVM) private var greasySettings
    @InjectedObject(\.greasyRepo) private var greasyRepo
    @InjectedObject(\.sitesRepo) private var sitesRepo

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var nav: NavigationStateManager



    
    
    var body: some View {
        List {
            Section {
                Toggle("options.settings.toggleGreasyMonkey", isOn: $greasySettings.toggleGreasy)
            }
            header: {
                Text("optionsEdit.settings.greasy.toggle.header")
            }
            footer: {
                Text("optionsEdit.settings.greasy.toggle.footer")
            }
            
            if !greasySettings.toggleGreasy {
                Text("optionsEdit.settings.greasy.disabled")
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
                            VStack(alignment: .leading) {
                                Text(script.scriptName)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                HStack {
                                    if script.scriptEnabled {
                                        Circle()
                                            .frame(width: 8, height: 8)
                                            .foregroundColor(.green)
                                        Text(script.coreSite)
                                            .font(.caption)
                                        
                                    } else {
                                        Circle()
                                            .frame(width: 8, height: 8)
                                            .foregroundColor(.red)
                                        Text("disabled")
                                            .font(.caption)
                                    }
                                }
                                
                            }
                        }
                    }
                    
                    Button("Add Custom Script") {
                        nav.path.append(NavTarget.greasyWiz1)
                    }
                    
                }
                header: {
                    Text("optionsEdit.settings.greasy.custom.header")
                }
                footer: {
                    Text("optionsEdit.settings.greasy.custom.footer")
                }
                
                // Default builtin scripts
                Section {
                    
                    ForEach(greasySettings.builtinScripts.map { $0 }, id: \.id) { script in
                        NavigationLink(destination: iOSOptionsGreasyEdit(scriptObject: script, greasyRepo: greasyRepo, sitesRepo: sitesRepo)) {
                            VStack(alignment: .leading) {
                                Text(script.scriptName)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                HStack {
                                    if script.scriptEnabled {
                                        Circle()
                                            .frame(width: 8, height: 8)
                                            .foregroundColor(.green)
                                        Text(script.coreSite)
                                            .font(.caption)
                                        
                                    } else {
                                        Circle()
                                            .frame(width: 8, height: 8)
                                            .foregroundColor(.red)
                                        Text("disabled")
                                            .font(.caption)
                                    }
                                }
                                
                            }
                        }
                    }
                }
                header: {
                    Text("optionsEdit.settings.greasy.default.header")
                }
                footer: {
                    Text("optionsEdit.settings.greasy.default.footer")
                }

            }
            
        }
        .navigationTitle("greasy.header")
        
    }
    

    
    
}

