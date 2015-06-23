//
//  AttributeTable.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-06-11.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

import UIKit

// AttributeTable is always presented as a segue from CoreController. Its properties are not retained when the user returns to CoreController
class AttributeTable: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var pickerTest=["Undefined","Integer 16","Integer 32","Integer 64","Decimal","Double","Float","String","Boolean","Date","Binary Data","Transformable"];
    
    // vert will be assigned before we segue to this view
    //TODO: release this vert when view disappears
    var vert:Vert?;
    // attrsOrNil an array holding AttributeString managed objects
    var attrsOrNil:Array<AttributeString>?;
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
        if attrsOrNil != nil {
            return attrsOrNil!.count+1;
        }
        else {
            return 0;
        }
    }
    
    // delegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.dataSource == nil {println("AttributeTable: didSelectRowAtIndexPath: data source is nil");}

        //let cell:CustomCell? = self.tableView(tableView, cellForRowAtIndexPath: indexPath) as? CustomCell; would also work in the line below. 
        //However, self cannot be removed. I don't know the reason. The compiler warning doesn't turn up anything when searched on google.
        let cell:CustomCell? = tableView.dataSource?.tableView(tableView, cellForRowAtIndexPath: indexPath) as? CustomCell;
        
        if cell == nil {println("AttributeTable: didSelectRowAtIndexPath: could not find cell that is to be selected");}
        cell!.selectCell();
    }

    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.dataSource == nil {println("AttributeTable: didDeselectRowAtIndexPath: data source is nil");}

        //let cell:CustomCell? = self.tableView(tableView, cellForRowAtIndexPath: indexPath) as? CustomCell; would also work in the line below. 
        //However, self cannot be removed. I don't know the reason. The compiler warning doesn't turn up anything when searched on google.
        let cell:CustomCell? = tableView.dataSource?.tableView(tableView, cellForRowAtIndexPath: indexPath) as? CustomCell;
        
        if cell == nil {println("AttributeTable: didSelectRowAtIndexPath: could not find cell that is to be selected");}
        cell!.deselectCell();
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cellIdentifier:String="AttributeCell";
        var cell:CustomCell? = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as? CustomCell
        if cell == nil {
            // init a custom cell
            cell = CustomCell(style:UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier);
            
            if cell == nil {
                println("AttributeTable: tableView cellForRowAtIndexPath: failed to create cell")
            }
            
            // do any additional setup of the cell
     
        }
        // set the delegate and datasource of the picker view on the table
        cell!.picker!.delegate = self;
        cell!.picker!.dataSource = self;
        
        // config cell by extracting element from attrStrings at given row
        if indexPath.row < attrsOrNil!.count {
            let elem:AnyObject = attrStringsOrNil![indexPath.row];
            if elem is String {
            
                cell!.descriptionLabel!.text=elem as? String;
                
            }
            else {println("AttributeTable: tableView cellForRowAtIndexPath: elem stored in attribute.string is not a string");}
        }
        else {
            // init a UITextField
            let textField=attributeTextField(frame: CGRectMake(110, 10, 185, 30) );
            textField.backgroundColor=UIColor.clearColor();
            cell!.contentView.addSubview(textField);
            setTextField(textField, placeholder:"Add attribute");
        }
        return cell!
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
