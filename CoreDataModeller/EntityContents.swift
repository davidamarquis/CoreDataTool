//
//  Textfield.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-07-05.
//  Copyright © 2015 David Marquis. All rights reserved.
//

import UIKit

class EntityContents: UIView {

    var descField:EntityTextField? = EntityTextField();
    var descLabel:UILabel = UILabel();
    var labelText:String = String();
    var fieldText:String = String();
    var fieldPlaceholder:String = String();
    
    let fieldHeight:CGFloat = 48;
    let labelWidth:CGFloat = 160;
    let labelHeight:CGFloat = 20;
    var backColor:UIColor = UIColor();
    var textAreaColor:UIColor = UIColor();
    
    // colors, text (label, field), placeholder text (field), and field delegate must be set prior to layoutSubviews()
    override func layoutSubviews() {
        descLabel.frame = CGRectMake(0, 0, labelWidth, labelHeight);
        descLabel.backgroundColor = backColor;
        descLabel.textColor = UIColor.grayColor();
        descLabel.text = labelText;
        descLabel.font = UIFont(name: "HelveticaNeue", size: 13);
        self.addSubview(descLabel);
        
        descField!.frame = CGRectMake(CGFloat(0), labelHeight, labelWidth, self.bounds.height - labelHeight);
        // colors, outline
        descField!.backgroundColor = textAreaColor;
        descField!.textColor = UIColor.whiteColor();
        descField!.layer.borderWidth = CGFloat(1);
        descField!.layer.borderColor = UIColor(red: 1,green: 1, blue: 1, alpha: 1).CGColor;
        descField!.layer.cornerRadius = CGFloat(5);
        // settings
        descField!.clearsOnBeginEditing = true;
        descField!.adjustsFontSizeToFitWidth = true;
        descField!.keyboardType = UIKeyboardType.EmailAddress;
        // text
        descField!.placeholder = fieldPlaceholder;
        descField!.text = fieldText;
        self.addSubview(descField!);
    }
}
