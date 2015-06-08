//
//  GraphWorldView.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-06-01.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

import UIKit

class GraphWorldView: UIView {

override init(frame: CGRect) {
    self.backgroundColor=UIColor.whiteColor();
    self.circSize=50;
    self.edgeSize=10;
    self.strokeSize=5;
    // make the graph recognize taps
    let recog      = UITapGestureRecognizer(target:self, action:"tap:");
    addGestureRecognizer(recog);
    super.init(frame: frame);
}

required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder);
}

var circSize:Double;
var edgeSize:Double;
var strokeSize:Double;

func removeSubviews() {
    for s in subviews {
        s.removeFromSuperview();
    }
}

var radius:Double {return (self.circSize+self.edgeSize)/2; }
var diameter:Double {return (self.circSize+self.edgeSize); }

func tap(recognizer:UITapGestureRecognizer) {

    let cgp:CGPoint=recognizer.locationInView(self);
    let N:Int=subviews.count;
    var i:Int=0;
    
    for(i=0;i<N;i++) {
    
        if(subviews[i] is VertView) {
            let cur:VertView = subviews[i] as! VertView;
            // do a hit test on the vert
            if(cur.updateIfHit(cgp)) {
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

-(VertView*)addVertAtPoint:(CGPoint) cgp {
    double newX=cgp.x;
    double newY=cgp.y;
    
    VertView* vert=[[VertView alloc] initWithFrame:CGRectMake(newX, newY, self.circSize+self.edgeSize, self.circSize+self.edgeSize)];

    vert.circSize=self.circSize;
    vert.strokeSize=self.strokeSize;
    [self addSubview:vert];
    [self setNeedsDisplay];
    return vert;
}

func addEdgeWithFrame(frame:CGRect, edgeDirectionCase:Int) {
    EdgeView* ev=[[EdgeView alloc] initWithFrame:frame];
    ev.directionCase=edgeDirectionCase;
    // fill in the radius
    ev.radius=self.radius;
    [self addSubview:ev];
    [self sendSubviewToBack:ev];
}

// public
// return the VertView corresponding to a particular id
// or nil if such a VertView does not exist
-(VertView*) getVertViewById:(NSNumber*)vertViewId {

    for(id subview in self.subviews) {
        if([subview isKindOfClass:[VertView class]]) {
            VertView* vertView=subview;
            if([vertView.vertViewId isEqualToNumber:vertViewId]) {return vertView;}
        }
    }
    return nil;
}

}
