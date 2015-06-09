//
//  EdgeView.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-06-01.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

import UIKit

class EdgeView: UIView {

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        opaque=false;
    }
    override init(frame:CGRect) {
        super.init(frame:frame);
        opaque=false;
    }
    // directionCase options are 0 or 1
    var directionCase:Int?;
    var radius:CGFloat?;
    
    override func drawRect(rect:CGRect) {

        let cont:CGContextRef = UIGraphicsGetCurrentContext();
        CGContextSaveGState(cont);
        CGContextSetRGBFillColor(cont, 1.0, 1.0, 0.0, 1.0);
        CGContextStrokeRect(cont, rect);
        
        let wdth:CGFloat = self.bounds.size.width;
        let hght:CGFloat = self.bounds.size.height;
     
        let bz:UIBezierPath=UIBezierPath();
        
        var p1:CGPoint?;
        var p2:CGPoint?;
        
        UIColor.blackColor().setStroke();
        UIColor.blackColor().setFill();
        bz.lineWidth=CGFloat(5.0);

        // when drawRect is called self.radius has already been set by the superview
        if(self.directionCase==0) {
        //X1<X2 && Y1<Y2
            p1=CGPointMake(radius!,radius!);
            p2=CGPointMake(wdth-radius!,hght-radius!);
        }
        else if(self.directionCase==1) {
            //X1<X2 && Y1>=Y2
            p1=CGPointMake(radius!,hght-radius!);
            p2=CGPointMake(wdth-radius!,radius!);
        }
        else {
            print("EdgeView drawRect: err");
        }
        bz.moveToPoint(p1!);
        bz.addLineToPoint(p2!);
        bz.stroke();
        bz.fill();
        
        CGContextRestoreGState(cont);
    }

}
