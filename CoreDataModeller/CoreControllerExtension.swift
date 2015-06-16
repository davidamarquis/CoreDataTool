//
//  CoreControllerExtension.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-06-15.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

import UIKit

extension CoreController {

    func handleStateBegan(recog:UIPanGestureRecognizer)
    {
        let startPos:CGPoint=recog.locationInView(graphView!.gwv!);
        let N:Int=graphView!.gwv!.subviews.count;
        var i:Int=0;
        
        // case 1: user has started a pan gesture from a vert
        for(i=0;i<N;i++) {
            // get a view
            if(graphView!.gwv!.subviews[i] is VertView) {
                // check if view is hit
                if (graphView!.gwv!.subviews[i] as! VertView).contains(startPos) {
                    // store a reference to the view
                    gestureVV = graphView!.gwv!.subviews[i] as? VertView;
                    vertViewFound=true;
                    break;
                }
            }
        }
        
        // if not case 1
        // case 2: user has started a pan gesture from a
        if !vertViewFound {
            if addVertControl != nil {

                if CGRectContainsPoint(addVertControl!.frame, startPos) {
                    addVert();
                }
            }
        }
        
        // reset the flag
        vertViewFound=false;
    }
        
    func handleStateChanged(recog:UIPanGestureRecognizer)
    {
        let translation:CGPoint=recog.translationInView(graphView!.gwv!);
        
        // if cur is nil then at the start of the gesture we need not recognize a gesture
        if gestureVV != nil {
        
            // if we are in vert mode then do a smooth pan of the vert object
            // if we are in edge mode then we still need to track where the frame would be if the vert had moved
            // this data is stored in a CGPoint variable
            if inVertMode {
                // move the center of gestureVV
                gestureVV!.center=CGPointMake(gestureVV!.center.x+translation.x, gestureVV!.center.y+translation.y);
                // reset the translation
                recog.setTranslation(CGPointMake(0,0), inView: graphView!.gwv!);
            }
            else if inEdgeMode {
                shiftedOrigin=CGPointMake(gestureVV!.frame.origin.x+translation.x, gestureVV!.frame.origin.y+translation.y);
            }
        }
    }
    
    func handleStateEnded(recog:UIPanGestureRecognizer) {
        if gestureVV != nil {
            // set the end position so that we can figure out where we parked

            // case 1 = vert ended hitting the remove button
            // case 2 = vert ended hitting another vert
            // case 3 = vert ended hitting nothing interesting
            if vertEndsOnRemControl(gestureVV!) {
                // remove the vert in the model
                remVert(gestureVV!.vertViewId!);
                
            }
            else if inEdgeMode {
            
                // set the final frame position if the vert had been moved
                // this should be the same as the frame of gestureVV
                let finalVertViewFrame:CGRect = CGRectMake(shiftedOrigin!.x, shiftedOrigin!.y, gestureVV!.frame.width, gestureVV!.frame.height);
                
                if getIntersectingVert(finalVertViewFrame, vv: gestureVV!) != nil {
                
                    let hitVV:VertView? = getIntersectingVert(finalVertViewFrame, vv: gestureVV! );
                    if hitVV != nil && hitVV!.vertViewId != nil && gestureVV!.vertViewId != nil {
                        let id1=gestureVV!.vertViewId!;
                        let id2=hitVV!.vertViewId!;
                        
                        // add an edge in CoreController
                        addEdge(id1, vertId2: id2);
                    }
                }
            }
            else {
                moveVertIfDidNotHit(gestureVV!)
            }
        }
        
        // remove the gestureVV it exists
        gestureVV = nil;
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
 
        for obj in graphView!.gwv!.subviews {
        
            if obj is VertView && (obj as! VertView) != vv {
                 // check if the frame of obj as a vert is intersecting with vframe
                 if CGRectIntersectsRect(vframe, (obj as! VertView).frame) {
                 
                     return (obj as! VertView);
                 }
            }
        }
        return nil;
    }
    
    
    private func moveVertIfDidNotHit(vv:VertView!) {
        if vv.vertViewId != nil {
            let endPos:CGPoint=vv.frame.origin;
            drawGraphAfterMovingVert(vv.vertViewId!, toXPos: Float(endPos.x), toYPos: Float(endPos.y) );
        }
    }
    
    // vertEndsOnRemControl() returns true if we are in vert mode and vv has ended on the control for removing verts
    private func vertEndsOnRemControl(vv:VertView)->Bool {
        if inVertMode {
            return CGRectIntersectsRect(vv.frame, remVertControl!.frame);
        }
        else {
            return false;
        }
    }
}
