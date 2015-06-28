//
//  Graph.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-06-28.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

import Foundation
import CoreData

class Graph: NSManagedObject {

    @NSManaged var curEdgeId: Int32
    @NSManaged var curVertId: Int32
    @NSManaged var edges: NSSet
    @NSManaged var verts: NSSet

}
