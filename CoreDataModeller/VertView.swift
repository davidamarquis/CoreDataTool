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
var circSize:CGFloat;
var strokeSize:CGFloat;
var positionBeforePan:CGPoint;

// reference to an object that obeys the VertViewWasTouchedProtocol
var delegate:VertViewWasTouchedProtocol?;
var vertViewId:Int32;
weak var parentController:CoreController?;

// MARK: inits
override init(frame:CGRect) {
    //self.backgroundColor=[UIColor whiteColor];
    opaque=false;
    // by default vert is not selected
    selected=false;
    x=frame.origin.x ;
    y=frame.origin.y ;
    
    addGestureRecognizer(UIPanGestureRecognizer(target:self, action:"pan:" ));
    setNeedsDisplay();

    super.init(frame: frame);
}

required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder);
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
            delegate!.drawGraphAfterMovingVert(vertViewId, toXPos: endPos.x as! Float, toYPos: endPos.y as! Float);
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
        bz=UIBezierPath bezierPathWithOvalInRect:CGRectMake(strokeSize, strokeSize, circSize, circSize));
        // set fill property
        if selected {
        
            UIColor.greenColor] setFill];
        }
        else {
        
            [[UIColor redColor] setFill];
        }
        // set stroke properties
        [[UIColor blackColor] setStroke];
        self.bz.lineWidth = self.strokeSize;
        // stroke and fill
        [self.bz stroke];
        [self.bz fill];
    
}

// hit changes the selected property to its negation if cgp is within the BZ
-(BOOL)updateIfHit:(CGPoint)cgp {

    double xorig=self.frame.origin.x;
    double yorig=self.frame.origin.y;
    
    CGPoint newCGP=CGPointMake(cgp.x-xorig,cgp.y-yorig);
    
    BOOL pointWithin=[self.bz containsPoint:newCGP];
    
    if(!pointWithin && self.selected) {
        [self selected:NO];
        return NO;
    }
    // if there is a hit and the point is selected then unselect it
    else if(pointWithin && self.selected) {
        [self selected:NO];
        // indicate that a selected point has been found
        return YES;
    }
    // if there is a hit and the point is not selected then select it
    else if(pointWithin && !self.selected) {
        [self selected:YES];
        // indicate that a selected point has been found
        return YES;
    }
    // if there is not a hit return NO
    else if(!pointWithin && !self.selected) {
        return NO;
    }
    else {
        NSLog(@"VertView: updateIfHit: err");
        return NO;
    }
    
}
-(void)selected:(BOOL)sel {
    self.selected=sel;
    [self setNeedsDisplay];
}
// switch selected changes the selected property to its negation
-(void)switchSelected {
    self.selected=!self.selected;
    [self setNeedsDisplay];
}

}
