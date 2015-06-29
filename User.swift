//
//  User.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-06-29.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

import Foundation
import CoreData

class User: NSManagedObject {

    @NSManaged var username: String
    @NSManaged var password: String
    @NSManaged var email: String

}
