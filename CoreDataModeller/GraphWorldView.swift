//
//  GraphWorldView.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-06-01.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

import UIKit

class GraphWorldView: UIView {

// MARK: vars
var circSize:CGFloat = 50;
var edgeSize:CGFloat = 10;
var strokeSize:CGFloat = 5;
var x1:Double = 0;
var x2:Double = 0;
var y1:Double = 0;
var y2:Double = 0;
var radius:CGFloat {return (self.circSize+self.edgeSize)/2; }
var diameter:CGFloat {return (self.circSize+self.edgeSize); }

// MARK: init
override init(frame: CGRect) {
    // step1: set non-inherited properties
    
    // step 2: delegate to superclass
    super.init(frame: frame);
    
    // make the graph recognize taps
    let recog = UITapGestureRecognizer(target:self, action:"tap:");
    // step 3: set inherited properties
    self.backgroundColor=UIColor.whiteColor();
    addGestureRecognizer(recog);
}

required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder);
}

// MARK: methods
func removeSubviews() {
    for s in subviews {
        s.removeFromSuperview();
    }
}

func tap(recognizer:UITapGestureRecognizer) {

    let cgp:CGPoint=recognizer.locationInView(self);
    let N:Int=subviews.count;
    var i:Int=0;
    
    for(i=0;i<N;i++) {
    
        if(subviews[i] is VertView) {
            let cur:VertView = subviews[i] as! VertView;
            // do a hit test on the vert
            // ok so need to know
            if( cur.updateIfHit(cgp) ) {
                break;
            }
        }
    }
    if(i+1==N) {
        return;
    }
    else {
        i=i+1;
        for( ;i<N;i++) {
            if(subviews[i] is VertView) {
                let cur:VertView=subviews[i] as! VertView;
                if(cur.selected) {
                    cur.selected=false;
                }
            }
        }
    }
}

func addVertAtPoint(cgp:CGPoint)->VertView {
    let diameter:CGFloat=circSize+edgeSize;

    let vert:VertView=VertView( frame: CGRectMake(cgp.x, cgp.y, diameter, diameter) );

    vert.circSize=circSize;
    vert.strokeSize=strokeSize;
    addSubview(vert);
    setNeedsDisplay();
    return vert;
}

func addEdgeWithFrame(frame:CGRect, edgeDirectionCase:Int) {
    let ev:EdgeView=EdgeView(frame: frame);
    ev.directionCase=edgeDirectionCase;
    // fill in the radius
    ev.radius=self.radius;
    addSubview(ev);
    sendSubviewToBack(ev);
}

// public
// return the VertView corresponding to a particular id
// or nil if such a VertView does not exist
func getVertViewById(vertViewId:Int32) -> VertView? {

    for subview in subviews {
        if subview is VertView {
            let vertView:VertView=subview as! VertView;
            if(vertView.vertViewId == vertViewId) {return vertView;}
        }
    }
    return nil;
}

}
