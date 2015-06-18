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
    
    let numberOfHitboxes = 5;
    var scaleOfBox:CGFloat?;
    
    //MARK: init
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        setupEdgeView();
    }
    override init(frame:CGRect) {
        super.init(frame:frame);
        setupEdgeView();
    }
    func setupEdgeView() {
        opaque=false;
        addSubview(hitbox);
        var i=0;
        for (i=0; i<numberOfHitboxes; i++) {
            let subview:UIView=UIView();
            hitbox.addSubview(subview);
        }
        
        let numBox = CGFloat(numberOfHitboxes);
        scaleOfBox = 1/numBox;
    }
    
    //MARK: custom drawing
    override func drawRect(rect:CGRect) {
    
        // reset any global variables containing bezier paths
        bz=UIBezierPath();
        
        let cont:CGContextRef = UIGraphicsGetCurrentContext();
        CGContextSaveGState(cont);
        CGContextSetRGBFillColor(cont, 1.0, 1.0, 0.0, 1.0);
        //CGContextStrokeRect(cont, rect);
        
        let wdth:CGFloat = bounds.size.width;
        let hght:CGFloat = bounds.size.height;
        var p1,p2:CGPoint?;

        UIColor.blackColor().setStroke();
        UIColor.blackColor().setFill();
        bz.lineWidth=CGFloat(5.0);

        // topLeftToBotRight is a description of the edge direction starting from the leftmost vert
        if topLeftToBotRight != nil {
            
            if topLeftToBotRight! == true {
                // handling a case like X1<X2 && Y1<Y2
                p1=CGPointMake(radius!,radius!);
                p2=CGPointMake(wdth-radius!,hght-radius!);
                
                //(1) set hitbox frame
                //hitbox.frame=CGRectMake(0,0, scaleOfBox!*frame.width, scaleOfBox!*frame.height);
                //(2) set subhitbox frames
                hitbox.frame=CGRectMake(0,0,0,0);
                for var i=0; i<self.numberOfHitboxes; i++ {
                
                    //println("ev: drawRect: printing \(numberOfHitboxes) views");
                    let xOrg = scaleOfBox!*CGFloat(i)*frame.width;
                    let yOrg = scaleOfBox!*CGFloat(i)*frame.height;
                    (hitbox.subviews[i] as! UIView).frame = CGRectMake(xOrg, yOrg, scaleOfBox!*frame.width, scaleOfBox!*frame.height);
                }
            
            }
            else {
                // handling a case like X1<X2 && Y1>=Y2
                p1=CGPointMake( radius!, hght-radius!);
                p2=CGPointMake(wdth-radius!, radius!);
                
                let hght:CGFloat = self.frame.height;
                
                //(1) set hitbox frame
                //hitbox.frame=CGRectMake(0,hght-scaleOfBox!*frame.height,scaleOfBox!*frame.width, scaleOfBox!*frame.height);
                //(2) set subhitbox frames
                hitbox.frame=CGRectMake(0,hght-scaleOfBox!*frame.height,0,0);
                for var i=0; i<self.numberOfHitboxes; i++ {
                    let xOrg = scaleOfBox!*CGFloat(i)*frame.width;
                    let yOrg = scaleOfBox!*CGFloat(i)*frame.height
                    // x and y position displacement are relative to the parent view's position
                    (hitbox.subviews[i] as! UIView).frame = CGRectMake(xOrg, -yOrg, scaleOfBox!*frame.width, scaleOfBox!*frame.height);
                }
                
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
