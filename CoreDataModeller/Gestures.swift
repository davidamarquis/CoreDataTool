//
//  Cow.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-06-16.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

import UIKit
import Foundation

// warning: in the context of this class, the terms vert and edge are refering to views not model objects
class gestureCC:CoreController, GestureResponse
{
    // 3 properties
    var gestureVV:VertView?;
    var shiftedOrigin:CGPoint?;
    var mustAddVert=false;
    var edgeViewToCheckRem:EdgeView?;
  
    //computed properties
    // gestureDidStartOnVert() is a computed flag: in handleStateChanged() and handleStateEnded() a gesture started on a vert if and only if gestureVV has a non-nil value
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
        // get location
        let loc = recog.locationInView(graphView!.gwv!);
        // get the relative location. This is used for testing if the gesture ended on a button
        //TODO: remove
        let relLoc = CGPointMake(loc.x - graphView!.contentOffset.x,loc.y - graphView!.contentOffset.y);
        
        let id1,id2:Int32;
        
        // Each case follows these steps: (1) check gesture, (2) check Move/Vert/Edge and if the given gesture does anything
        //in this state then assign any vert ids or edge ids, (3) using the ids get CoreController to respond. Cases:
        // case 1 = gesture started on addVertControl and ended somewhere
        // case 2 = gesture started on vertView and ended hitting the remove button
        // case 3 = gesture started on vertView and ended hitting another vert
        // case 4 = gesture started on vertView and ended hitting nothing
        // case 5 = gesture started on edgeView and ended hitting remEdgeControl
        // Methods for case determination are responsible for printing an error message if anything is nil
        if mustAddVert {
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
        else if inEdgeMode && edgeViewToCheckRem != nil {
 
            if remEdgeControl == nil {print("CoreController gestures: handleStateEnded: trying to remove edge but remEdgeControl is nil");}
            if CGRectContainsPoint(remEdgeControl!.frame, loc) {
            
                if edgeViewToCheckRem!.edgeViewId == nil {print("CoreController gestures: handleStateEnded: trying to remove edge but id is nil")}
                remEdge(edgeViewToCheckRem!.edgeViewId!);
            }
        }

        
        //TODO: rem this? remove the gestureVV if it exists
        gestureVV = nil;
    }
    
    // returns true if any of the subviews of the input view are hit
    func testSubviews(view:UIView,loc:CGPoint)->Bool {
        // TODO: 3:26pm changed pointInside to contains()
        if view.frame.contains(loc) {
            return true;
        }
        for x in view.subviews {
            if x.pointInside(loc, withEvent: nil) {
                return true;
            }
        }
        return false;
    }
    
    // MARK: methods for handleStateEnded()
    //
    private func vertEndsOnVert()->Bool {
        if inEdgeMode && gestureDidStartOnVert() {
            // error checking
            if shiftedOrigin == nil {print("CoreController gestures: vertEndsOnVert: shiftedOrigin nil when it is needed in edge mode");}
            if gestureVV == nil {print("CoreController gestures: vertEndsOnVert: gestureVV is nil when it is needed");}
            
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
            if gestureVV == nil {print("Graph extension: vertEndsOnRemControl: gestureVV is nil");}
            if remVertControl == nil {print("Graph extension: vertEndsOnRemControl: remVertControl is nil");}
            
            return CGRectIntersectsRect(gestureVV!.frame, remVertControl!.frame);
        }
        return false;
    }
    
    // getHitVertId() returns the id of the vertView that was hit by the user
    private func getHitVertId()->Int32 {
        // vertEndsOnVert() checks that we are in Edge mode
        if vertEndsOnVert() {
            let finalVertViewFrame:CGRect = CGRectMake(shiftedOrigin!.x, shiftedOrigin!.y, gestureVV!.frame.width, gestureVV!.frame.height);
            let vv:VertView? = getIntersectingVert(finalVertViewFrame, vv: gestureVV!);
            if vv == nil {print("CoreData gestures: getHitVertId: could not find intersecting vert");}
            
            if let retId = vv!.vertViewId {
                return retId;
            }
            else {print("CoreController sub: getHitVertId: err found nil vert id inside of guard");}
        }
        else { print("CoreController sub: getHitVertId: err failed to set id"); }
        return 0;
    }
    
    private func respondToNoHit() {
    
        if inVertMode && gestureDidStartOnVert() {
            if gestureVV!.vertViewId == nil { print(""); }
            
            let endPos=gestureVV!.frame.origin;
            if gestureVV!.vertViewId != nil {
                drawGraphAfterMovingVert(gestureVV!.vertViewId!, toXPos: Float(endPos.x), toYPos: Float(endPos.y) );
            }
            else {
            
            }
        }
    }
    
    // getIntersectingVert examines all the stored vertViews to see if any hits have occured. Returns the first vertView on which a hit has occured
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
    
    // checkFrame(): takes two frames as input. If these frames are equal and we are in vert mode checkFrames() prints and error message
    private func checkFramePositionsAndMode(frame1:CGRect,frame2:CGRect) {
        let org1,org2:CGPoint;
        (org1,org2)=(frame1.origin,frame2.origin);
        
        if ((fabs(org1.x - org2.x) > 0.01) || (fabs(org1.y - org2.y)) > 0.01) && inVertMode {
            print("GraphWorldView: getIntersectingVert: err: in Vert mode and the frames of the vertViews are not equal");
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
        
        edgeViewToCheckRem = nil;
        let startPos:CGPoint=recog.locationInView(graphView!.gwv!);
        //TODO: remove
        let relStart = CGPointMake(startPos.x - graphView!.contentOffset.x,startPos.y - graphView!.contentOffset.y);
        
        if graphView == nil {print("CoreController gestures: handleStateBegan: graphView is nil");}
        if graphView!.gwv == nil {print("CoreController gestures: handleStateBegan: gwv is nil");}
        
        // case 1: user has started a pan gesture from the add entity button
        if addVertControl != nil && inVertMode {
        
            // if we started on the addVertControl then we set the flag for adding vert
            if CGRectContainsPoint(addVertControl!.frame, startPos) {
            
                mustAddVert=true;
            }
        }
        
        // case 2: User has started a pan gesture from a vert.
        // At this point (1) mustAddVert is true if the starting point was contained in the frame and false otherwise
        // (2) gestureVV is nil,shiftedOrigin is nil.
        let N:Int=graphView!.gwv!.subviews.count;
        var i:Int=0;
        for(i=0;i<N;i++) {
            // get a view
            if(graphView!.gwv!.subviews[i] is VertView) {
                // check if view is hit
                
                if (graphView!.gwv!.subviews[i] as! VertView).frame.contains(startPos) {
                    // store a reference to the view
                    
                    gestureVV = graphView!.gwv!.subviews[i] as? VertView;
                    break;
                }
            }
        }
        
        // case 3: User has started a pan gesture from an edge.
        // At this point mustAddVert is true if and only if relLoc was contained in the frame
        // gestureVV is nil if and only if the user started the pan on a vert
        // shiftedOrigin is nil
        if inEdgeMode {
            let loc = recog.locationInView(graphView!.gwv!);
            for e in graphView!.gwv!.subviews {
                if e is EdgeView {
                    let edge=e as! EdgeView;
                    if testSubviews(edge,loc: loc) {
                        if edge.edgeViewId != nil {
                        
                            edgeViewToCheckRem=edge;
                        }
                        else {print("CoreController: handleStateEnded: edgeViewId is nil");}
                    }
                }
            }
        }
    }
    
}
