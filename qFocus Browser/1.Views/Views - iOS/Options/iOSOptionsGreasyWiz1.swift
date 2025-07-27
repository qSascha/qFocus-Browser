//
//  iOSOptionsGreasyWiz1.swift
//  qFocus Browser
//
//
import SwiftUI



struct GreasyWizard1: View {
    @EnvironmentObject var nav: NavigationStateManager
    
    
    
    var body: some View {
        
        if #available(iOS 26.0, *) {
            
            ScrollView {
                
                VStack(alignment: .leading, spacing: 16) {
                    
                    
                    Text("greasy.wiz.intro")
                    
                    Spacer()
                    
                    Text("greasy.wiz.attention.header")
                        .font(.headline)
                    
                    Text("greasy.wiz.attention.text1")
                    
                    Spacer()
                    
                    Text("greasy.wiz.attention.text2")
                    
                    Spacer()
                    
                    Text("greasy.wiz.hints.header")
                        .font(.headline)
                    
                    Text("greasy.wiz.hints.1")
                    Text("greasy.wiz.hints.2")
                    Text("greasy.wiz.hints.3")
                    Text("greasy.wiz.hints.4")
                    
                    Spacer()
                    
                    Text("greasy.wiz.instructions.header")
                        .font(.headline)
                    
                    Text ("greasy.wiz.instructions.text")
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            nav.path.append(NavTarget.greasyWiz2)
                        }) {
                            Text("greasy.wiz.confirmbutton")
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .foregroundColor(.white)
                                .cornerRadius(20)
                                .glassEffect(.regular.tint(.blue))
                            
                        }
                        
                        Spacer()
                        
                    }
                    
                }
                .padding(20)
            }
            .navigationTitle("greasy.wiz.header")
            .onAppear() {
                Collector.shared.save(event: "Viewed", parameter: "Options-GreasyMonkey-Wizard1")
            }
        } else {
            
            //Legacy Versions
            ScrollView {
                
                VStack(alignment: .leading, spacing: 16) {
                    
                    
                    Text("greasy.wiz.intro")
                    
                    Spacer()
                    
                    Text("greasy.wiz.attention.header")
                        .font(.headline)
                    
                    Text("greasy.wiz.attention.text1")
                    
                    Spacer()
                    
                    Text("greasy.wiz.attention.text2")
                    
                    Spacer()
                    
                    Text("greasy.wiz.hints.header")
                        .font(.headline)
                    
                    Text("greasy.wiz.hints.1")
                    Text("greasy.wiz.hints.2")
                    Text("greasy.wiz.hints.3")
                    Text("greasy.wiz.hints.4")
                    
                    Spacer()
                    
                    Text("greasy.wiz.instructions.header")
                        .font(.headline)
                    
                    Text ("greasy.wiz.instructions.text")
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            nav.path.append(NavTarget.greasyWiz2)
                        }) {
                            Text("greasy.wiz.confirmbutton")
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .foregroundColor(.white)
                                .background(Color.blue)
                                .cornerRadius(20)
                        }
                        
                        Spacer()
                        
                    }
                    
                }
                .padding(20)
            }
            .navigationTitle("greasy.wiz.header")
            .onAppear() {
                Collector.shared.save(event: "Viewed", parameter: "Options-GreasyMonkey-Wizard1")
            }


        }
    }
    
    
}

