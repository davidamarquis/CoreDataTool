//
//  CustomCellTableViewCell.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-06-20.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

import UIKit
import Foundation

protocol CheckAttributes {
    
    func addAttributeById(vertId:Int32, withString attrString:String);
    // the delegate is responsible for presenting an
    func presentViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?);
    
    func setAttrName(attr:Attribute, name:String);
    func setAttrType(attr:Attribute, type:String);
    func validateAttrName(str:String)->Bool;
    
    var attrsOrNil:Array<Attribute>? {get};
}

class CustomCell: UITableViewCell,UITextFieldDelegate,UIPickerViewDelegate, UIPickerViewDataSource {
    // determines if changing the
    var doesCreateNewCell:Bool?;

    var attributesDelegate:CheckAttributes?;
    var pickerTest=["Undefined","Integer 16","Integer 32","Integer 64","Decimal","Double","Float","String","Boolean","Date","Binary Data","Transformable"];
    
    let addAttrFieldPlaceholderText = "Add Attribute";
    // the id of the vert that has been passed to AttrTable
    var vertViewId:Int32?;
    
    //MARK: UI vars 
    //pickerView's delegate is AttributeTable
    var descriptionLabel:UITextField?;
    var picker:Picker?;
    var typeLabel:UILabel?;
    //TODO: refactor trello:
    var attr:Attribute?;

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
    }
    
    //MARK: pickerView datasource
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1;
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerTest.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
    
        return pickerTest[row];
    }
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 20;
    }
    
    //MARK: picker scrolled
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // sometimes scrolling of the picker view is ignored
        if doesCreateNewCell! {return;}
        
        if attributesDelegate == nil {println("CustomCell: pickerView: attributesDelegate is nil");}
        if row < 0 || pickerTest.count < row { println("CustomCell:pickerView:didSelectRow: row is too large after checking doesCreateNewCell"); }

        attributesDelegate!.setAttrType(attr!, type: pickerTest[row]);
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
    


    //MARK: UITextFieldDelegate methods
    func textFieldShouldReturn(textField: UITextField)->Bool {
        
        if attributesDelegate == nil {println("CustomCell: textFieldShouldReturn: delegate is nil");}
        if vertViewId == nil {println("CustomCell: textFieldShouldReturn: vertViewId is nil");}
        if attributesDelegate == nil {println("CustomCell: textFieldShouldReturn: attributesDelegate is nil");}
        if attributesDelegate!.attrsOrNil == nil {println("CustomCell: textFieldShouldReturn: attributesDelegate's attrsOrNil is nil");}
        if doesCreateNewCell == nil {println("CustomCell: textFieldShouldReturn: attributesDelegate's: doesCreateNewCell is nil");}
        
        if attributesDelegate!.validateAttrName(textField.text) {
            if doesCreateNewCell! {
                attributesDelegate!.addAttributeById(vertViewId!, withString: textField.text);
            }
            else {
                // assuming attr is not nil
                attributesDelegate!.setAttrName(attr!,name: textField.text);
            }
        }
        else {
            textField.text = "";
            textField.placeholder = addAttrFieldPlaceholderText;
        }
        textField.resignFirstResponder();
        return true;
    }
    
    
}
