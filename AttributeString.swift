//
//  AttributeString.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-06-20.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

import Foundation
import CoreData

class AttributeString: NSManagedObject {

    @NSManaged var string: String
    @NSManaged var vertWithAttribute: Vert

}
