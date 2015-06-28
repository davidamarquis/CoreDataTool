//
//  ObjCEntityMGen.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-06-25.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

import UIKit

class ObjCEntityMGen: NSObject {

    let username:String = "David Marquis";
    var entityM:String=String();
    
    var comment:Array<String> = Array<String>();
    var vert:Vert?;
    
    //placeholders
    var title="Data Fun!";
    var date="";
    var year="";
    var entityName="Test"
    
    let useScalarTypes=true;

    func setupArrays() {
        comment = ["//","//  \(entityName).m","//  \(title)","//","//  Created by \(username) on \(date).","//  Copyright (c) \(year) \(username). All rights reserved.","//","","#import <CoreData/CoreData.h>","","@interface \(entityName) : NSManagedObject",""];
        // any custom class names should be put at the start of this array
    }
    
    func updateString() {
        year = CurDate().getYearString();
        date = CurDate().getDateString();
        // set any strings that need to be inserted into the array
    
        setupArrays();
        if vert == nil {println("AttributeTableVC: udpdateString: vert is nil ");}
        
        for str in comment{
            entityM += str+"\n";
        }
        for obj in vert!.attributes {
            let attr=(obj as! Attribute);
            
            entityM += "@dynamic \(attr.name);\n";
        }
        entityM += "\n";
        entityM += "@end\n";
    }
}
