//
//  mailGen.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-06-21.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

import UIKit;
import MessageUI;

protocol MailGenDelegate: class {
    var graph:Graph? {get};
    func presentViewController(viewControllerToPresent: UIViewController,animated flag: Bool, completion: (() -> Void)?);
    func dismissViewControllerAnimated(flag: Bool, completion: (() -> Void)?);
}

class MailGen: NSObject, MFMailComposeViewControllerDelegate {
    
    //TODO:
    weak var delegate:MailGenDelegate?;
    //let mailVC:MFMailComposeViewController = MFMailComposeViewController();
    
    var user:User? = nil;
    
    //MARK: nav bar
    func emailPressed() {

        if delegate == nil {print("mailGen: emailPressed(): delegate is nil");}
        
        if MFMailComposeViewController.canSendMail() {
            var mailVC:MFMailComposeViewController? = MFMailComposeViewController();
            
            if mailVC!.mailComposeDelegate == nil {
                mailVC!.mailComposeDelegate = self;
            }
            
            mailVC!.modalTransitionStyle = UIModalTransitionStyle.CoverVertical;
            
            mailVC!.setSubject("test file");
            mailVC!.setToRecipients(["david.a.marquis@gmail.com"]);
            
            // http://stackoverflow.com/questions/901357/how-do-i-convert-an-nsstring-value-to-nsdata
            // create app delegate header string

            // generate app delegate files
            makeAppDelegateHGen(mailVC!);
            makeAppDelegateMGen(mailVC!);
            
            // generate entity files 
            for v in delegate!.graph!.verts! {
                if let vert=(v as? Vert) {
                 
                    let entityHGen = ObjCEntityHGen();
                    if user == nil {print("MailGen: emailPressed: user is nil");}
                    entityHGen.user = user;
                    
                    entityHGen.vert = vert;
                    entityHGen.updateString();
                    let entityStr = entityHGen.entityH;
                    let entityData:NSData?=entityStr.dataUsingEncoding(NSUTF8StringEncoding);
                    mailVC!.addAttachmentData(entityData!, mimeType:"text/rtf", fileName:"\(vert.title).h");
                    
                    // M
                    let entityMGen = ObjCEntityMGen();
                    if user == nil {print("MailGen: emailPressed: user is nil");}
                    entityMGen.user = user;
                    
                    entityMGen.vert = vert;
                    entityMGen.updateString();
                    let entityMStr = entityMGen.entityM;
                    let entityMData:NSData?=entityMStr.dataUsingEncoding(NSUTF8StringEncoding);
                    mailVC!.addAttachmentData(entityMData!, mimeType:"text/rtf", fileName:"\(vert.title).m");
                }
            }
            
            // dismiss the VC
            delegate!.presentViewController(mailVC!, animated: true, completion: nil);
            
            // TODO: test making nil
            mailVC = nil;
            
        }
        else {
            showSendMailErrorAlert();
        }
    }
    
    // makeAppDelegateHGen() adds an app delegate.h string attachment
    private func makeAppDelegateHGen(mailViewController:MFMailComposeViewController) {
        let headerGen = ObjCAppDelegateHGen();
        if user == nil {print("MailGen: makeAppDelegateHGen: user is nil");}
        headerGen.user = user;
        
        headerGen.updateString();
        let appDelegHStr = headerGen.appDelegateH;
        // attach app delegate header file to mail
        let delegHeaderData:NSData?=appDelegHStr.dataUsingEncoding(NSUTF8StringEncoding);
        if delegHeaderData != nil {
            mailViewController.addAttachmentData(delegHeaderData!, mimeType:"text/rtf", fileName:"AppDelegate.h");
        }
    }
    
    // makeAppDelegateMGen() adds an app delegate.m string attachment
    private func makeAppDelegateMGen(mailViewController:MFMailComposeViewController) {
        let delegMGen = ObjCAppDelegateMGen();
        if user == nil {print("MailGen: makeAppDelegateMGen: user is nil");}
        delegMGen.user = user;
        
        delegMGen.graph = delegate!.graph;
        delegMGen.updateString();
        let appDelegMStr = delegMGen.appDelegateM;
        // attach app delegate.m file to mail
        let delegMData:NSData? = appDelegMStr.dataUsingEncoding(NSUTF8StringEncoding);
        if delegMData != nil {
            mailViewController.addAttachmentData(delegMData!, mimeType:"text/rtf", fileName:"AppDelegate.m");
        }
    }
    
    //TODO: UIAlertView is deprecated
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }

    // mailComposeController() handles emails that are sent
    //func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        
        if result.rawValue == MFMailComposeResultCancelled.rawValue {
            print("CoreController: mailComposeController: result=Cancelled");
        }
        else if result.rawValue == MFMailComposeResultSaved.rawValue {
            print("CoreController: mailComposeController: result=Saved");
        }
        else if result.rawValue == MFMailComposeResultSent.rawValue {
            print("CoreController: mailComposeController: result=Sent");
        }
        else if result.rawValue == MFMailComposeResultFailed.rawValue {
            print("CoreController: mailComposeController: result=Failed");
        }
    
        if error != nil {
            print("CoreController: mailComposeController: error sending email");
            print(error!.localizedDescription);
        }
        //TODO: test reset delegate
        //mailVC = MFMailComposeViewController();
        
        delegate!.dismissViewControllerAnimated(true, completion: nil);
    }
    
}
