//
//  EdgeView.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-06-01.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

import UIKit

class EdgeView: UIView {

    var topLeftToBotRight:Bool?;
    //TODO: clarify radius
    var radius:CGFloat?;
    var edgeViewId:Int32?;
    var bz:UIBezierPath = UIBezierPath();
    // length holds the length of the edge
    var length:CGFloat?;
    var angle:CGFloat?;
    let hitbox=UIView();
    let hbHeight=CGFloat(44);
    
    //MARK: init
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        opaque=false;
        addSubview(hitbox);
    }
    override init(frame:CGRect) {
        super.init(frame:frame);
        opaque=false;
        addSubview(hitbox);
    }
    
    //MARK: custom drawing
    override func drawRect(rect:CGRect) {
        /*
        let cont:CGContextRef = UIGraphicsGetCurrentContext();
        CGContextSaveGState(cont);
        CGContextSetRGBFillColor(cont, 1.0, 1.0, 0.0, 1.0);
        CGContextStrokeRect(cont, rect);
        */
        let wdth:CGFloat = bounds.size.width;
        let hght:CGFloat = bounds.size.height;
        var p1,p2:CGPoint?;

        UIColor.blackColor().setStroke();
        UIColor.blackColor().setFill();
        bz.lineWidth=CGFloat(5.0);

        // topLeftToBotRight is a description of the edge direction starting from the leftmost vert
        if topLeftToBotRight != nil {
            if topLeftToBotRight!==true {
                // handling a case like X1<X2 && Y1<Y2
                p1=CGPointMake(radius!,radius!);
                p2=CGPointMake(wdth-radius!,hght-radius!);
                if length != nil {
                    hitbox.frame=CGRectMake(p1!.x, p1!.y + hbHeight/2, CGFloat(length!), hbHeight);
                    // if the angle has been set then do a rotation
                    if angle != nil {
                        let cont:CGContextRef = UIGraphicsGetCurrentContext();
                        CGContextSaveGState(cont);
                        CGContextTranslateCTM(cont, p1!.x, p1!.y);
                        CGContextRotateCTM(cont, angle);
                        //hitbox.transform = CGAffineTransformMakeRotation(CGFloat(angle!));
                        CGContextRestoreGState(cont);
                    }
                }
            }
            else {
                // handling a case like X1<X2 && Y1>=Y2
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
    }

}
