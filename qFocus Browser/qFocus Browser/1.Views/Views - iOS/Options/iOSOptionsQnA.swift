//
//  iOSOptionsQnA.swift
//  qFocus Browser
//
//
import SwiftUI
import FactoryKit
import MessageUI



struct QnAs: Identifiable {
    let id: UUID;
    let questionNo: Int;
    let questionText: String
    let answerText: String
    
}



struct iOSOptionsQnA: View {
    @InjectedObject(\.optionsVM) var optionsVM: OptionsVM
    
    @Environment(\.openURL) private var openURL
    
    var iconSize: CGFloat = 32
    @State private var selectedQnA: QnAs? = nil
    @State private var qnas: [QnAs] = [
        
        QnAs(id: UUID(),
             questionNo: 1,
             questionText: String(localized:"Options.qna.question1"),
             answerText: String(localized:"Options.qna.answer1")
            ),
        QnAs(id: UUID(),
             questionNo: 2,
             questionText: String(localized:"Options.qna.question2"),
             answerText: String(localized:"Options.qna.answer2")
            ),
        QnAs(id: UUID(),
             questionNo: 3,
             questionText: String(localized:"Options.qna.question3"),
             answerText: String(localized:"Options.qna.answer3")
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
                        
                    }
                }

            }

        }
        .navigationTitle(String(localized:"qna.header"))
        .sheet(item: $selectedQnA) { qna in
            AnswerView(question: qna.questionText, answerText: qna.answerText)
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $showingMailView) {
            MailView(recipient: "contact@qsascha.dev", subject: String(localized:"Options.qna.feedback.subject"))
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








struct AnswerView: View {
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








struct MailView: UIViewControllerRepresentable {
    @Environment(\.dismiss) var dismiss
    let recipient: String
    let subject: String
    
    class Coordinator: NSObject, @MainActor MFMailComposeViewControllerDelegate {
        var parent: MailView
        init(_ parent: MailView) { self.parent = parent }
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

