//
//  Graph+CoreDataProperties.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-07-02.
//  Copyright © 2015 David Marquis. All rights reserved.
//
//  Delete this file and regenerate it using "Create NSManagedObject Subclass…"
//  to keep your implementation up to date with your model.
//

import Foundation
import CoreData

extension Graph {

    @NSManaged var curEdgeId: Int32
    @NSManaged var curVertId: Int32
    @NSManaged var edges: NSSet?
    @NSManaged var verts: NSSet?

}
