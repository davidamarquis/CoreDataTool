//
//  Vert.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-06-28.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

import Foundation
import CoreData

class Vert: NSManagedObject {

    @NSManaged var depthSearchSeen: Bool
    @NSManaged var finishedObservedMethod: Bool
    @NSManaged var parseObjId: String
    @NSManaged var shouldSyncEntityAttributes: Bool
    @NSManaged var title: String
    @NSManaged var vertViewId: Int32
    @NSManaged var x: Float
    @NSManaged var y: Float
    @NSManaged var freshViews: Bool
    @NSManaged var attributes: NSSet
    @NSManaged var edges: NSSet
    @NSManaged var graph: Graph
    @NSManaged var neighbors: NSSet

}
