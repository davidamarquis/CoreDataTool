//
//  Options.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-06-29.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

import UIKit

class Options: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let usernameWidth:CGFloat = 200;
        let username = UITextField(frame: CGRectMake(view.bounds.width/2 - usernameWidth/2,100,200,40));
        username.backgroundColor = UIColor.redColor();
        username.placeholder = "Username"
        
        let email = UITextField(frame: CGRectMake(view.bounds.width/2 - usernameWidth/2,150,200,40));
        email.backgroundColor = UIColor.redColor();
        email.placeholder = "Email"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
