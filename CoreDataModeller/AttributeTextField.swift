//
//  TableViewCell.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-06-20.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

import UIKit

class attributeTextField:UITextField {

    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds,10,0);
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 10, 0);
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        self.layer.borderWidth = CGFloat(1);
        self.layer.borderColor = UIColor(red: 1,green: 1, blue: 1, alpha: 1).CGColor;
        self.layer.cornerRadius = CGFloat(5);
        self.clearsOnBeginEditing = true;
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder);
    }
    
    override func layoutSubviews() {

    }
}
