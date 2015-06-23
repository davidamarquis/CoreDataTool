//
//  CustomCellTableViewCell.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-06-20.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

import UIKit
import Foundation

protocol CellChangeResponse {
    func addAttributeById(vertId:Int32, withString attrString:String);
    func presentViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?);
}

protocol CheckAttributes {
    var attrStringsOrNil:Array<String>? {get};
}

class CustomCell: UITableViewCell,UITextFieldDelegate {
 
    var showAttrErr=false;
    
    var attributesDelegate:CheckAttributes?;
    
    let addAttrFieldPlaceholderText = "Add Attribute";
    var delegate:CellChangeResponse?;
    // the id of the vert that has been passed to AttrTable
    var vertViewId:Int32?;
    
    //MARK: UI vars 
    //pickerView's delegate is AttributeTable
    var descriptionLabel:UITextField?;
    var picker:Picker?;
    var typeLabel:UILabel?;

    // selectCell() enables picker scrolling
    func selectCell() {
        if picker == nil {println("CustomCell: selectCell: picker is nil")}
        picker!.canScroll = true;
    }
    
    func deselectCell() {
        if picker == nil {println("CustomCell: selectCell: picker is nil")}
        picker!.canScroll = false;
    }

    override init(style:UITableViewCellStyle, reuseIdentifier:String?) {
        super.init(style: style, reuseIdentifier:reuseIdentifier);
        postInitSetup();
    }
    
    func postInitSetup() {
        // configure control(s)
        descriptionLabel = UITextField(frame: CGRectMake(0, 0, 160, 48));
        descriptionLabel!.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1);
        setTextField(descriptionLabel!, placeholder: addAttrFieldPlaceholderText);
        contentView.addSubview(descriptionLabel!);
        
        if descriptionLabel != nil {
            typeLabel = UILabel(frame: CGRectMake(0, descriptionLabel!.frame.height, 160, descriptionLabel!.frame.height));
            typeLabel!.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1);
            contentView.addSubview(typeLabel!);
        }
        else {println("CoreController: descriptionLabel is nil so can't set typeLabel");}
        
        picker=Picker();
        if picker == nil {println("CustomCell: postInitSetup: picker is nil");}
        picker!.frame = CGRectMake(160,0,140,self.frame.height);
        contentView.addSubview(picker!);
        
        let noteCenter:NSNotificationCenter = NSNotificationCenter.defaultCenter();
        let mainQueue:NSOperationQueue=NSOperationQueue.mainQueue();
        
        noteCenter.addObserverForName( UIKeyboardWillHideNotification, object: nil, queue: mainQueue, usingBlock:
        {(notification:NSNotification!) -> Void in
        
            if self.showAttrErr {
                let alert = UIAlertController(title: "Attribute Exists", message: "Cannot add an attribute with the same name as an already existing attribute", preferredStyle: .Alert);
                let alertAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil);
                alert.addAction(alertAction);
                self.delegate!.presentViewController(alert, animated: false, completion:
                {() -> Void in
                    // reset the showAttrErr flag
                    self.showAttrErr=false;
                });
            }
        });
    
    }
    
    private func setTextField(textField:UITextField, placeholder:String) {
        textField.adjustsFontSizeToFitWidth = true;
        textField.textColor = UIColor.blackColor();
        textField.placeholder = placeholder;
        textField.keyboardType = UIKeyboardType.EmailAddress;
        textField.delegate = self;
    }
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder);
        postInitSetup();
    }
    
    // default contains function is not working in Swift 1.2
    func contains(arr:Array<String>, str:String)->Bool {
        for elem in arr {
            if elem == str {
                return true;
            }
        }
        return false;
    }

    //MARK: UITextFieldDelegate methods
    func textFieldShouldReturn(textField: UITextField)->Bool {
        
        if delegate == nil {println("CustomCell: textFieldShouldReturn: delegate is nil");}
        if vertViewId == nil {println("CustomCell: textFieldShouldReturn: vertViewId is nil");}
        if attributesDelegate == nil {println("CustomCell: textFieldShouldReturn: attributesDelegate is nil");}
        if attributesDelegate!.attrStringsOrNil == nil {println("CustomCell: textFieldShouldReturn: attributesDelegate's attrStringsOrNil is nil");}
        
        if !contains(attributesDelegate!.attrStringsOrNil!, str:textField.text) {
            delegate!.addAttributeById(vertViewId!, withString: textField.text);
        }
        else {
            showAttrErr=true;
        }
        textField.resignFirstResponder();
        return true;
    }
    
    
}
