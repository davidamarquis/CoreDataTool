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

    // MARK: inits
    override init(frame:CGRect) {
        
        // step 1:
        selected=false;
        x=frame.origin.x ;
        y=frame.origin.y ;
        // step 2:
        super.init(frame: frame);
        postInit();
    }

    required init(coder aDecoder: NSCoder) {
        // step 1:
        selected=false;
        x=0 ;
        y=0 ;
        // step 2:
        super.init(coder: aDecoder);
        postInit();
    }
    
    func postInit() {
        opaque=false;
        addGestureRecognizer(UITapGestureRecognizer(target:self, action:"tap:" ));
    }

    // MARK: methods
    override func drawRect(rect:CGRect) {
        // fill the rect
        let cont:CGContextRef = UIGraphicsGetCurrentContext();
        CGContextSaveGState(cont);
        CGContextSetRGBFillColor(cont, 0.0, 0.5, 0.5, 1.0);
        //CGContextStrokeRect(cont, rect);
        // do the rest of the custom drawing
        drawPoint();
    }

    // drawPoint is called by drawRect
    func drawPoint() {
        // when drawPoint has been called circSize and strokeSize have alreay been set

        //double circSize=((GraphWorldView*)self.superview).circSize;
        //double strokeSize=((GraphWorldView*)self.superview).strokeSize;
        // need to offset from the origin by the stroke size to ensure the bez is inside fully inside the frame
        bz=UIBezierPath(ovalInRect: CGRectMake(strokeSize!, strokeSize!, circSize!, circSize! ));
        // set fill property
        if selected {
            UIColor.greenColor().setFill();
        }
        else {
            UIColor.redColor().setFill();
        }
        // set stroke properties
        UIColor.blackColor().setStroke();
        bz.lineWidth = strokeSize!;
        // stroke and fill
        bz.stroke();
        bz.fill();
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
