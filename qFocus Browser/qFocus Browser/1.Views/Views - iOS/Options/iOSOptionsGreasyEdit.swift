//
//  iOSOptionsGreasyEdit.swift
//  qFocus Browser
//
//
import FactoryKit
import SwiftUI



public struct iOSOptionsGreasyEdit: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var nav: NavigationStateManager
    @StateObject private var greasyEdit: OptionsGreasyEditVM
    @StateObject private var greasyRepo: GreasyScriptRepo
    @StateObject private var sitesRepo: SitesRepo
    
    
    

    //MARK: Init
    init(scriptObject: GreasyScriptStorage?, greasyRepo: GreasyScriptRepo, sitesRepo: SitesRepo, newScript: defaultGreasyScriptItem? = nil) {

        _greasyEdit = StateObject(wrappedValue: OptionsGreasyEditVM(scriptObject: scriptObject, greasyRepo: greasyRepo, sitesRepo: sitesRepo, newScript: newScript))
        _greasyRepo = StateObject(wrappedValue: greasyRepo)
        _sitesRepo = StateObject(wrappedValue: sitesRepo)
    }
 


    //MARK: Body
    public var body: some View {
        
        Form {
            
            Section {
                                
                HStack {
                    Text("Name:")
                        .frame(width: 50, alignment: .leading)
                    if greasyEdit.defaultScript {
                        Text(greasyEdit.scriptName)
                    } else {
                        TextField("", text: $greasyEdit.scriptName)
                            .onChange(of: greasyEdit.scriptName) { _, newValue in
                                if newValue.count > 40 {
                                    greasyEdit.scriptName = String(newValue.prefix(40))
                                }
                            }
                    }
                }
                
                if greasyEdit.defaultScript {
                    HStack {
                        Text("Connect Site")
                        Spacer()
                        Text(greasyEdit.coreSite)
                    }
                    
                } else {

                    Picker("Connect Site", selection: $greasyEdit.coreSite) {
                        
                        Text("none/disabled").tag("###disabled###")
                        
                        ForEach(greasyEdit.sites, id: \.cookieStoreID) { site in
                            Text(site.siteName).tag(site.siteURL.replacingOccurrences(of: "https://", with: ""))
                        }
                    }
                }
                
                
            Text("\(Image(systemName: "link.circle")) \(greasyEdit.siteURL)")
                    .onTapGesture {
                        greasyEdit.linkToShow = IdentifiableURL(url: URL(string:greasyEdit.siteURL)!)
                    }

            }
            header: {
                Text("greasyedit.sect-picker.header")
            }
            footer: {
                Text("greasyedit.sect-picker.footer")
            }
            
            
            Section {
                VStack(alignment: .leading) {
                    if greasyEdit.defaultScript {
                        Text(greasyEdit.scriptExplanation)
                            .frame(minHeight: 80, maxHeight: 350)

                    } else {
                        
                        TextEditor(text: $greasyEdit.scriptExplanation)
                            .frame(minHeight: 80, maxHeight: 350)
                            .onChange(of: greasyEdit.scriptExplanation) { _, newValue in
                                if newValue.count > 400 {
                                    greasyEdit.scriptExplanation = String(newValue.prefix(400))
                                }
                            }
                    }
                }
            }
            header: {
                Text("greasyedit.sect-info.header")
            }
            footer: {
                if !greasyEdit.defaultScript {
                    Text("\(greasyEdit.scriptExplanation.count)/400")
                }
            }

        }
        .onDisappear() {
            print("Saving Data ----->")
            if !greasyEdit.defaultScript {
                greasyEdit.saveData()

            }
            
            // ### = Came here through wizard
            if greasyEdit.scriptLicense == "###" {
                nav.path.removeLast(2)
            }

        }
        .navigationTitle("greasyedit.header")
        .toolbar {
            if greasyEdit.defaultScript != true  && greasyEdit.scriptLicense != "###" {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(role: .destructive) {
                        greasyEdit.scriptName = ""
                        dismiss()
                    } label: {
                        Text("Delete")
                    }
                }
            }
        }
        .sheet(item: $greasyEdit.linkToShow, onDismiss: {
            greasyEdit.linkToShow = nil
        }) { identifiable in
            ExternalBrowserView(viewModel: ExternalBrowserVM(url: identifiable.url))
        }
        
    }
    
}

