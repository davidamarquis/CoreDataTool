//
//  PrintMethodsForCC.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-07-11.
//  Copyright © 2015 David Marquis. All rights reserved.
//

import UIKit

extension CoreController {

    //MARK: kvo debug methods
    func printDeletedVerts() {
        for elem in self.context!.deletedObjects {
            if elem is Vert {
                print("printDeletedVerts");
                if (elem as! Vert).gVertViewId() != nil {
                    print("deleted vert id \((elem as! Vert).gVertViewId()!) ");
                }
                return;
            }
        }
    }
    func printChangedVerts() {
        for elem in self.context!.updatedObjects {
            if elem is Vert  {
                print("CC: printChangedVerts");
                if (elem as! Vert).gVertViewId() != nil {
                    print("updated vert id \((elem as! Vert).gVertViewId()!) ");
                }
                return;
            }
        }
    }
}
