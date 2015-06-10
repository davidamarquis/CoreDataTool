//
//  EdgeView.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-06-01.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

import UIKit

class EdgeView: UIView {

    //MARK: init
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        opaque=false;
    }
    override init(frame:CGRect) {
        super.init(frame:frame);
        opaque=false;
    }
    // directionCase options are 0 or 1
    var topLeftToBotRight:Bool?;
    var radius:CGFloat?;
    var edgeViewId:Int32?;
    
    //MARK: custom drawing
    override func drawRect(rect:CGRect) {

        let cont:CGContextRef = UIGraphicsGetCurrentContext();
        CGContextSaveGState(cont);
        CGContextSetRGBFillColor(cont, 1.0, 1.0, 0.0, 1.0);
        CGContextStrokeRect(cont, rect);
        
        let wdth:CGFloat = bounds.size.width;
        let hght:CGFloat = bounds.size.height;
     
        let bz:UIBezierPath=UIBezierPath();
        
        var p1,p2:CGPoint?;

        UIColor.blackColor().setStroke();
        UIColor.blackColor().setFill();
        bz.lineWidth=CGFloat(5.0);

        if topLeftToBotRight != nil {
            if topLeftToBotRight!==true {
                // handling a case like X1<X2 && Y1<Y2
                p1=CGPointMake(radius!,radius!);
                p2=CGPointMake(wdth-radius!,hght-radius!);
            }
            else {
                // handling a case like X1<X2 && Y1>=Y2
                //
                p1=CGPointMake( radius!, hght-radius!);
                p2=CGPointMake(wdth-radius!, radius!);
            }
        }
        else {
            println("EdgeView: drawRect: err");
        }
        bz.moveToPoint(p1!);
        bz.addLineToPoint(p2!);
        bz.stroke();
        bz.fill();
        
        CGContextRestoreGState(cont);
    }

}
