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
    var shiftedOrigin:CGPoint?;
    
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
            vv.delegate!.remVertById(vv.vertViewId!);
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
            if gestureVV != nil && gestureVV!.delegate != nil {
            
                // if we are in vert mode then do a smooth pan of the vert object
                // if we are in edge mode then we still need to track where the frame would be if the vert had moved
                // this data is stored in a CGPoint variable
                if gestureVV!.delegate!.inVertMode {
                    // move the center of gestureVV
                    gestureVV!.center=CGPointMake(gestureVV!.center.x+translation.x, gestureVV!.center.y+translation.y);
                    // reset the translation
                    recognizer.setTranslation(CGPointMake(0,0), inView: self);
                }
                else if gestureVV!.delegate!.inEdgeMode {
                    shiftedOrigin=CGPointMake(gestureVV!.frame.origin.x+translation.x, gestureVV!.frame.origin.y+translation.y);
                }
            }
        }
        else if(recognizer.state==UIGestureRecognizerState.Ended) {
            if gestureVV != nil {
                // set the end position so that we can figure out where we parked

                // case 1 = vert ended hitting the delete button
                // case 2 = vert ended hitting another vert
                // case 3 = vert ended hitting nothing interesting
                if CGRectIntersectsRect(gestureVV!.frame, remVert!.frame) {
                    // remove the vert in the model
                    removeVertByVertView(gestureVV!);
                }
                else if gestureVV!.delegate!.inEdgeMode {
                
                    // set the final frame position if the vert had been moved
                    // this should be the same as the frame of gestureVV
                    let finalVertViewFrame:CGRect = CGRectMake(shiftedOrigin!.x, shiftedOrigin!.y, gestureVV!.frame.width, gestureVV!.frame.height);
                    
                    
                    if getIntersectingVert(finalVertViewFrame, vv: gestureVV!) != nil {
                    
                        let hitVV:VertView? = getIntersectingVert(finalVertViewFrame, vv: gestureVV! );
                        if hitVV != nil && hitVV!.vertViewId != nil && gestureVV!.vertViewId != nil {
                            let id1=gestureVV!.vertViewId!;
                            let id2=hitVV!.vertViewId!;
                            
                            // add an edge in CoreController
                            gestureVV!.delegate!.addEdgeById(id1, vertId2: id2);
                        }
                    }
                }
                else {
                    if gestureVV!.delegate != nil && gestureVV!.vertViewId != nil {
                        // call the drawGraphAfterMovingVert method on the delegate (CoreController)
                        let endPos:CGPoint=gestureVV!.frame.origin;
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
    
    // getIntersectingVert examines all the stored vertViews to see if any collisions have occured. Returns the first vertView on which a hit has occured
    // this method is used for creating edges between verts
    func getIntersectingVert(vframe:CGRect, vv:VertView!)->VertView? {
        
        // error checking
        // access the current state through the delegate
        if fabs(vv.frame.origin.x - vframe.origin.x) < 0.01 && fabs(vv.frame.origin.y - vframe.origin.y) < 0.01 {
            if vv.delegate != nil {
                if !(vv.delegate!.inEdgeMode) {
                    //
                    println("GraphWorldView: getIntersectingVert: vframe not equal to vert.frame should only occur when in Edge mode. Current mode is \( vv.delegate!.curMode() )");
                }
            }
        }
 
        for obj in subviews {
        
            if obj is VertView && (obj as! VertView) != vv {
                 // check if the frame of obj as a vert is intersecting with vframe
                 if CGRectIntersectsRect(vframe, (obj as! VertView).frame) {
                 
                     return (obj as! VertView);
                 }
            }
        }
        return nil;
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
