//
//  Options.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-06-29.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

import UIKit

class Options: UIViewController, UITextFieldDelegate {

    //var nameOfUser:String? = String();
    //var emailOfUser:String? = String();
    var user:User? = nil;
    var username: UITextField?;
    var email: UITextField?;
    let usernameWidth:CGFloat = 200;
    var addAccount:UIButton?;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        username = TagTextField(frame: CGRectMake(view.bounds.width/2 - usernameWidth/2,100,200,40));
        username!.backgroundColor = UIColor.redColor();
        username!.delegate = self;
        username!.fieldTag = "nameOfUser";
        
        if user == nil {println("Options: viewDidLoad: user is nil");}
        if user!.username == "" {
            username!.placeholder = "Name";
        }
        else {
            username!.text = user!.username;
        }
        view.addSubview(username!);
        
        email = TagTextField(frame: CGRectMake(view.bounds.width/2 - usernameWidth/2,170,200,40));
        email!.backgroundColor = UIColor.redColor();
        email!.delegate = self;
        username!.fieldTag = "email";
        
        if user!.email == "" {
            email!.placeholder = "Email";
        }
        else {
            email!.text = user!.email;
        }
        view.addSubview(email!);
        
        if user!.email == "" || user!.username == "" {
            addAccount = UIButton(frame: CGRectMake(view.bounds.width/2 - usernameWidth/2,240,200,40));
            addAccount!.backgroundColor = UIColor.grayColor();
            addAccount!.setTitle("Add Account", forState: UIControlState.Normal);
            addAccount!.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal);
            addAccount!.targetForAction("addAccountResponse", withSender: self);
            view.addSubview(addAccount!);
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func addAccountResponse() {
        if validAccount() {
        
            user!.username = username!.text!;
            user!.email = email!.text!;
            addAccount!.removeFromSuperview();
        }
    }
    
    func validAccount()->Bool {
        if user!.username == "" || user!.email == "" {
            return false;
        }
        return true;
    }
    
    //MARK: UITextFieldDelegate methods
    func textFieldShouldReturn(textField: TagTextField)->Bool {
    
        // if username then update the model
        
        // if email then update the model
        
        
        textField.resignFirstResponder();
        return true;
    }
}
