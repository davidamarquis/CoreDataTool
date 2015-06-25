//
//  ObjCEntityHGen.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-06-24.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

import UIKit

class ObjCEntityHGen: NSObject {

    let username:String = "David Marquis";
    var entityH:String=String();
    
    var comment:Array<String> = Array<String>();
    var vert:Vert?;
    
    //placeholders
    var title="Data Fun!";
    var date="9999-99-99";
    var entityName="Test"
    
    let useScalarTypes=true;

    func setupArrays() {
        comment = ["//","//  \(entityName).h","//  \(title)","//","//  Created by \(username) on \(date).","//  Copyright (c) 2015 \(username). All rights reserved.","//","","#import <CoreData/CoreData.h>","","@interface \(entityName) : NSManagedObject",""];
        // any custom class names should be put at the start of this array
    }
    
    func updateString() {
    
        setupArrays();
        if vert == nil {println("AttributeTableVC: udpdateString: vert is nil ");}
        
        for str in comment{
            entityH += str+"\n";
        }
        
        for obj in vert!.attributes {
            let attr=(obj as! Attribute);
            
            if useScalarTypes {
            
                if attr.type == "Undefined" {
                    println("ObjCEntityHGen: updateString: type is undefined so email cannot be created");
                    // don't want to handle this case. Undefined type would result in a build error anyway
                }
                else if attr.type == "Integer 16" {
                    entityH += "@property (nonatomic) int16_t \(attr.name);\n";
                }
                else if attr.type == "Integer 32" {
                    entityH += "@property (nonatomic) int32_t \(attr.name);\n";
                }
                else if attr.type == "Integer 64" {
                    entityH += "@property (nonatomic) int64_t \(attr.name);\n";
                }
                else if attr.type == "Decimal" {
                    entityH += "@property (nonatomic, retain) NSDecimalNumber * \(attr.name);\n";
                }
                else if attr.type == "Double" {
                    entityH += "@property (nonatomic) double \(attr.name);\n";
                }
                else if attr.type == "Float" {
                    entityH += "@property (nonatomic) float \(attr.name);\n";
                }
                else if attr.type == "String" {
                    entityH += "@property (nonatomic, retain) NSString * \(attr.name);\n";
                }
                else if attr.type == "Boolean" {
                    entityH += "@property (nonatomic) BOOL \(attr.name);\n";
                }
                else if attr.type == "Date" {
                    entityH += "@property (nonatomic) NSTimeInterval \(attr.name);\n";
                }
                else if attr.type == "Binary Data" {
                    entityH += "@property (nonatomic, retain) NSData * \(attr.name);\n";
                }
                else if attr.type == "Transformable" {
                    entityH += "@property (nonatomic, retain) id \(attr.name);\n";
                }
                else {println("ObjCEntityHGen: updateString: vert has an attribute of unrecognized type");}
            }
            entityH += "\n";
            entityH += "@end\n";
        }
    }
}
