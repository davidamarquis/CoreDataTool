//
//  VertView.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-06-01.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

import UIKit

protocol VertViewWasTouchedProtocol {
    func drawGraphAfterMovingVert(viewId:Int32, toXPos endX:Float, toYPos endY:Float);
    func performSegueWithIdentifier(identifier: String?, sender: AnyObject?);
    var inEdgeMode:Bool {get};
    var inVertMode:Bool {get};
    var inMoveMode:Bool {get};
    func curMode()->Int;
    
    func remVertById(vertId:Int32);
    func addEdgeById(vertId1:Int32, vertId2:Int32);
    func remEdgeById(edgeId:Int32);
    func addVertById();
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
        
        // step 3:
        opaque=false;
        //addGestureRecognizer(UIPanGestureRecognizer(target:self, action:"pan:" ));
        setNeedsDisplay();
    }

    required init(coder aDecoder: NSCoder) {
        // step 1:
        selected=false;
        x=0 ;
        y=0 ;
        // step 2:
        super.init(coder: aDecoder);
        // step 3:
        opaque=false;
        //addGestureRecognizer(UIPanGestureRecognizer(target:self, action:"pan:" ));
        setNeedsDisplay();
    }

    // MARK: methods
    override func drawRect(rect:CGRect) {
        // fill the rect
        let cont:CGContextRef = UIGraphicsGetCurrentContext();
        CGContextSaveGState(cont);
        CGContextSetRGBFillColor(cont, 0.0, 0.5, 0.5, 1.0);
        CGContextStrokeRect(cont, rect);
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
    
    func contains(cgp:CGPoint)->Bool {

        let xorig:CGFloat=frame.origin.x;
        let yorig:CGFloat=frame.origin.y;
        let newCGP:CGPoint = CGPointMake(cgp.x-xorig,cgp.y-yorig);
        let pointWithin:Bool = bz.containsPoint(newCGP);
        if pointWithin {
            return true;
        }
        return false;
    }

    // hit changes the selected property to its negation if cgp is within the BZ
    func updateIfHit(cgp:CGPoint)->Bool {

        let xorig:CGFloat=frame.origin.x;
        let yorig:CGFloat=frame.origin.y;
        let newCGP:CGPoint = CGPointMake(cgp.x-xorig,cgp.y-yorig);
        let pointWithin:Bool = bz.containsPoint(newCGP);
        
        // if hit then perform segue
        if pointWithin {
        
            if delegate != nil {
                delegate!.performSegueWithIdentifier("VertInfo", sender: self);
            }
            else {
            
            }
            if selected {
                selected = !selected;
                setNeedsDisplay();
                // indicate that a selected point has been found
                return true;
            }
            else {
            
                selected = !selected;
                setNeedsDisplay();
                // indicate that a selected point has been found
                return true;
            }
        }
        else {
            if selected {
                return false;
            }
            // if there is not a hit return
            else {
                return false;
            }
        }
    }

    // switch selected changes the selected property to its negation
    func switchSelected() {
        selected = !selected;
        setNeedsDisplay();
    }

}
