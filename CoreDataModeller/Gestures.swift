//
//  Cow.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-06-16.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

import UIKit
import Foundation

// warning: in the methods and comments of this class to be concise we will sometimes refer to vertViews as verts
class gestureCC:CoreController, GestureResponse
{
    // 3 properties
    var gestureVV:VertView?;
    var shiftedOrigin:CGPoint?;
    var mustAddVert=false;
  
    //computed properties
    private func gestureDidStartOnVert()->Bool {
        if gestureVV != nil {
            return true;
        }
        else {
            return false;
        }
    }
    
    ////
    //MARK: state ended methods
    func handleStateEnded(recog:UIPanGestureRecognizer) {
        
        let id1,id2:Int32;
        // case 1 = gesture started on addVertControl and ended somewhere
        // case 2 = gesture started on vertView and ended hitting the remove button
        // case 3 = gesture started on vertView and ended hitting another vert
        // case 4 = gesture started on vertView and ended hitting nothing
        // each case follows these steps: check what the gesture, check the state that CoreController is in, if the given gesture
        //does anything in this state then assign any vert or edge ids and get CoreController to respond
        // Style Warning: the bool *guards* are responsible for printing an error message if a variable needed inside the guard is nil
        //this makes the code below more readible
        if mustAddVert {
            let loc = recog.locationInView(graphView!.gwv!)
            addVert(loc);
        }
        else if vertEndsOnRemControl() {
        
            id1=gestureVV!.vertViewId!;
            remVert(id1);
        }
        else if vertEndsOnVert() {
        
            (id1,id2)=(gestureVV!.vertViewId!, getHitVertId());
            addEdge(id1, vertId2: id2);
        }
        else if inVertMode && gestureDidStartOnVert() {
            respondToNoHit();
        }
        
        // remove the gestureVV it exists
        gestureVV = nil;
    }
    
    ////
    // All helper methods below called by handleStateEnded() at some point
    //MARK: guards
    private func vertEndsOnVert()->Bool {
        if inEdgeMode && gestureDidStartOnVert() {
            // error checking
            if shiftedOrigin == nil {println("CoreController gestures: vertEndsOnVert: shiftedOrigin nil when it is needed in edge mode");}
            if gestureVV == nil {println("CoreController gestures: vertEndsOnVert: gestureVV is nil when it is needed");}
            
            let finalVertViewFrame:CGRect = CGRectMake(shiftedOrigin!.x, shiftedOrigin!.y, gestureVV!.frame.width, gestureVV!.frame.height);
            
            if getIntersectingVert(finalVertViewFrame, vv: gestureVV!) != nil {
                return true;
            }
        }
        return false;
    }
    
    // vertEndsOnRemControl() returns true if we are in vert mode and vv has ended on the control for removing verts
    private func vertEndsOnRemControl()->Bool {
        if inVertMode && gestureDidStartOnVert() {
            if gestureVV == nil {println("Graph extension: vertEndsOnRemControl: gestureVV is nil");}
            if remVertControl == nil {println("Graph extension: vertEndsOnRemControl: remVertControl is nil");}
            
            return CGRectIntersectsRect(gestureVV!.frame, remVertControl!.frame);
        }
        return false;
    }
    
    // getHitVertId() returns the id of the vertView that was hit by the vertView that was moved by the user
    private func getHitVertId()->Int32 {
        // vertEndsOnVert() checks that we are in Edge mode
        if vertEndsOnVert() {
            let finalVertViewFrame:CGRect = CGRectMake(shiftedOrigin!.x, shiftedOrigin!.y, gestureVV!.frame.width, gestureVV!.frame.height);
            let vv:VertView? = getIntersectingVert(finalVertViewFrame, vv: gestureVV!);
            if vv == nil {println("CoreData gestures: getHitVertId: could not find intersecting vert");}
            
            if let retId = vv!.vertViewId {
                return retId;
            }
            else {println("CoreController sub: getHitVertId: err found nil vert id inside of guard");}
        }
        else { println("CoreController sub: getHitVertId: err failed to set id"); }
        return 0;
    }
    
    //MARK: helpers
    private func respondToNoHit() {
        if inVertMode && gestureDidStartOnVert() {
            if gestureVV!.vertViewId == nil { println(); }
            
            let endPos=gestureVV!.frame.origin;
            drawGraphAfterMovingVert(gestureVV!.vertViewId!, toXPos: Float(endPos.x), toYPos: Float(endPos.y) );
        }
    }
    
    // getIntersectingVert examines all the stored vertViews to see if any collisions have occured. Returns the first vertView on which a hit has occured
    // this method is used for creating edges between verts
    private func getIntersectingVert(vframe:CGRect, vv:VertView!)->VertView? {
        
        checkFramePositionsAndMode(vframe, frame2: vv.frame);
 
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
    
    // checkFrame(): if in vertMode assert(vframe=vv.frame);
    private func checkFramePositionsAndMode(frame1:CGRect,frame2:CGRect) {
        let org1,org2:CGPoint;
        (org1,org2)=(frame1.origin,frame2.origin);
        
        if ((fabs(org1.x - org2.x) > 0.01) || (fabs(org1.y - org2.y)) > 0.01) && inVertMode {
            println("GraphWorldView: getIntersectingVert: err: in Vert mode and the frames of the vertViews are not equal");
        }
    }
    
    ////
    //MARK: stateChanged
    ////
    func handleStateChanged(recog:UIPanGestureRecognizer)
    {
    
        let translation:CGPoint=recog.translationInView(graphView!.gwv!);
        
        if inVertMode {
            // if cur is nil then at the start of the gesture we need not recognize a gesture
            if gestureDidStartOnVert() {
            
                // if we are in vert mode then do a smooth pan of the vert object
                // if we are in edge mode then we still need to track where the frame would be if the vert had moved
                // this data is stored in a CGPoint variable
                
                // move the center of gestureVV
                gestureVV!.center=CGPointMake(gestureVV!.center.x+translation.x, gestureVV!.center.y+translation.y);
                // reset the translation
                recog.setTranslation(CGPointMake(0,0), inView: graphView!.gwv!);
            }
        }
        else if inEdgeMode {
            if gestureDidStartOnVert() {
                shiftedOrigin=CGPointMake(gestureVV!.frame.origin.x+translation.x, gestureVV!.frame.origin.y+translation.y);
            }
        }
    }
    
    ////
    //MARK: stateBegan
    ////
    func handleStateBegan(recog:UIPanGestureRecognizer)
    {
        gestureVV = nil;
        shiftedOrigin = nil;
        mustAddVert = false;
        let startPos:CGPoint=recog.locationInView(graphView!.gwv!);
        
        if graphView == nil {println("CoreController gestures: handleStateBegan: graphView is nil");}
        if graphView!.gwv == nil {println("CoreController gestures: handleStateBegan: gwv is nil");}
        
        if addVertControl != nil {
            // if we started on the addVertControl then we set the flag for adding vert
            if CGRectContainsPoint(addVertControl!.frame, startPos) {
            
                mustAddVert=true;
            }
        }
        // at this point mustAddVert is true if the starting point was contained in the frame and false otherwise
        // gestureVV is nil
        // shiftedOrigin is nil
        
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
                    break;
                }
            }
        }
        // at this point mustAddVert is true iff was contained in the frame and false otherwise
        // gestureVV is nil iff the user started the pan on a vert
        // shiftedOrigin is nil
    }
    
}
