//
//  Attribute.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-06-24.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

import Foundation
import CoreData

class Attribute: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var type: String
    @NSManaged var vertWithAttribute: Vert

}
