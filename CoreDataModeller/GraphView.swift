//
//  GraphView.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-06-01.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

import UIKit

class GraphView: UIScrollView {

//
//  VertCircle.m
//  April25NotGoingWell
//
//  Created by David Marquis on 2015-04-26.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

    lazy var gwv:GraphWorldView = {
        // inside a block so we have to use self
            let sizeX:CGFloat = self.contentSize.width;
            let sizeY:CGFloat = self.contentSize.height;
            let worldRect:CGRect = CGRectMake(0,0,sizeX,sizeY);
            let worldView = init();
            worldView.frame=worldRect
            addSubview(worldView);
            return worldView;
    }()
    
    required init(coder aDecoder: NSCoder) {
        // set the content size first as all subclasses will need it
        self.contentSize=CGSizeMake(1000,1000);
        // self.backgroundColor may seem irrelevant as the view is covered by a GraphWorldView
        // This is wrong. There is no default color so nothing will be displayed
        self.backgroundColor=UIColor.whiteColor();
        self.opaque=false;
        super.init(coder: aDecoder);
    }

}
