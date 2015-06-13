//
//  File.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-05-30.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

import Foundation

extension NSSet {

    func setByRemovingObject(object:AnyObject)->NSSet {
        var newSet:NSMutableSet! ;
        var set:NSSet = NSSet() ;
        for x in self {
            if(x !== object) {
                newSet.addObject(x);
            }
        }
        set=NSSet.alloc();
        if let set = newSet.copy() as? NSSet {
            return set;
        }
        else {
            
        }
        return set;
    }

}