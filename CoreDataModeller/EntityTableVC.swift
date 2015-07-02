//
//  AttributeTable.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-06-11.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

import UIKit;
import CoreData;

// AttributeTable is always presented as a segue from CoreController. Its properties are not retained when the user returns to CoreController
class EntityTableVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, CheckAttributes, RelationshipDelegate {
    
    // a flag that determines if keyboard appearance should trigger an attempt to scroll entityTable
    var shouldMove:Bool?=false;
    
    // flags for validating attribute name input from user
    var attrNameDidNotStartWithCaptial=false;
    var attrAlreadyExists=false;
    // error strings
    let attrTypeWarning="Entity attribute needs type";
    let attrNameWarning="Entity attribute needs name";
    let entityNameWarning="Entity needs name";
    let entityFirstChar="Entity name must start with a capital letter";
    
    let capLets=["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"] as Array<Character>;
    let lowLets=["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"] as Array<Character>;
    
    //Mark: Core data
    var context:NSManagedObjectContext?;
    
    var pickerTest=["Undefined","Integer 16","Integer 32","Integer 64","Decimal","Double","Float","String","Boolean","Date","Binary Data","Transformable"];
    
    // vert will be assigned before we segue to this view
    var vert:Vert?;
    // attrsOrNil an array holding AttributeString managed objects
    var attrsOrNil:Array<Attribute>?;
    var relsOrNil:Array<Edge>?;
    // an array holding each of the string properties of attrsOrNil

    let entityTable:UITableView?=UITableView();
    var titleField:UITextField?;
    let titleHeight:CGFloat=48;
    
    // validates entity name in the model
    private func validateEntityNameWithAlert()->Bool {
        if vert!.title == "" {
            invalidInput(entityNameWarning, title:"Invalid Entity Name");
            return false;
        }
        else if !firstCharacterIsCapital(vert!.title!) {
            invalidInput(entityFirstChar, title:"Invalid Entity Name");
            return false;
        }
        return true;
    }
    
    // validates user input for the entity name
    private func validateEntityNameInputWithAlert(name:String)->Bool {
        if name == "" {
            invalidInput(entityNameWarning, title:"Invalid Entity Name");
            return false;
        }
        else if !firstCharacterIsCapital(name) {
            invalidInput(entityFirstChar, title:"Invalid Entity Name");
            return false;
        }
        return true;
    }
    
    // checks if the first character of the string is a capital letter
    private func firstCharacterIsCapital(str:String)->Bool {
        let firstChar=str[str.startIndex];
        if lowLets.indexOf(firstChar) != nil {
            return false;
        }
        return true;
    }
    
    // displays and invalid input warning
    func invalidInput(warning:String, title:String) {
        let alert = UIAlertController(title: title, message: warning, preferredStyle: .Alert);
        let alertAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil);
        alert.addAction(alertAction);
        presentViewController(alert, animated: false, completion:nil);
    }
    
    //MARK: kvo
    //kvo is used to support changes in attributes.
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [NSObject: AnyObject]?, context: UnsafeMutablePointer<Void>) {

        if object is Vert {
            let v = object as! Vert;
            if titleField == nil {print("AttributeTable: observeValueForKeyPath: title field is nil");}
            if keyPath=="title" {
                titleField!.text = v.title
            }
        }
        else if object is Attribute {
            var att = object as! Attribute;
            
            if keyPath == "name" || keyPath == "type" {
                // get list and re-sort it
                getSortedAttributes();
            }
            else {
                print("AttributeTable: observeValueForKeyPath: unregonized key path for object vert");
            }
        }
        else if object is Edge {
            var edge = object as! Edge;
            
            if keyPath == "rel1name" {
            
            }
            else if keyPath == "rel2name" {
            
            }
            else if keyPath == "vertChange" {
            
            }
        }
    }
    
    //MARK: view lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad();

        // set numbe of attributes and edges
        getSortedAttributes();
        getSortedRels();
        for obj in vert!.edges! {
            (obj as! Edge).addObserver(self, forKeyPath: "name", options: .New, context: nil);
        }
        
        //register for keyboard notifications
        NSNotificationCenter.defaultCenter().addObserver(self,selector:"keyboardWasShown:", name:UIKeyboardDidShowNotification, object:nil);
        NSNotificationCenter.defaultCenter().addObserver(self,selector:"keyboardWillBeHidden:", name:UIKeyboardWillHideNotification, object:nil);
        
        view.backgroundColor = UIColor.grayColor();
        if vert == nil {print("AttributeTable: viewWillAppear: err vert is nil");}
        
        titleField = UITextField(frame: CGRectMake( CGFloat(0), CGFloat(20+44), view.frame.width, titleHeight ));
        if titleField == nil {print("AttributeTable: viewWillAppear: err titleField is nil");}
        
        view.addSubview(titleField!);
        titleField!.backgroundColor=UIColor.blueColor();
        setTextField(titleField!, placeholder:"Add title");
        
        // if there's text in vert title then override placeholder text
        if !vert!.title!.isEmpty {
            titleField!.text = vert!.title;
        }
        
        // create the table view
        //entityTable!.frame = CGRectMake(CGFloat(0),CGFloat(20+44)+titleHeight,view.frame.width,view.frame.height-CGFloat(titleHeight));
        entityTable!.frame = CGRectMake(CGFloat(0),CGFloat(20+44)+titleHeight,view.frame.width,162*3);
        (entityTable!.dataSource, entityTable!.delegate) = (self, self);
        entityTable!.allowsSelection=true;
        // register class will allow new cells to be initialized properly at launch
        // an incorrect class name will cause cells to not be shown at launch
        entityTable!.registerClass(AttributeCell.self, forCellReuseIdentifier:"AttributeCell");
        entityTable!.registerClass(RelationshipCell.self, forCellReuseIdentifier:"RelationshipCell");
        entityTable!.registerClass(UITableViewCell.self, forCellReuseIdentifier:"Cell");
        entityTable!.reloadData();
        view.addSubview(entityTable!);
        
        // observes keyboard dismissal in case any error
        let noteCenter:NSNotificationCenter = NSNotificationCenter.defaultCenter();
        let mainQueue:NSOperationQueue=NSOperationQueue.mainQueue();
        noteCenter.addObserverForName( UIKeyboardWillHideNotification, object: nil, queue: mainQueue, usingBlock:
        {(notification:NSNotification!) -> Void in
        
            if self.attrNameDidNotStartWithCaptial {
                let alert = UIAlertController(title: "Invalid Name", message: "Attribute names must start with a capital letter", preferredStyle: .Alert);
                let alertAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil);
                alert.addAction(alertAction);
                self.presentViewController(alert, animated: false, completion:
                {() -> Void in
                    // reset the showAttrErr flag
                    self.attrNameDidNotStartWithCaptial=false;
                });
            }
        });
        
        noteCenter.addObserverForName( UIKeyboardWillHideNotification, object: nil, queue: mainQueue, usingBlock:
        {(notification:NSNotification!) -> Void in
        
            if self.attrAlreadyExists {
                let alert = UIAlertController(title: "Attribute Exists", message: "Cannot add an attribute with the same name as an already existing attribute", preferredStyle: .Alert);
                let alertAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil);
                alert.addAction(alertAction);
                self.presentViewController(alert, animated: false, completion:
                {() -> Void in
                    // reset the showAttrErr flag
                    self.attrAlreadyExists=false;
                });
            }
        });
    }
    
    //MARK: setup methods
    func getSortedAttributes() {
    
        // 1.get an unsorted array of attributes from the vert
        if vert == nil {print("EntityTableVC: getSortedAttributes: the vert is nil");}
        attrsOrNil=vert!.attributes!.allObjects as? Array<Attribute>;
        if attrsOrNil == nil {print("EntityTableVC: getSortedAttributes: the list of attributes is nil");}
        
        // 2.sort
        attrsOrNil = (attrsOrNil!).sort(sortAttributes);
        
        // 3.reload
        entityTable!.reloadData();
    }
    
    // the sorting method for attributes
    private func sortAttributes(a1:Attribute, a2:Attribute)->Bool {
        if a1.name < a2.name {
            return true;
        }
        return false;
    }
    
    func getSortedRels() {
    
        // 1.get an unsorted array of edges
        if vert == nil {print("EntityTableVC: getSortedRels: the vert is nil");}
        
        relsOrNil=vert!.edges!.allObjects as? Array<Edge>;
        if relsOrNil == nil {print("EntityTableVC: getSortedRels: the list of rels is nil");}
        
        // 2.sort
        relsOrNil = (relsOrNil!).sort(sortEdges);
        
        // 3.reload
        entityTable!.reloadData();
    }
    
    // the sorting method for attributes
    private func sortEdges(a1:Edge, a2:Edge)->Bool {
        return true;
        //TODO: 
        /*
        if a1.name < a2.name {
            return true;
        }
        return false;
        */
    }
    
    //MARK: model methods
    // use vert id to get a vert and add an attribute to it
    func addAttributeById(vertId:Int32, withString attrString:String) {
        // make attr
        let attrDescription = NSEntityDescription.entityForName("Attribute",inManagedObjectContext: context!);
        let attr:Attribute = Attribute(entity: attrDescription!,insertIntoManagedObjectContext: context);

        // set KVO on self
        attr.addObserver(self, forKeyPath: "name", options: .New, context: nil);
        attr.addObserver(self, forKeyPath: "type", options: .New, context: nil);
        
        // update vert
        if vert == nil {print("CoreController: addAttributeById: could not find vert to modify");}

        let manyRelation:AnyObject? = vert!.valueForKeyPath("attributes") ;
        if manyRelation is NSMutableSet {
            (manyRelation as! NSMutableSet).addObject(attr);
        }
        
        // set attr properties
        attr.name=attrString; // trigger KVO
        attr.type="Undefined";
    }
    
    // delegate method
    func setAttrName(attr:Attribute, name:String){
        attr.name = name;
    }
    
    // delegate method
    func setAttrType(attr:Attribute, type:String){
    
        attr.type = type;
    }
    
    //MARK: UITextFieldDelegate methods
    func textFieldShouldReturn(textField: UITextField)->Bool {
    
        textField.resignFirstResponder();
        if vert == nil {print("AttributeTable: testFieldShouldReturn: vert is nil");};
        
        // if the input is valid change the title of the vert
        // assumption here: the only textfields in AttributeTable not=attributeTextField is the title text field
        if navigationController == nil {print("AttributeTable: testFieldShouldReturn: nav controller is nil");}
        for vc in navigationController!.viewControllers {
            if vc is CoreController {
 
                if validateEntityNameInputWithAlert(textField.text!) {
                    (vc as! CoreController).setTitle(vert!.vertViewId, title: textField.text!);
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
    return 2;
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if attrsOrNil != nil {
                return attrsOrNil!.count+1;
            }
            else {
                print("EntityTableVC: number of rows in section: err trying to set number of rows but attrsOrNil is nil");
                return 0;
            }
        }
        else if section == 1 {
            if relsOrNil != nil {
                return relsOrNil!.count+1;
                
            }
            else {
                print("EntityTableVC: number of rows in section: err trying to set number of rows but relsOrNil is nil");
                return 0;
            }
        }
        else {
            print("EntityTableVC: numberOfRowsInSection: invalid number of sections");
            return 0;
        }
    }
    
    //MARK: table view helpers
    func inAttributesSection(indexPath:NSIndexPath)->Bool {
        if indexPath.row < self.tableView(entityTable!, numberOfRowsInSection: 0) {
            return true;
        }
        else {return false;}
    }
    
    func inRelationshipsSection(indexPath:NSIndexPath)->Bool {

        let m = self.tableView(entityTable!, numberOfRowsInSection: 0);
        let n = self.tableView(entityTable!, numberOfRowsInSection: 0) + self.tableView(entityTable!, numberOfRowsInSection: 1);

        // row must be greater than or equal to number rows in the first section, less than total number of rows
        if m <= indexPath.row && indexPath.row < n {
            return true;
        }
        else {return false;}
    }


    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
    
        if inAttributesSection(indexPath) {

            let cellIdentifier:String="AttributeCell";
            var cell:AttributeCell? = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as? AttributeCell
            if cell == nil {
                // init a custom cell
                cell = AttributeCell(style:UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier);
                
                if cell == nil {print("AttributeTable: tableView cellForRowAtIndexPath: failed to create cell");}
                
                // do any additional setup of the cell...
            }
            
            (cell!.picker!.delegate,cell!.picker!.dataSource) = (cell!,cell!);  //UIPickerView delegate and datasource
            cell!.attributesDelegate = self;                                    //CheckAttributes delegate
            cell!.vertViewId = vert!.vertViewId;

            // customize the cell based on its section

            setAttributeCell(indexPath, cell: cell!);
            return cell!;
        }
        else if inRelationshipsSection(indexPath) {
        
            let cellIdentifier:String="RelationshipCell";
            
            var cell:RelationshipCell? = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as? RelationshipCell
            if cell == nil {
                // init a custom cell
                cell = RelationshipCell(style:UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier);
                if cell == nil {print("RelationshipTable: tableView cellForRowAtIndexPath: failed to create cell");}
            }
            
            (cell!.picker!.delegate,cell!.picker!.dataSource) = (cell!,cell!);  //UIPickerView delegate and datasource

            // customize the cell based on its section
            setRelationshipCell(indexPath, cell: cell!);
            
            return cell!;
        }
        else {
            print("EntityTable: tableView cellForRowAtIndexPath: invalid section");
            
            return tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell;
        }
    }
    
    // setAttributeCell() does the setup for a table view cell in the attributes section. 
    // Assumes that the indexPath row its given is in the right section
    func setAttributeCell(indexPath: NSIndexPath, cell:AttributeCell) {
        
        // set the text showing the attribute name
        // assumption: attrsOrNil!.count+1 = length of attributes section
        if indexPath.row < attrsOrNil!.count
        {
            // if a cell is not flagged with doesCreateNewCell then changing the textField makes a change to an existing attribute
            cell.doesCreateNewCell = false;
            
            //set the text of the cell textfield
            cell.descriptionLabel!.text=attrsOrNil![indexPath.row].name;
        
            cell.attr=attrsOrNil![indexPath.row];
            
            let ind = pickerTest.indexOf(cell.attr!.type!);
            if ind != nil {
            
                cell.picker!.selectRow(ind!, inComponent: 0, animated: false);
            }
        }
        else {
            cell.doesCreateNewCell = true;
            // the last cell in the attribute section invites creating a new cell
            cell.descriptionLabel!.placeholder=cell.addAttrFieldPlaceholderText;
        }
    
    }
    
    // setRelationshipCell() does the setup for a table view cell in the attributes section.
    // Assumes that the indexPath row its given is in the right section
    func setRelationshipCell(indexPath: NSIndexPath, cell:RelationshipCell) {
        // set the text showing the attribute name
        // assumption: attrsOrNil!.count+1 = length of attributes section
        if indexPath.row < relsOrNil!.count
        {
            // if a cell is not !doesCreateNewCell then changes to textFields modify existing attribute
            cell.doesCreateNewCell = false;
            
            print("setRelationshipCell: relationship/edge is \(relsOrNil![indexPath.row]) ");
            print("setRelationshipCell: vert is \(vert!) ");
            
            cell.descriptionLabel!.text = relsOrNil![indexPath.row].getNameForVert(vert!);
            cell.edge = relsOrNil![indexPath.row];
            
            cell.relationshipDelegate = self;
        
            for obj in vert!.neighbors! {
                cell.destinations.append((obj as! Vert).title!);
            }
        }
        else {
            cell.doesCreateNewCell = true;
            // the last cell in the attribute section invites creating a new cell
            cell.descriptionLabel!.placeholder = cell.addRelFieldPlaceholderText ;
        }
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

    private func setTextField(textField:UITextField, placeholder:String) {
        textField.adjustsFontSizeToFitWidth = true;
        textField.textColor = UIColor.blackColor();
        textField.placeholder = placeholder;
        textField.keyboardType = UIKeyboardType.EmailAddress;
        textField.delegate = self;
    }
    
    //MARK: attr name validation
    // default contains function is not working in Swift 1.2
    private func contains(arr:Array<Attribute>, str:String)->Bool {
        for elem in arr {
            if elem.name == str {
                return true;
            }
        }
        return false;
    }
    private func validateNameNotExists(str:String)->Bool {
        if contains(attrsOrNil!, str:str) {
            attrAlreadyExists=true;
            return false;
        }
        return true;
    }
    
    private func validateFirstChar(str:String)->Bool {
        if !firstCharacterIsCapital(str) {
            attrNameDidNotStartWithCaptial=true;
            return false;
        }
        return true;
    }
    
    // validateAttrName() validates input and sets flags for displaying an alert if the input is bad
    func validateAttrName(str:String)->Bool {
        // if any of the tests is false then return false
        if !validateFirstChar(str) || !validateNameNotExists(str) {
            return false;
        }
        return true;
    }
    
    // following listing 5-1 in https://developer.apple.com/library/ios/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html
    var activeField:UITextField?;
        
    //MARK: keyboard methods
    // Called when the UIKeyboardDidShowNotification is sent.
    func keyboardWasShown(aNotification:NSNotification) {
    
        if shouldMove == nil {print("EntityTableVC: keyboardWasShown: shouldMove is nil");}
        if shouldMove! {
            let info:NSDictionary = aNotification.userInfo!;
            // from http://stackoverflow.com/questions/25856003/swift-moving-content-behind-keyboard-doesnt-reset-after-dismiss
            let kbSize:CGSize = (info.valueForKey(UIKeyboardFrameBeginUserInfoKey) as! NSValue).CGRectValue().size;
         
            //TODO: remove magic number
            let magicNumber:CGFloat=20;
            let contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height+magicNumber, 0.0);
            
            entityTable!.contentInset = contentInsets;
            entityTable!.scrollIndicatorInsets = contentInsets;
         
            // If active text field is hidden by keyboard, scroll it so it's visible
            // Your app might not need or want this behavior.
            var aRect = self.view.frame;
            aRect.size.height -= kbSize.height;
            
            if !CGRectContainsPoint(aRect, activeField!.frame.origin) {
                entityTable!.scrollRectToVisible(activeField!.frame, animated:true);
            }
            shouldMove = false;
        }
    }
    
    // Called when the UIKeyboardWillHideNotification is sent
    func keyboardWillBeHidden(aNotification:NSNotification) {
    
        let contentInsets = UIEdgeInsetsZero;
        entityTable!.contentInset = contentInsets;
        entityTable!.scrollIndicatorInsets = contentInsets;
    }
    
    
}