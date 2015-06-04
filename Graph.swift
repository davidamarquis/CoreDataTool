//
//  Graph.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-05-31.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

import Foundation
import CoreData

@objc(Graph) class Graph: NSManagedObject {

    @NSManaged var edges: NSSet
    @NSManaged var verts: NSSet

}
