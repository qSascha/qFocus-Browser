//
//  iOSOptionsGreasyWiz1.swift
//  qFocus Browser
//
//
import SwiftUI



struct GreasyWizard1: View {
    @EnvironmentObject var nav: NavigationStateManager

    
    
    var body: some View {
        
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

    }

}

/*
 
 Text("This feature allows you to add a Greasy Fork script to your browser. Greasy Fork is a website that allows you to find and download scripts for qFocus Browser.")
 
 Spacer()

 Text("Attention")
     .font(.headline)

 Text("This is an advanced feature. Please read below carefully and if you don't know what any of this means then this feature is not for you.")
 
 Spacer()
 
 Text("Some scripts are very powerful and may cause problems with qFocus Browser. If you are unsure about adding a script then please do not add it.")
 
 Spacer()
 
 Text("Hints & Tips")
     .font(.headline)
 
 Text("1. Disable all other scripts, temporarily, so you can test the beheavior of the added script and see if it works as expected")
 Text("2. Scripts that are not designed for mobile Safari may not work as expected.")
 Text("3. If you encounter any problems with the script then please contact the script author.")
 Text("4. If you add a script that doesn't provide the expected functionality then please ensure to disable or uninstall it, as it may lead to additional unexpected behavior.")
 
 Spacer()
 
 Text("Instructions")
     .font(.headline)

 Text ("Sometimes when when you click on \"Install this Script\" you will be presented with a \"How to install\"-pop-up.\nWhen this happens click on \"(I already have a user script manager. let me install it!)\"")
 
 Spacer()
 
 HStack {
     Spacer()
     
     Button(action: {
         nav.path.append(NavTarget.greasyWiz2)
     }) {
         Text("Confirm")
                 .padding(.vertical, 10)
                 .padding(.horizontal, 20)
                 .foregroundColor(.white)
                 .glassEffect(.regular.tint(.blue))

     }

     Spacer()

 }

}
.padding(20)
}
.navigationTitle("greasy.wizard.header")
 */
 
