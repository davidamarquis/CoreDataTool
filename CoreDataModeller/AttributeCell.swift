//
//  AttributeCellTableViewCell.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-06-20.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

import UIKit
import Foundation

protocol CheckAttributes: class {
    
    func addAttributeById(vertId:Int32, withString attrString:String);
    // the delegate is responsible for presenting an
    func presentViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?);
    
    func setAttrName(attr:Attribute, name:String);
    func setAttrType(attr:Attribute, type:String);
    func validateAttrName(str:String)->Bool;
    
    var attrsOrNil:Array<Attribute>? {get};
    
    var activeField:UITextField? {get set};
    var shouldMove:Bool? {get set};
}

class AttributeCell: UITableViewCell,UITextFieldDelegate,UIPickerViewDelegate, UIPickerViewDataSource {

    weak var attributesDelegate:CheckAttributes?;
    
    // There are two ways to end editing of a text field
    // switching to another text field or hitting the return button.
    var willSwitchFields = true;

    // if the field or the picker gets changed then this flag determines the response
    var doesCreateNewCell:Bool?;

    var types=["Undefined","Integer 16","Integer 32","Integer 64","Decimal","Double","Float","String","Boolean","Date","Binary Data","Transformable"];
    
    let addAttrFieldPlaceholderText = "Add Attribute";
    // the id of the vert that has been passed to AttrTable
    var vertViewId:Int32?;
    
    // controls
    var attrContents = EntityContents();
    var picker:Picker?;

    var attr:Attribute?;
    
    //MARK: methods
    // selectCell() enables picker scrolling
    func selectCell() {
        if picker == nil {print("AttributeCell: selectCell: picker is nil")}
        picker!.canScroll = true;
    }
    
    func deselectCell() {
        if picker == nil {print("AttributeCell: selectCell: picker is nil")}
        picker!.canScroll = false;
    }

    override init(style:UITableViewCellStyle, reuseIdentifier:String?) {
        super.init(style: style, reuseIdentifier:reuseIdentifier);
        postInitSetup();
    }
    
    func postInitSetup() {
        let textAreaColor = UIColor(red: 32/255, green: 135/255, blue: 252/255, alpha: 1); // blue
        let backColor = UIColor(red: 28/255, green: 35/255, blue: 53/255, alpha: 1); // purple
        let contentsHeight:CGFloat = 64;
        let labelWidth:CGFloat = 160;
        
        // set background color
        contentView.backgroundColor = backColor;

        // attr
        attrContents = EntityContents(frame: CGRectMake(0, 0, labelWidth, contentsHeight));
        attrContents.backColor = backColor;
        attrContents.textAreaColor = textAreaColor;
        attrContents.labelText = "Attribute";
        // attrContents.fieldText is set by the table view delegate when this cell is init()
        attrContents.fieldPlaceholder = "Add Attribute";
        attrContents.descField!.delegate = self;
        addSubview(attrContents);
        
        picker=Picker();
        if picker == nil {print("AttributeCell: postInitSetup: picker is nil");}
        picker!.frame = CGRectMake(160,0,140,self.frame.height);
        picker!.backgroundColor = backColor;
        contentView.addSubview(picker!);
    }
    
    //MARK: pickerView datasource
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1;
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return types.count
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        // set text as destinations[row] with white color
        // from http://stackoverflow.com/questions/19232817/how-do-i-change-the-color-of-the-text-in-a-uipickerview-under-ios-7
        return NSAttributedString(string: types[row], attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
    }
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 20;
    }
    
    //MARK: picker scrolled
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // sometimes scrolling of the picker view is ignored
        if doesCreateNewCell! {return;}
        
        if attributesDelegate == nil {print("AttributeCell: pickerView: attributesDelegate is nil");}
        if row < 0 || types.count < row { print("AttributeCell:pickerView:didSelectRow: row is too large after checking doesCreateNewCell"); }

        attributesDelegate!.setAttrType(attr!, type: types[row]);
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
    
    func setAttribute(textField:UITextField) {
        if attributesDelegate == nil {print("AttributeCell: textFieldShouldReturn: delegate is nil");}
        if vertViewId == nil {print("AttributeCell: textFieldShouldReturn: vertViewId is nil");}
        if attributesDelegate == nil {print("AttributeCell: textFieldShouldReturn: attributesDelegate is nil");}
        if attributesDelegate!.attrsOrNil == nil {print("AttributeCell: textFieldShouldReturn: attributesDelegate's attrsOrNil is nil");}
        if doesCreateNewCell == nil {print("AttributeCell: textFieldShouldReturn: attributesDelegate's: doesCreateNewCell is nil");}
        
        if attributesDelegate!.validateAttrName(textField.text!) {
        
            if doesCreateNewCell! {
                attributesDelegate!.addAttributeById(vertViewId!, withString: textField.text!);
            }
            else {
                // assuming attr is not nil
                attributesDelegate!.setAttrName(attr!,name: textField.text!);
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
        
        if attributesDelegate == nil {print("AttributeCell: textFieldDidBeginEditing: delegate is nil");}
        attributesDelegate!.activeField = textField;
    }
    
    // called when text field resigns first responder status
    func textFieldDidEndEditing(textField: UITextField) {

        attributesDelegate!.shouldMove = false;
        
        if attr != nil && willSwitchFields {
            textField.text = attr!.name;
        }
        willSwitchFields = true;
        
        if attributesDelegate == nil {print("AttributeCell: textFieldDidEndEditing: delegate is nil");}
        attributesDelegate!.activeField = nil;
    
    }
    
    deinit {
    
    }
}
