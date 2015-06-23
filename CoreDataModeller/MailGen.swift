//
//  mailGen.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-06-21.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

import UIKit;
import MessageUI;

protocol MailGenDelegate {
    var graph:Graph? {get};
    func presentViewController(viewControllerToPresent: UIViewController,animated flag: Bool, completion: (() -> Void)?);
    func dismissViewControllerAnimated(flag: Bool, completion: (() -> Void)?);
}

class MailGen: NSObject, MFMailComposeViewControllerDelegate {
    
    //TODO:
    weak var delegate:CoreController?;
    let mailVC:MFMailComposeViewController = MFMailComposeViewController();
    
    //MARK: nav bar
    func emailPressed(sender: AnyObject) {
    
        // mailVC is of type
        if mailVC.mailComposeDelegate == nil {
            mailVC.mailComposeDelegate = self;
        }
        if !(mailVC.mailComposeDelegate is CoreController) {
            println("CoreController: emailPressed: err mailComposeDelegate is not equal to self");
        }
        
        if delegate == nil {
            println("mailGen: emailPressed() delegate is nil");
        }
        if MFMailComposeViewController.canSendMail() {
            mailVC.modalTransitionStyle = UIModalTransitionStyle.CoverVertical;
            
            mailVC.setSubject("test file");
            mailVC.setToRecipients(["david.a.marquis@gmail.com"]);
            
            // TODO: let myData:NSData = NSKeyedArchiver.archivedDataWithRootObject("cake is good for taste but bad for weight");
            // http://stackoverflow.com/questions/901357/how-do-i-convert-an-nsstring-value-to-nsdata
            
            // create app delegate header string
            let headerGen:ObjCAppDelegateHGen = ObjCAppDelegateHGen();
            headerGen.updateString();
            let appDelegHStr = headerGen.appDelegateH;
            // attach app delegate header file to mail
            let delegHeaderData:NSData?=appDelegHStr.dataUsingEncoding(NSUTF8StringEncoding);
            if delegHeaderData != nil {
                mailVC.addAttachmentData(delegHeaderData, mimeType:"text/rtf", fileName:"AppDelegate.h");
            }
            
            // create app delegate header string
            let delegMGen:ObjCAppDelegateMGen = ObjCAppDelegateMGen();
            delegMGen.updateString();
            let appDelegMStr = delegMGen.appDelegateM;
            // attach app delegate header file to mail
            let delegMData:NSData?=appDelegMStr.dataUsingEncoding(NSUTF8StringEncoding);
            if delegMData != nil {
                mailVC.addAttachmentData(delegMData, mimeType:"text/rtf", fileName:"AppDelegate.m");
            }
            
            
            for v in delegate!.graph!.verts {
                if let vert=(v as? Vert) {
                
                    let testStr = "";
                    let testData:NSData?=testStr.dataUsingEncoding(NSUTF8StringEncoding);
                    mailVC.addAttachmentData(testData, mimeType:"text/rtf", fileName:"\(vert.title).m");
                }
            }
            
            // dismiss the VC
            delegate!.presentViewController(mailVC, animated: true, completion: nil);
        }
        else {
            showSendMailErrorAlert();
        }
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // mailComposeController() handles emails that are sent
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {

        if result.value == MFMailComposeResultCancelled.value {
            println("CoreController: mailComposeController: result=Cancelled");
        }
        else if result.value == MFMailComposeResultSaved.value {
            println("CoreController: mailComposeController: result=Saved");
        }
        else if result.value == MFMailComposeResultSent.value {
            println("CoreController: mailComposeController: result=Sent");
        }
        else if result.value == MFMailComposeResultFailed.value {
            println("CoreController: mailComposeController: result=Failed");
        }
    
        if error != nil {
            println("CoreController: mailComposeController: error sending email");
            println(error.localizedDescription);
        }
        //TODO: test reset delegate
        //mailVC = MFMailComposeViewController();
        
        delegate!.dismissViewControllerAnimated(true, completion: nil);
    }

}
