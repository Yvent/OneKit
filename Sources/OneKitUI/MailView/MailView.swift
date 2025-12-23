//
//  MailView.swift
//  OneKit
//
//  Created by zyw on 2025/12/23.
//

import SwiftUI
import UIKit
import MessageUI

struct MailView: UIViewControllerRepresentable {

    @Environment(\.presentationMode)
    var presentation
    
    @Binding var result: Result<MFMailComposeResult, Error>?
    
    var subject: String
    var messageBody: String
    var recipients: [String]
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {

        @Binding
           var presentation: PresentationMode
        @Binding var result: Result<MFMailComposeResult, Error>?

        init(presentation: Binding<PresentationMode>,
             result: Binding<Result<MFMailComposeResult, Error>?>) {
            _presentation = presentation
            _result = result
        }

        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            defer {
               $presentation.wrappedValue.dismiss()
             }
            guard error == nil else {
                self.result = .failure(error!)
                return
            }
            self.result = .success(result)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(
             presentation: presentation,
             result: $result
           )
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.setSubject(subject)
        vc.setMessageBody(messageBody, isHTML: false)
        vc.setToRecipients(recipients)
        vc.mailComposeDelegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController,
                                context: UIViewControllerRepresentableContext<MailView>) {

    }
}
