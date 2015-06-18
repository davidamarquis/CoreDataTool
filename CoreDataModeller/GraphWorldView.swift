//
//  GraphWorldView.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-06-01.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

import UIKit

protocol GestureResponse {
    // 4 methods for changing the model
    func handleStateBegan(recog:UIPanGestureRecognizer);
    func handleStateChanged(recog:UIPanGestureRecognizer);
    func handleStateEnded(recog:UIPanGestureRecognizer);
}
    
class GraphWorldView: UIView {

    var gestureResponseDelegate:GestureResponse?;
    
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
    
    var panCount=0;
    
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
    
    // MARK: gesture recognizers
    func pan(recognizer:UIPanGestureRecognizer) {
        panCount++;
        let translation:CGPoint=recognizer.translationInView(self);
        let loc:CGPoint=recognizer.locationInView(self);
        
        if gestureResponseDelegate == nil {println("GraphView: pan: delegate is nil");}
        
        if(recognizer.state==UIGestureRecognizerState.Began) {
            gestureResponseDelegate!.handleStateBegan(recognizer);
        }
        else if(recognizer.state == UIGestureRecognizerState.Changed ) {
            gestureResponseDelegate!.handleStateChanged(recognizer);
        }
        else if(recognizer.state==UIGestureRecognizerState.Ended) {
            gestureResponseDelegate!.handleStateEnded(recognizer);
            
            //reset panCount;
            panCount=0;
        }
        else {
            println("VertView: pan(): err state is not valid");
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
        
        //let recog:UIPanGestureRecognizer = UIPanGestureRecognizer(target: ev, action: "pan:");
        //ev.addGestureRecognizer(recog);
        return ev;
    }

    // return the EdgeView corresponding to a particular id
    func getEdgeViewById(edgeViewId:Int32)->EdgeView? {
        for subview in subviews {
            if subview is EdgeView {
            
                let edgeView:EdgeView=subview as! EdgeView;
                if(edgeView.edgeViewId == edgeViewId) {
                    println("GraphWorldView: getEdgeViewById: got edge with id \(edgeViewId)");
                    return edgeView;
                }
            }
        }
        return nil;
    }

}
