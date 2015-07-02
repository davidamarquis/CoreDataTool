//
//  Edge+CoreDataProperties.swift
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

extension Edge {

    @NSManaged var edgeViewId: Int32
    @NSManaged var freshView: Bool
    @NSManaged var parseObjectId: String?
    @NSManaged var rel1name: String?
    @NSManaged var rel2name: String?
    @NSManaged var vertChange: Bool
    @NSManaged var graph: Graph?
    @NSManaged var joinedTo: NSSet?

}
