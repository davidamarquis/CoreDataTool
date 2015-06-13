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
    var circSize,edgeSize,strokeSize: CGFloat?;
    // not used
    var x1,x2,y1,y2: Double?;
    var radius: CGFloat {return (circSize!+edgeSize!)/2; }
    var diameter: CGFloat {return (circSize!+edgeSize!); }
    var addVert:UILabel?;
    var remVert:UILabel?;
    var gestureVV:VertView?;

    // MARK: init
    override init(frame: CGRect) {
    
        // step1: set non-inherited properties
        circSize=50;
        edgeSize=10;
        strokeSize=5;
        
        // step 2: delegate to superclass
        super.init(frame: frame);
        
        // make the graph recognize taps
        let recog = UITapGestureRecognizer(target:self, action:"tap:");
        // step 3: set inherited properties
        self.backgroundColor=UIColor.whiteColor();
        addGestureRecognizer(recog);
        
        // add a gesture recognizer to the view
        addGestureRecognizer(UIPanGestureRecognizer(target:self, action:"pan:" ));
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
    
    // removeVertById
    // access the view controller using the delegate of the view that is passed to it
    func removeVertByVertView(vv:VertView) {
    
        if vv.vertViewId != nil && vv.delegate != nil {
            vv.delegate!.removeVertById(vv.vertViewId!);
        }
        else {
            println("GraphWorldView: removeVertByVertView: ");
        }
    }
    
    // MARK: gesture recognizers
    func pan(recognizer:UIPanGestureRecognizer) {
        let translation:CGPoint=recognizer.translationInView(self);
        let cgp:CGPoint=recognizer.locationInView(self);
        
        // at StateBegan we determine if a hit has been hit and if it has been we make a reference to that vert
        if(recognizer.state==UIGestureRecognizerState.Began) {
            
            let startPos:CGPoint=translation;
            
            //step 1: find the vert
            let N:Int=subviews.count;
            var i:Int=0;
            
            for(i=0;i<N;i++) {
                // get a view
                if(subviews[i] is VertView) {
                    // check if view is hit
                    if (subviews[i] as! VertView).contains(cgp) {
                        // store a reference to the view
                        gestureVV = subviews[i] as? VertView;
                        
                    }
                }
            }
        }
        else if(recognizer.state == UIGestureRecognizerState.Changed ) {
            // if cur is nil then at the start of the gesture we need not recognize a gesture
            if gestureVV != nil {
                // move the center of gestureVV
                gestureVV!.center=CGPointMake(gestureVV!.center.x+translation.x, gestureVV!.center.y+translation.y);
                // reset the translation
                recognizer.setTranslation(CGPointMake(0,0), inView: self);
                
            }
        }
        else if(recognizer.state==UIGestureRecognizerState.Ended) {
            if gestureVV != nil {
                // set the end position so that we can figure out where we parked
                let endPos:CGPoint=gestureVV!.frame.origin;
            
                // cur is the vert that has been hit (Assumption: can't hit more than one vert)
                // case 1 = vert ended hitting the delete button
                if CGRectIntersectsRect(gestureVV!.frame, remVert!.frame) {
                    // remove the vert in the model
                    removeVertByVertView(gestureVV!);
                }
                else {
                    if gestureVV!.delegate != nil && gestureVV!.vertViewId != nil {
                        // call the drawGraphAfterMovingVert method on the parent
                        gestureVV!.delegate!.drawGraphAfterMovingVert(gestureVV!.vertViewId!, toXPos: Float(endPos.x), toYPos: Float(endPos.y) );
                        gestureVV = nil;
                    }
                }
            }
        }
        else {
            println("VertView: pan: err state is not valid");
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

    //MARK: Vert Interface
    func addVertAtPoint(cgp:CGPoint)->VertView {
        let diameter:CGFloat=circSize!+edgeSize!;
        let vert:VertView=VertView( frame: CGRectMake(cgp.x, cgp.y, diameter, diameter) );
        (vert.circSize,vert.strokeSize)=(circSize,strokeSize);
        addSubview(vert);
        return vert;
    }
    // return the VertView corresponding to a particular id
    // or nil if such a VertView does not exist
    func getVertViewById(vertViewId:Int32) -> VertView? {

        for subview in subviews {
            if subview is VertView {
                let vertView:VertView=subview as! VertView;
                if(vertView.vertViewId == vertViewId) {return vertView;}
            }
            else {
                // probably subview is an Edge
            }
        }
        return nil;
    }

    //MARK: Edge Interface
    // setEdge sets the properties of an EdgeView. Returns a reference to this in case this view had init() in setEdge input
    func setEdge(ev:EdgeView, topLeftToBotRight:Bool)->EdgeView {
        ev.topLeftToBotRight=topLeftToBotRight;
        // fill in the radius
        ev.radius=radius;

        addSubview(ev);
        sendSubviewToBack(ev);
        return ev;
    }

    // return the EdgeView corresponding to a particular id
    func getEdgeViewById(edgeViewId:Int32)->EdgeView? {
        for subview in subviews {
            if subview is EdgeView {
            
                let edgeView:EdgeView=subview as! EdgeView;
                if(edgeView.edgeViewId == edgeViewId) {return edgeView;}
            }
        }
        return nil;
    }

}
