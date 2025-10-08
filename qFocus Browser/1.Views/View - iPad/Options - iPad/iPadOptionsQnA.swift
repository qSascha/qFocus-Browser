//
//  iPadOptionsQnA.swift
//  qFocus Browser
//
//
import SwiftUI
import FactoryKit
import MessageUI


/*
struct QnAs: Identifiable {
    let id: UUID;
    let questionNo: Int;
    let questionText: String
    let answerText: String
}
*/


struct iPadOptionsQnA: View {
    @InjectedObject(\.optionsVM) var optionsVM: OptionsVM
    
    @Environment(\.openURL) private var openURL
    
    var iconSize: CGFloat = 32
    @State private var selectedQnA: QnAs? = nil
    @State private var qnas: [QnAs] = [
        
        QnAs(id: UUID(),
             questionNo: 1,
             questionText: String(localized:"Options.qna.5question"),
             answerText: String(localized:"Options.qna.5answer")
            ),
        QnAs(id: UUID(),
             questionNo: 2,
             questionText: String(localized:"Options.qna.1question"),
             answerText: String(localized:"Options.qna.1answer")
            ),
        QnAs(id: UUID(),
             questionNo: 3,
             questionText: String(localized:"Options.qna.2question"),
             answerText: String(localized:"Options.qna.2answer")
            ),
        QnAs(id: UUID(),
             questionNo: 4,
             questionText: String(localized:"Options.qna.3question"),
             answerText: String(localized:"Options.qna.3answer")
            ),
        QnAs(id: UUID(),
             questionNo: 5,
             questionText: String(localized:"Options.qna.4question"),
             answerText: String(localized:"Options.qna.4answer")
            )

        ]
    
    @State private var showingMailView = false
    @State private var showMailAlert = false

    
    var body: some View {
        
        List {

            Section {
                
                ForEach(qnas) { qna in
                    Button(action: {
                        selectedQnA = qna
                    }) {
                        HStack {
                            Image("Number\(qna.questionNo)")
                                .resizable()
                                .frame(width: iconSize, height: iconSize)
                            
                            Text(LocalizedStringKey(qna.questionText))
                                .foregroundColor(.primary)
                        }
                    }
                }

            }
            
            Section {
                
                Button(action: {
                    if MFMailComposeViewController.canSendMail() {
                        showingMailView = true
                    } else {
                        showMailAlert = true
                    }
                }) {
                    HStack {
                        Image("Feedback")
                            .resizable()
                            .frame(width: iconSize, height: iconSize)
                        
                        Text (String(localized:"Options.qna.feedback.header"))
                            .foregroundColor(.primary)

                    }
                }

            }

        }
        .navigationTitle(String(localized:"qna.header"))
        .sheet(item: $selectedQnA) { qna in
            iPadAnswerView(question: qna.questionText, answerText: qna.answerText)
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $showingMailView) {
            iPadMailView(recipient: "contact@qsascha.dev", subject: String(localized:"Options.qna.feedback.subject"))
        }
        .alert(String(localized:"Options.qna.noemailalert"), isPresented: $showMailAlert) {
            Button(String(localized:"general.ok"), role: .cancel) { }
            } message: {
                Text(String(localized:"Options.qna.noemailmessage"))
        }
        .onAppear() {
           Collector.shared.save(event: "Viewed", parameter: "Options-QnA")
        }
            
    }
    
}








struct iPadAnswerView: View {
    @Environment(\.dismiss) private var dismiss
    let question: String
    let answerText: String



    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 6) {


                Text(answerText)
                    .padding()

                Spacer()
            }
            .navigationTitle(question)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear() {
                Collector.shared.save(event: "Viewed", parameter: "Options-QnA-\(question)")
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                    }
                }
            }
        }
    }
}








struct iPadMailView: UIViewControllerRepresentable {
    @Environment(\.dismiss) var dismiss
    let recipient: String
    let subject: String
    
    class Coordinator: NSObject, @MainActor MFMailComposeViewControllerDelegate {
        var parent: iPadMailView
        init(_ parent: iPadMailView) { self.parent = parent }
        @MainActor
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            parent.dismiss()
        }
    }
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.setToRecipients([recipient])
        vc.setSubject(subject)
        vc.mailComposeDelegate = context.coordinator
        return vc
    }
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
}





#Preview {
    iOSOptionsQnA()
}

