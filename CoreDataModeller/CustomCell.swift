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

    override init(style:UITableViewCellStyle, reuseIdentifier:String?) {
        super.init(style: style, reuseIdentifier:reuseIdentifier);
        postInitSetup();
    }
    
    func postInitSetup() {
        // configure control(s)
        let descriptionLabel = UILabel(frame: CGRectMake(5, 10, 300, 30));
        descriptionLabel.textColor = UIColor.blackColor();
        descriptionLabel.font = UIFont(name:"Arial", size:12.0);

        addSubview(descriptionLabel);
    }
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder);
        postInitSetup();
    }
}
