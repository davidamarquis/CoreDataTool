//
//  VertView.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-06-01.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

import UIKit

protocol VertViewWasTouchedProtocol {
    var inEdgeMode:Bool {get};
    var inVertMode:Bool {get};
    var inMoveMode:Bool {get};
    func drawGraphAfterMovingVert(viewId:Int32, toXPos endX:Float, toYPos endY:Float);
    func performSegueWithIdentifier(identifier: String?, sender: AnyObject?);
    func curMode()->Int;
}

class VertView: UIView {

    // MARK: VARS
    var bz:UIBezierPath = UIBezierPath();
    var selected:Bool = false;
    var x,y:CGFloat;
    // variables that are set after initialization
    var positionBeforePan:CGPoint?;
    var circSize,strokeSize:CGFloat?;
    var vertViewId:Int32?;
    // protocol delegates
    var delegate:VertViewWasTouchedProtocol?;
    
    var titleLabel:UILabel?;
    var isDrawn = false;

    // MARK: inits
    override init(frame:CGRect) {
        
        // step 1:
        selected=false;
        (x,y)=(frame.origin.x,frame.origin.y);
        // step 2:
        super.init(frame: frame);
        postInit();
    }

    required init(coder aDecoder: NSCoder) {
        // step 1:
        selected=false;
        (x,y)=(0,0);
        // step 2:
        super.init(coder: aDecoder);
        postInit();
    }
    
    func postInit() {
        opaque=false;
        addGestureRecognizer(UITapGestureRecognizer(target:self, action:"tap:" ));
        
        // configure label
        titleLabel = UILabel();
        if titleLabel == nil {println("VertView: postInit: titleLabel is nil");}
        addSubview(titleLabel!);
        
        titleLabel!.backgroundColor = UIColor.clearColor();
        titleLabel!.textColor = UIColor.blackColor();
    }

    // MARK: methods
    override func drawRect(rect:CGRect) {
        if !isDrawn {
            if strokeSize == nil || circSize == nil {println("VertView: drawRect: strokeSize or circSize is nil");}
            
            let diameter=circSize! + strokeSize!;
            
            bz=UIBezierPath(ovalInRect: CGRectMake(strokeSize!, strokeSize!, circSize!, circSize! ));
            UIColor.whiteColor().setFill();
            UIColor.blueColor().setStroke();
            bz.lineWidth = strokeSize!;
            bz.stroke();
            bz.fill();
            
            // label is as wide as circle and half as tall
            titleLabel!.frame.size = CGSizeMake(frame.width, frame.width/2);
            // center the label vertically
            titleLabel!.frame.origin = CGPointMake(0, frame.height/2 - titleLabel!.frame.height/2);
            titleLabel!.textAlignment = NSTextAlignment.Center;
            bringSubviewToFront(titleLabel!);
        }
        isDrawn=true;
    }
    
    // hit changes the selected property to its negation if cgp is within the BZ
    func tap(recognizer:UITapGestureRecognizer) {
        if delegate != nil {
            delegate!.performSegueWithIdentifier("VertInfo", sender: self);
        }
        else {
            println("VertView: tap: vv delegate is nil");
        }
    }
 
    // switch selected changes the selected property to its negation
    func switchSelected() {
        selected = !selected;
        setNeedsDisplay();
    }

}
