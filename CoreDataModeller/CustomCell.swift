//
//  CustomCellTableViewCell.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-06-20.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

import UIKit
import Foundation

class CustomCell: UITableViewCell {

    var descriptionLabel:UILabel?;
    // pickerView's delegate is AttributeTable
    var picker:UIPickerView?;

    override init(style:UITableViewCellStyle, reuseIdentifier:String?) {
        super.init(style: style, reuseIdentifier:reuseIdentifier);
        postInitSetup();
    }
    
    func postInitSetup() {
        // configure control(s)
        descriptionLabel = UILabel(frame: CGRectMake(0, 0, 60, 25));
        descriptionLabel!.textColor = UIColor.blackColor();
        descriptionLabel!.font = UIFont(name:"Arial", size:12.0);

        contentView.addSubview(descriptionLabel!);
        
        picker=UIPickerView();
        if picker == nil {println("CustomCell: postInitSetup: picker is nil");}
        picker!.frame = CGRectMake(160,0,140,self.frame.height);
        contentView.addSubview(picker!);
    }
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder);
        postInitSetup();
    }
}
