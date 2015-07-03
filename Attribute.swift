//
//  Attribute.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-07-01.
//  Copyright © 2015 David Marquis. All rights reserved.
//

import Foundation
import CoreData

@objc(Attribute)
class Attribute: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

    func gName()->String {
        let selfX:String? = valueForKeyPath("name") as? String;
        if selfX == nil {print("Attribute: gName: is nil");}
        return selfX!;
    }
    
    func gType()->String {
        let selfX:String? = valueForKeyPath("type") as? String;
        if selfX == nil {print("Attribute: gType: is nil");}
        return selfX!;
    }
    
    func gVertWithAttribute()->NSMutableArray {
        let selfX:NSMutableArray? = valueForKeyPath("type") as? NSMutableArray;
        if selfX == nil {print("Attribute: gVert: is nil");}
        return selfX!;
    }
    
}
