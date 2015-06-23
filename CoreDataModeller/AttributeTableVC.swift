//
//  AttributeTable.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-06-11.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

import UIKit

// AttributeTable is always presented as a segue from CoreController. Its properties are not retained when the user returns to CoreController
class AttributeTableVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, CheckAttributes {
    
    var pickerTest=["Undefined","Integer 16","Integer 32","Integer 64","Decimal","Double","Float","String","Boolean","Date","Binary Data","Transformable"];
    
    // vert will be assigned before we segue to this view
    var vert:Vert?;
    // attrsOrNil an array holding AttributeString managed objects
    var attrsOrNil:Array<AttributeString>?;
    var relsOrNil:Array<Edge>?;
    // an array holding each of the string properties of attrsOrNil
    var attrStringsOrNil:Array<String>?;
    
    let attrView:UITableView?=UITableView();
    var titleField:UITextField?;
    let titleHeight:CGFloat=48;
    
    //MARK: view lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        if vert == nil {
           println("AttributeTable: viewWillAppear: err vert is nil");
        }
        
        titleField = UITextField(frame: CGRectMake( CGFloat(0), CGFloat(20+44), view.frame.width, titleHeight ));
        if titleField == nil {println("AttributeTable: viewWillAppear: err titleField is nil");}
        
        view.addSubview(titleField!);
        titleField!.backgroundColor=UIColor.blueColor();
        setTextField(titleField!, placeholder:"Add title");
        // if the vert does have text in its title then we override the placeholder
        if !vert!.title.isEmpty {
            titleField!.text = vert!.title;
        }
        
        // create the table view
        attrView!.frame = CGRectMake(CGFloat(0),CGFloat(20+44)+titleHeight,view.frame.width,view.frame.height-CGFloat(titleHeight));
        attrView!.dataSource = self;
        attrView!.delegate = self;
        //attrView!.delaysContentTouches=false;
        //attrView!.canCancelContentTouches=true;
        attrView!.allowsSelection=false;
        //attrView!.userInteractionEnabled=false;
        
        // register class will allow new cells to be initialized properly at launch
        // an incorrect class name will cause cells to not be shown at launch
        attrView!.registerClass(CustomCell.self, forCellReuseIdentifier:"AttributeCell");
        attrView!.reloadData();
        view.addSubview(attrView!);
        
        getStringsFromVert();
    }
    
    //MARK: setup methods
    func getStringsFromVert() {
        attrsOrNil=vert?.attributeStrings.allObjects as? Array<AttributeString>;
        
        // init the array that will hold the strings
        attrStringsOrNil = Array<String>();
        if attrsOrNil == nil { println("AttributeTable: viewWillAppear: no attributes found on the given vert"); }
        for attr in attrsOrNil! {
            attrStringsOrNil!.append(attr.string);
        }
        
        // sort the attributes alphabetically
        attrStringsOrNil = sorted(attrStringsOrNil!, { $0 < $1 })
        attrView!.reloadData();
    }
    
    //MARK: pickerView interface
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
    
    //MARK: UITextFieldDelegate methods
    func textFieldShouldReturn(textField: UITextField)->Bool {
    
        textField.resignFirstResponder();
        
        if vert == nil {println("AttributeTable: testFieldShouldReturn: vert is nil");};
        
        if textField is attributeTextField {
            if navigationController == nil {println("AttributeTable: testFieldShouldReturn: nav controller is nil");}
            for vc in navigationController!.viewControllers {
                if vc is CoreController {
                    (vc as! CoreController).addAttributeById(vert!.vertViewId, withString: textField.text);
                }
            }
        }
        else {
            // assumption here: the only textfields in AttributeTable not=attributeTextField is the title text field
            if navigationController == nil {println("AttributeTable: testFieldShouldReturn: nav controller is nil");}
            for vc in navigationController!.viewControllers {
                if vc is CoreController {
                    //entityName = textField.text;
                    // add the new title to the model
                    (vc as! CoreController).setTitle(vert!.vertViewId, title: textField.text);
                }
            }
        }
        return true;
    }
    
    //MARK: table view data source and delegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 162;
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 2
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if section == 0 {
            if attrsOrNil != nil {
                return attrsOrNil!.count+1;
            }
            else {
                return 0;
            }
        }
        else if section == 1 {
            if relsOrNil != nil {
                return relsOrNil!.count+1;
            }
            else {
                return 0;
            }
        }
        else {
            println("AttributeTableVC: numberOfRowsInSection: invalid number of sections");
            return 0;
        }
    }
    
    //MARK: table view helpers
    func inAttributesSection(indexPath:NSIndexPath)->Bool {
        if indexPath.row < self.tableView(attrView!, numberOfRowsInSection: 0) {
            return true;
        }
        else {return false;}
    }
    func inRelationshipsSection(indexPath:NSIndexPath)->Bool {
        if self.tableView(attrView!, numberOfRowsInSection: 1) <= indexPath.row && indexPath.row < self.tableView(attrView!, numberOfRowsInSection: 1) {
            return true;
        }
        else {return false;}
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {

        let cellIdentifier:String="AttributeCell";
        var cell:CustomCell? = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as? CustomCell
        if cell == nil {
            // init a custom cell
            cell = CustomCell(style:UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier);
            
            if cell == nil{println("AttributeTable: tableView cellForRowAtIndexPath: failed to create cell");}
            
            // do any additional setup of the cell...
        }
        cell!.picker!.delegate = self; //UIPickerView delegate
        cell!.picker!.dataSource = self; //UIPickerView data source
        cell!.attributesDelegate = self; //CheckAttributes delegate

        // customize the cell based on its section
        if inAttributesSection(indexPath) {
            setAttributeCell(indexPath, cell: cell!);
        }
        else if inRelationshipsSection(indexPath) {
            setRelationshipCell(indexPath, cell: cell!)
        }
        else {
            println("AttributeTable: tableView cellForRowAtIndexPath: invalid section");
        }
        return cell!
    }
    
    // setAttributeCell() does the setup for a table view cell in the attributes section. 
    // Assumes that the indexPath row its given is in the right section
    func setAttributeCell(indexPath: NSIndexPath, cell:CustomCell) {
        
        // set the text showing the attribute name
        // assumption: attrsOrNil!.count+1 = length of attributes section
        if indexPath.row < attrsOrNil!.count
        {
            let elem:AnyObject = attrStringsOrNil![indexPath.row];
            if !(elem is String) {"AttributeTable: tableView setAttributeCell(): elem stored in attribute.string is not a string"}
            
            //set the text of the cell textfield
            cell.descriptionLabel!.text=elem as? String;
        }
        else {
            // the last cell in the attribute section invites creating a new cell
            cell.descriptionLabel!.text=cell.addAttrFieldPlaceholderText;
        }
        
        // set the delegate for cell
        if navigationController == nil {println("AttributeTable: setAttributeCell(): nav controller is nil");}
        // assumes there is only a single CoreController in nav
        for vc in navigationController!.viewControllers
        {
            if vc is CoreController
            {
                cell.delegate=vc as! CoreController; // UITextField subclass delegate
                cell.vertViewId=vert!.vertViewId;
            }
        }
    }
    
    // setRelationshipCell() does the setup for a table view cell in the attributes section.
    // Assumes that the indexPath row its given is in the right section
    func setRelationshipCell(indexPath: NSIndexPath, cell:CustomCell) {
         //TODO:
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionName:String?;
        switch (section)
        {
            case 0:
                sectionName = "Attributes"
                break;
            case 1:
                sectionName = "Relationships";
                break;
            default:
                sectionName = "";
                break;
        }    
        return sectionName;
    }

    
    //MARK: helper methods
    private func setTextField(textField:UITextField, placeholder:String) {
        textField.adjustsFontSizeToFitWidth = true;
        textField.textColor = UIColor.blackColor();
        textField.placeholder = placeholder;
        textField.keyboardType = UIKeyboardType.EmailAddress;
        textField.delegate = self;
    }
}
