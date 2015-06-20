//
//  AttributeTable.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-06-11.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

import UIKit

class AttributeTable: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
  
    // vert will be assigned before we segue to this view
    //TODO: release this vert when view disappears
    var vert:Vert?;
    // attrsOrNil an array holding AttributeString managed objects
    var attrsOrNil:Array<AttributeString>?;
    // an array holding each of the string properties of attrsOrNil
    var attrStringsOrNil:Array<String>?;
    
    let attrView:UITableView?=UITableView();
    
    //MARK: view lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        attrView!.frame = CGRectMake(10,30,320,400);
        attrView!.dataSource = self;
        attrView!.delegate = self;
        attrView!.registerClass(UITableViewCell.self, forCellReuseIdentifier:"AttributeCell");
        attrView!.reloadData();
        view.addSubview(attrView!);
    }
    override func viewWillAppear(animated: Bool) {
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
    
    //MARK: UITextFieldDelegate methods
    func textFieldShouldReturn(textField: UITextField)->Bool {
        textField.resignFirstResponder();
        
        if vert == nil {println("AttributeTable: testFieldShouldReturn: vert is nil");};
        if navigationController == nil {println("AttributeTable: testFieldShouldReturn: nav controller is nil");}
        for vc in navigationController!.viewControllers {
            if vc is CoreController {
                (vc as! CoreController).addAttributeById(vert!.vertViewId, withString: textField.text);
            }
        }
        return true;
    }
    
    //MARK: table view data source
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

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cellIdentifier:String="AttributeCell";
        var cell:CustomCell? = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as? CustomCell
        if cell == nil {
            cell = CustomCell(style:UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier);
            println("AttributeTable: tableView cellForRowAtIndexPath: TODO create cell") ;
        }
        
        // config cell by extracting element from attrStrings at given row
        if indexPath.row < attrsOrNil!.count {
            let elem:AnyObject = attrStringsOrNil![indexPath.row];
            if elem is String {
                cell!.textLabel!.text=elem as? String;
            }
            else {println("AttributeTable: tableView cellForRowAtIndexPath: elem stored in attribute.string is not a string");}
        }
        else {
            // init a UITextField
            let textField:UITextField  = UITextField(frame: CGRectMake(110, 10, 185, 30) );
            // config the textfield
            textField.adjustsFontSizeToFitWidth = true;
            textField.textColor = UIColor.blackColor();
            textField.placeholder = "Add attribute";
            textField.keyboardType = UIKeyboardType.EmailAddress;
            //TODO: missing return key type
            textField.backgroundColor=UIColor.clearColor();
            textField.delegate = self;
            
            cell!.contentView.addSubview(textField);
        }
        return cell!
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */
    /*
    // Override to support editing the table view.
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
