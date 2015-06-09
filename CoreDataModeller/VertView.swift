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
}

class VertView: UIView {

    // MARK: VARS
    var bz:UIBezierPath = UIBezierPath();
    var selected:Bool;
    var x:CGFloat;
    var y:CGFloat;
    var positionBeforePan:CGPoint;
    // set by other classes
    var circSize:CGFloat?;
    var strokeSize:CGFloat?;

    // reference to an object that obeys the VertViewWasTouchedProtocol
    var delegate:VertViewWasTouchedProtocol?;
    var vertViewId:Int32;
    weak var parentController:CoreController?;

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
        addGestureRecognizer(UIPanGestureRecognizer(target:self, action:"pan:" ));
        setNeedsDisplay();
    }

    required init(coder aDecoder: NSCoder) {
        // step 1:
        selected=false;
        x=frame.origin.x ;
        y=frame.origin.y ;
        // step 2:
        super.init(coder: aDecoder);
        // step 3:
        opaque=false;
        addGestureRecognizer(UIPanGestureRecognizer(target:self, action:"pan:" ));
        setNeedsDisplay();
    }

    // MARK: methods
    func pan(recognizer:UIPanGestureRecognizer) {
        let translation:CGPoint=recognizer.translationInView(self);
        
        // smooth panning requires handling StateBegan and StateChanged
        if(recognizer.state==UIGestureRecognizerState.Began) {
            positionBeforePan=frame.origin;
        }
        
        else if(recognizer.state == UIGestureRecognizerState.Changed ) {
            //CGPoint endPos=CGPointMake(self.frame.origin.x+translation.x,self.center+translation.y);
            center=CGPointMake(self.center.x+translation.x,self.center.y+translation.y);
            recognizer.setTranslation(CGPointMake(0,0), inView:recognizer.view);
        }
        else if(recognizer.state==UIGestureRecognizerState.Ended) {
            let endPos:CGPoint=frame.origin;
            if((delegate != nil) && (parentController != nil)) {
            
                // call the drawGraphAfterMovingVert method on the parent
                delegate!.drawGraphAfterMovingVert(vertViewId, toXPos: Float(endPos.x), toYPos: Float(endPos.y) );
            }
            // we do not detach the view yet from the superview yet. If we did that we would no longer have a strong reference to it that is needed by the VC
        }
    }

    override func drawRect(rect:CGRect) {
        // fill the rect
        let cont:CGContextRef = UIGraphicsGetCurrentContext();
        CGContextSaveGState(cont);
        CGContextSetRGBFillColor(cont, 0.0, 0.5, 0.5, 1.0);
        CGContextStrokeRect(cont, rect);
        // do the rest of the custom drawing
        drawPoint();
    }

    func drawPoint() {
        // when drawPoint has been called circSize and strokeSize have alreay been set

        //double circSize=((GraphWorldView*)self.superview).circSize;
        //double strokeSize=((GraphWorldView*)self.superview).strokeSize;
        // need to offset from the origin by the stroke size to ensure the bez is inside fully inside the frame
        bz=UIBezierPath(ovalInRect: CGRectMake(strokeSize, strokeSize, circSize, circSize ));
        // set fill property
        if selected {
            UIColor.greenColor().setFill();
        }
        else {
            UIColor.redColor().setFill();
        }
        // set stroke properties
        UIColor.blackColor().setStroke();
        bz.lineWidth = strokeSize;
        // stroke and fill
        bz.stroke();
        bz.fill();
    }

    // hit changes the selected property to its negation if cgp is within the BZ
    func updateIfHit(cgp:CGPoint)->Bool {

        let xorig:CGFloat=frame.origin.x;
        let yorig:CGFloat=frame.origin.y;
        
        let newCGP:CGPoint = CGPointMake(cgp.x-xorig,cgp.y-yorig);
        
        let pointWithin:Bool = bz.containsPoint(newCGP);
        
        if(!pointWithin && selected) {
            selected=false;
            return false;
        }
        // if there is a hit and the point is selected then unselect it
        else if(pointWithin && self.selected) {
            selected=false;
            // indicate that a selected point has been found
            return true;
        }
        // if there is a hit and the point is not selected then select it
        else if(pointWithin && !self.selected) {
            selected=true;
            // indicate that a selected point has been found
            return true;
        }
        // if there is not a hit return NO
        else if(!pointWithin && !self.selected) {
            return false;
        }
        else {
            print("VertView: updateIfHit: err");
            return false;
        }
        
    }
    func selected(sel:Bool) {
        selected=sel;
        setNeedsDisplay();
    }
    // switch selected changes the selected property to its negation
    func switchSelected() {
        selected = !selected;
        setNeedsDisplay();
    }

}
