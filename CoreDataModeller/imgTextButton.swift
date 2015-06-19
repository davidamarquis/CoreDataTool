//
//  imgTextButton.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-06-18.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

import Foundation
import UIKit

class imgTextButton: UIButton {

    
    
    override func layoutSubviews() {
        backgroundColor=UIColor.whiteColor();
        
        super.layoutSubviews();
        let topInset:CGFloat = 0.1*bounds.size.height;
        var imgFrame:CGRect?;
        
        if imageView != nil {
            imgFrame = self.imageView!.frame;
            imgFrame = CGRectMake((bounds.size.width - imgFrame!.size.width) / 2, topInset, imgFrame!.size.width, imgFrame!.size.height);
            imageView!.frame = imgFrame!;
        }
        
        if titleLabel != nil {
            var titleFrame:CGRect = self.titleLabel!.frame;
            //let topLabelInset:CGFloat = (bounds.size.height - titleFrame.size.height) / 2 + topInset;
            
            titleFrame = CGRectMake((bounds.size.width - titleFrame.size.width)/2, topInset + imgFrame!.size.height, titleFrame.size.width, titleFrame.size.height);
            titleLabel!.frame = titleFrame;
            
            setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal);
            titleLabel!.textColor=UIColor.blackColor();
            titleLabel!.font = UIFont.systemFontOfSize(13);
            titleLabel!.lineBreakMode = .ByTruncatingTail;
            
        }
    } 
}
