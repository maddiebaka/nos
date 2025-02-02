//
//  ReportABugMailView.swift
//  Nos
//
//  Created by Jason Cheatham on 3/8/23.
//
import MessageUI
import SwiftUI
import Logger

struct ReportABugMailView: UIViewControllerRepresentable {
    
    @Environment(\.presentationMode) var presentation
    @Binding var result: Result<MFMailComposeResult, Error>?
    
    typealias UIViewControllerType = MFMailComposeViewController
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding var presentation: PresentationMode
        @Binding var result: Result<MFMailComposeResult, Error>?
        
        init(
            presentation: Binding<PresentationMode>,
            result: Binding<Result<MFMailComposeResult, Error>?>
        ) {
            _presentation = presentation
            _result = result
        }
        func mailComposeController(
            _ controller: MFMailComposeViewController,
            didFinishWith result: MFMailComposeResult,
            error: Error?
        ) {
            defer {
                $presentation.wrappedValue.dismiss()
            }
            if let error {
                self.result = .failure(error)
            } else {
                self.result = .success(result)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(presentation: presentation, result: $result)
    }
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let mailViewController = MFMailComposeViewController()
        mailViewController.mailComposeDelegate = context.coordinator
        mailViewController.setToRecipients(["support@nos.social"])
        mailViewController.setSubject("Reporting a bug in Nos")
        mailViewController.setMessageBody(
            "Hello, \n\n I have found a bug in Nos and would like to provide feedback",
            isHTML: false
        )
        Task {
            do {
                mailViewController.addAttachmentData(
                    try Data(contentsOf: try await LogHelper.zipLogs()),
                    mimeType: "application/zip", 
                    fileName: "diagnostics.zip"
                )
            } catch {
                Log.error("failed to zip logs for MFMailComposeViewController")
            }
        }
        return mailViewController
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {
    }
}
