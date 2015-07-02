//
//  Vert+CoreDataProperties.swift
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

extension Vert {

    @NSManaged var depthSearchSeen: Bool
    @NSManaged var finishedObservedMethod: Bool
    @NSManaged var freshViews: Bool
    @NSManaged var parseObjId: String?
    @NSManaged var shouldSyncEntityAttributes: Bool
    @NSManaged var title: String?
    @NSManaged var vertViewId: Int32
    @NSManaged var x: Float
    @NSManaged var y: Float
    @NSManaged var attributes: NSSet?
    @NSManaged var edges: NSSet?
    @NSManaged var graph: Graph?
    @NSManaged var neighbors: NSSet?

}
