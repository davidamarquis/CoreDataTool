//
//  AttributeTable.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-06-11.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

import UIKit

class AttributeTable: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
    // this vert will be assigned before we segue to this view
    var vert:Vert?;
    // attrsOrNil an array holding AttributeString managed objects
    var attrsOrNil:Array<AttributeString>?;
    // an array holding each of the string properties of attrsOrNil
    var attrStringsOrNil:Array<String>?;
    
    //MARK: view lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        let tableView=UITableView();
        tableView.frame = CGRectMake(10,30,320,400);
        tableView.dataSource = self;
        tableView.delegate = self;
        //tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier:"AttributeCell");
        tableView.reloadData();
        view.addSubview(tableView);
    }
    override func viewWillAppear(animated: Bool) {
        attrsOrNil=vert?.attributeStrings.allObjects as? Array<AttributeString>;
        
        // init the array that will hold the strings
        attrStringsOrNil = Array<String>();
        if attrsOrNil != nil {
            for attr in attrsOrNil! {
                attrStringsOrNil!.append(attr.string);
            }
        }
        else {
            println("AttributeTable: viewWillAppear: no attributes found on the given vert");
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if attrsOrNil != nil {
            return attrsOrNil!.count;
        }
        else {
            return 0;
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cellIdentifier:String="AttributeCell";
        let cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as? UITableViewCell
        if cell == nil { println("AttributeTable: tableView cellForRowAtIndexPath: TODO create cell") ;}
        
        // config cell by extracting element from attrStrings at given row
        let elem:AnyObject = attrStringsOrNil![indexPath.row];
        if elem is String {
            cell!.textLabel!.text=elem as? String;
        }
        else {println("AttributeTable: tableView cellForRowAtIndexPath: elem stored in attribute.string is not a string");}

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
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
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
