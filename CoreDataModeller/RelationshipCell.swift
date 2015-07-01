//
//  RelationshipCell.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-06-30.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

import UIKit

protocol TextFieldManager {
    
    var activeField:UITextField? {get set};
    var shouldMove:Bool? {get set};
}

class RelationshipCell: UITableViewCell,UITextFieldDelegate,UIPickerViewDelegate, UIPickerViewDataSource {
    // there are two ways to end editing of a text field:
    // switching to another text field or hitting the return button
    var willSwitchFields = true;

    var doesCreateNewCell:Bool?;

    let addRelFieldPlaceholderText = "Add relationship";
    // the id of the vert that has been passed to AttrTable
    var vertViewId:Int32?;
    
    //MARK: UI vars 
    //pickerView's delegate is AttributeTable
    var descriptionLabel:UITextField?;
    var picker:Picker?;
    var typeLabel:UILabel?;
    
    //TODO: refactor trello:
    var edge:Edge?;
    
    // selectCell() enables picker scrolling
    func selectCell() {
        if picker == nil {println("RelationshipCell: selectCell: picker is nil")}
        picker!.canScroll = true;
    }
    
    func deselectCell() {
        if picker == nil {println("RelationshipCell: selectCell: picker is nil")}
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
        if picker == nil {println("RelationshipCell: postInitSetup: picker is nil");}
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
        
        if attributesDelegate == nil {println("RelationshipCell: pickerView: attributesDelegate is nil");}
        if row < 0 || pickerTest.count < row { println("RelationshipCell:pickerView:didSelectRow: row is too large after checking doesCreateNewCell"); }

        //TODO: change model with new destination: attributesDelegate!.setAttrType(attr!, type: pickerTest[row]);
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
    //
    func textFieldShouldReturn(textField: UITextField)->Bool {
        
        // user has ended control by hitting return
        willSwitchFields = false;
        
        setAttribute(textField);
        
        textField.resignFirstResponder();
        return true;
    }
    
    private func setAttribute(textField:UITextField) {
        if attributesDelegate == nil {println("RelationshipCell: textFieldShouldReturn: delegate is nil");}
        if vertViewId == nil {println("RelationshipCell: textFieldShouldReturn: vertViewId is nil");}
        if attributesDelegate == nil {println("RelationshipCell: textFieldShouldReturn: attributesDelegate is nil");}
        if attributesDelegate!.attrsOrNil == nil {println("RelationshipCell: textFieldShouldReturn: attributesDelegate's attrsOrNil is nil");}
        if doesCreateNewCell == nil {println("RelationshipCell: textFieldShouldReturn: attributesDelegate's: doesCreateNewCell is nil");}
        
        if attributesDelegate!.validateAttrName(textField.text) {
            if doesCreateNewCell! {
                attributesDelegate!.addAttributeById(vertViewId!, withString: textField.text);
            }
            else {
                // assuming attr is not nil
                //TODO: set name attributesDelegate!.setAttrName(attr!,name: textField.text);
            }
        }
        else {
            textField.text = "";
            textField.placeholder = addAttrFieldPlaceholderText;
        }
    }
    
    //MARK:
    func textFieldDidBeginEditing(textField: UITextField) {
        attributesDelegate!.shouldMove = true;
        
        if attributesDelegate == nil {println("RelationshipCell: textFieldDidBeginEditing: delegate is nil");}
        attributesDelegate!.activeField = textField;
    }
    
    // called when text field resigns first responder status
    func textFieldDidEndEditing(textField: UITextField) {

        attributesDelegate!.shouldMove = false;
        
        // if
        if edge != nil && willSwitchFields {
            //TODO: set name textField.text = attr!.name;
        }
        willSwitchFields = true;
        
        if attributesDelegate == nil {println("RelationshipCell: textFieldDidEndEditing: delegate is nil");}
        attributesDelegate!.activeField = nil;
    
    }
    
}
