//
//  MailComposer.swift
//  Learn The Clock!
//
//  Created by Sebastian Strus on 2/21/26.
//

import SwiftUI

#if os(iOS)
import MessageUI
import MessageUI

struct MailComposer: UIViewControllerRepresentable {
    
    @Binding var isPresented: Bool
    let screenshot: UIImage?
    let recipient: String
    let subject: String
    
    // NEW: receive from SwiftUI context
    let screenSize: CGSize
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding var isPresented: Bool
        
        init(isPresented: Binding<Bool>) {
            _isPresented = isPresented
        }
        
        func mailComposeController(
            _ controller: MFMailComposeViewController,
            didFinishWith result: MFMailComposeResult,
            error: Error?
        ) {
            isPresented = false
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(isPresented: $isPresented)
    }
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = context.coordinator
        mail.setToRecipients([recipient])
        mail.setSubject(subject)
        mail.setMessageBody(
            getEmailBody(),
            isHTML: false
        )
        
        if let screenshotData = screenshot?.pngData() {
            mail.addAttachmentData(
                screenshotData,
                mimeType: "image/png",
                fileName: "screenshot.png"
            )
        }
        
        return mail
    }
    
    func updateUIViewController(
        _ uiViewController: MFMailComposeViewController,
        context: Context
    ) {}
    
    private func getEmailBody() -> String {
        return """
        I would like to share my feedback on the Learn The Clock! app:
        
        ------------------
        Device: \(UIDevice.current.modelName)
        iOS: \(UIDevice.current.systemVersion)
        App Version: \(Bundle.main.appVersion)
        """
    }
}
#endif
