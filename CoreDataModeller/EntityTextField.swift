//
//  EntityTextField.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-07-05.
//  Copyright © 2015 David Marquis. All rights reserved.
//

import UIKit

class EntityTextField: UITextField {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds,10,0);
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 10, 0);
    }

}
