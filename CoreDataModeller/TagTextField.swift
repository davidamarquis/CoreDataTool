//
//  TagTextField.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-06-29.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

import UIKit

// the reason for this class is that it is necessary to refer to existing text fields. There is a tag property in the View class but it is an int.
class TagTextField: UITextField {

    var fieldTag:String? = nil;

}
