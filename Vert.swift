//
//  Vert.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-05-31.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

import Foundation
import CoreData

class Vert: NSManagedObject {

    @NSManaged var depthSearchSeen: Bool
    @NSManaged var finishedObservedMethod: Bool
    @NSManaged var freshEdges: Bool
    @NSManaged var freshViews: Bool
    @NSManaged var parseObjId: String
    @NSManaged var vertViewId: Int32
    @NSManaged var x: Double
    @NSManaged var y: Double
    @NSManaged var edges: NSSet
    @NSManaged var graph: Graph
    @NSManaged var neighbors: NSSet

}