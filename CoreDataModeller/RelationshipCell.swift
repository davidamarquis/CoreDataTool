//
//  RelationshipCell.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-06-30.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

import UIKit
import Foundation

protocol RelationshipDelegate: class {
    
    var activeField:UITextField? {get set};
    var shouldMove:Bool? {get set};
    var vert:Vert? {get};
}

class RelationshipCell: UITableViewCell,UITextFieldDelegate,UIPickerViewDelegate, UIPickerViewDataSource {
    
    weak var relationshipDelegate:RelationshipDelegate?;
    
    // there are two ways to end editing of a text field:
    // switching to another text field or hitting the return button
    var willSwitchFields = true;
    var doesCreateNewCell:Bool?;

    // text
    let addRelFieldPlaceholderText = "Add relationship";
    let addInvFieldPlaceholderText = "Add inverse";
    
    // destinations holds the titles of the verts that the edge can end on. Assigned by EntityTable
    var destinations:Array<String> = Array<String>();
    var edge:Edge?;
    // controls
    var invContents:EntityContents = EntityContents();
    var relContents:EntityContents = EntityContents();
    var picker:Picker?;
    
    // selectCell() enables picker scrolling
    func selectCell() {
        if picker == nil {print("RelationshipCell: selectCell: picker is nil")}
        picker!.canScroll = true;
    }
    
    func deselectCell() {
        if picker == nil {print("RelationshipCell: selectCell: picker is nil")}
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
        
        contentView.backgroundColor = backColor;

        // rel
        relContents = EntityContents(frame: CGRectMake(0, relContents.frame.height, labelWidth, contentsHeight));
        relContents.backColor = backColor;
        relContents.textAreaColor = textAreaColor;
        relContents.labelText = "Relationship";
        // relContents.fieldText is set by the table view delegate when this cell is init()
        relContents.fieldPlaceholder = "Add Relationship";
        relContents.descField!.delegate = self;
        addSubview(relContents);
        
        // inverse
        invContents = EntityContents(frame: CGRectMake(0, relContents.frame.height, labelWidth, contentsHeight));
        invContents.backColor = backColor;
        invContents.textAreaColor = textAreaColor;
        invContents.labelText = "Inverse";
        // invContents.fieldText is set by the table view delegate when this cell is init()
        invContents.fieldPlaceholder = "Add Inverse";
        invContents.descField!.delegate = self;
        addSubview(invContents);
        
        // picker
        picker = Picker();
        if picker == nil {print("RelationshipCell: postInitSetup: picker is nil");}
        picker!.backgroundColor = backColor;
        // picker has a discrete set of possible heights
        picker!.frame = CGRectMake(160,0,140,self.frame.height);
        
        contentView.addSubview(picker!);
    }
    
    //MARK: pickerView datasource
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1;
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return destinations.count;
    }
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 20;
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        // set text as destinations[row] with white color
        // from http://stackoverflow.com/questions/19232817/how-do-i-change-the-color-of-the-text-in-a-uipickerview-under-ios-7
        return NSAttributedString(string: destinations[row], attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
    }
    
    //MARK: picker scrolled
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // sometimes scrolling of the picker view is ignored
        if doesCreateNewCell! {return;}
        
        if relationshipDelegate == nil {print("RelationshipCell: pickerView: relationshipDelegate is nil");}
        if row < 0 || destinations.count < row { print("RelationshipCell:pickerView:didSelectRow: row is too large after checking doesCreateNewCell"); }

        //TODO: change model with new destination: relationshipDelegate!.setAttrType(attr!, type: pickerTest[row]);
    }
    
    private func setTextField(textField:UITextField, placeholder:String) {

        
        textField.delegate = self;
    }
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder);
        postInitSetup();
    }
    
    //MARK: UITextFieldDelegate methods
    //
    func textFieldShouldReturn(textField: UITextField)->Bool {
        
        // set willSwitchField as user has ended control by hitting return
        willSwitchFields = false;
        
        setRelName(textField);
        
        textField.resignFirstResponder();
        return true;
    }
    
    // kvo response to relationship name being set
    func setRelName(textField:UITextField) {
        if relationshipDelegate == nil {print("RelationshipCell: textFieldShouldReturn: delegate is nil");}
        if doesCreateNewCell == nil {print("RelationshipCell: textFieldShouldReturn: relationshipDelegate's: doesCreateNewCell is nil");}
        
        // validate rel name and add
        if validateRel(textField.text!) {
            edge!.setNameForVert(relationshipDelegate!.vert!, relationshipName: textField.text!);
        }
        else {
            textField.text = "";
            textField.placeholder = addRelFieldPlaceholderText;
        }
    }
    
    // temporary method for validating relationships
    func validateRel(text:String)->Bool {
        if text != "" {
            return true;
        }
        return false;
    }
    
    //MARK:
    func textFieldDidBeginEditing(textField: UITextField) {
        relationshipDelegate!.shouldMove = true;
        relationshipDelegate!.shouldMove = true;
        
        if relationshipDelegate == nil {print("RelationshipCell: textFieldDidBeginEditing: delegate is nil");}
        relationshipDelegate!.activeField = textField;
    }
    
    // called when text field resigns first responder status
    func textFieldDidEndEditing(textField: UITextField) {

        relationshipDelegate!.shouldMove = false;
        
        // if
        if edge != nil && willSwitchFields {
            //TODO: set name textField.text = attr!.name;
        }
        willSwitchFields = true;
        
        if relationshipDelegate == nil {print("RelationshipCell: textFieldDidEndEditing: delegate is nil");}
        relationshipDelegate!.activeField = nil;
    
    }
    
    deinit {
    
    }
    
}
