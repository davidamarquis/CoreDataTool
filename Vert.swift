//
//  Vert.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-05-30.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

import Foundation
import CoreData

class Vert: NSManagedObject {

    @NSManaged var depthSearchSeen: NSNumber
    @NSManaged var freshViews: NSNumber
    @NSManaged var finishedObservedMethod: NSNumber
    @NSManaged var freshEdges: NSNumber
    @NSManaged var parseObjId: String
    @NSManaged var vertViewId: NSNumber
    @NSManaged var x: NSNumber
    @NSManaged var y: NSNumber
    @NSManaged var edges: NSSet
    @NSManaged var graph: Graph
    @NSManaged var neighbors: NSSet

}
