//
//  Edge.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-05-31.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

import Foundation
import CoreData

class Edge: NSManagedObject {

    @NSManaged var edgeViewId: Int32
    @NSManaged var parseObjectId: String
    @NSManaged var graph: Graph
    @NSManaged var joinedTo: NSSet

}
