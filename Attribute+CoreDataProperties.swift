//
//  Attribute+CoreDataProperties.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-07-03.
//  Copyright © 2015 David Marquis. All rights reserved.
//
//  Delete this file and regenerate it using "Create NSManagedObject Subclass…"
//  to keep your implementation up to date with your model.
//

import Foundation
import CoreData

extension Attribute {

    @NSManaged var name: String?
    @NSManaged var type: String?
    @NSManaged var vertWithAttribute: Vert?

}
